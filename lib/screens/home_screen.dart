import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';
import 'package:food_allergy_scanner/screens/matching_allergens_screen.dart';
import 'package:food_allergy_scanner/services/merriam_webster_service.dart';

class HomeScreen extends StatelessWidget {
  // Function to remove punctuation from a string
  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s-]'), ''); // Remove all non-word characters except spaces and hyphens
  }

  // Function to normalize accented characters to their base forms
  String normalizeAccents(String input) {
    return input
        .replaceAll(RegExp(r'[àáâãäå]', caseSensitive: false), 'a')
        .replaceAll(RegExp(r'[èéêë]', caseSensitive: false), 'e')
        .replaceAll(RegExp(r'[ìíîï]', caseSensitive: false), 'i')
        .replaceAll(RegExp(r'[òóôõö]', caseSensitive: false), 'o')
        .replaceAll(RegExp(r'[ùúûü]', caseSensitive: false), 'u')
        .replaceAll(RegExp(r'[ñ]', caseSensitive: false), 'n')
        .replaceAll(RegExp(r'[ç]', caseSensitive: false), 'c')
        .replaceAll(RegExp(r'[ß]', caseSensitive: false), 'ss');
  }

 Future<bool> validateIngredients(String text) async {
  final merriamWebsterService = MerriamWebsterService();
  bool isValidIngredients = true;
  int validCount = 0;
  int totalCount = 0;

  List<String> ingredients = text.split(RegExp(r'\s*[\(\),.!?]+\s*'));

  for (String ingredient in ingredients) {
    print("Ingredient: $ingredient");

    String normalizedIngredient = normalizeAccents(ingredient);

    List<String> words = [];
    words = normalizedIngredient.split(RegExp(r'[\s,.!?]+'));

    List<String> cleanedIngredients = [];
    for (String word in words) {
      String cleanedWord = removePunctuation(word.trim());
      if (cleanedWord.isNotEmpty) {
        if (RegExp(r'\d').hasMatch(cleanedWord)) {
          print('Skipping word with digits: $cleanedWord');
          continue;
        }
        cleanedIngredients.add(cleanedWord);
      }
    }

    bool isIngredientValid = true;
    for (String cleanedIngredient in cleanedIngredients) {
      print('Validating Word: $cleanedIngredient');
      bool isValid = await merriamWebsterService.isValidWord(cleanedIngredient.toLowerCase());

      if (!isValid) {
        List<String> suggestions = await merriamWebsterService.getSuggestions(cleanedIngredient.toLowerCase());
        if (suggestions.isNotEmpty) {
          print('Suggestions for "$cleanedIngredient": ${suggestions.join(', ')}');
        } else {
          print('No suggestions found for "$cleanedIngredient".');
        }
        isIngredientValid = false;
      } else {
        print('Word Validated: $cleanedIngredient');
        validCount++;
      }
      totalCount++;
    }

    if (!isIngredientValid) {
      print('Validating Ingredient: $ingredient');
      bool isValid = await merriamWebsterService.isValidWord(normalizedIngredient.toLowerCase());

      if (!isValid) {
        List<String> suggestions = await merriamWebsterService.getSuggestions(normalizedIngredient.toLowerCase());
        if (suggestions.isNotEmpty) {
          print('Suggestions for "$ingredient": ${suggestions.join(', ')}');
        } else {
          print('No suggestions found for "$ingredient".');
        }
        isValidIngredients = false;
      } else {
        print('Ingredient Validated: $ingredient');
        validCount++;
      }
      totalCount++;
    }
  }

  double validityPercentage = (validCount / totalCount) * 100;
  print('Validity Percentage: $validityPercentage%');

  if (validityPercentage < 90) {
    print('Photo unclear. Validity threshold not met.');
    return false;
  }
  else{
    return true;
  }

  //return isValidIngredients;
}

  // Function to initiate product scanning
  Future<void> scanProduct(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    if (image == null) {
      // User canceled the picker
      return;
    }

    final InputImage inputImage = InputImage.fromFilePath(image.path);
    final textRecognizer = TextRecognizer();
    final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

    // Print out all the ingredients that were scanned
    print('Scanned Ingredients: ${recognizedText.text}');

    bool isValidIngredients = await validateIngredients(recognizedText.text);

    if (!isValidIngredients) {
      // Handle case where ingredients are not valid (e.g., show message, reset state)
      print('Invalid ingredients scanned');
      textRecognizer.close();

      // Show dialog with scan result
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Center(child: Text('Scan Result')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Photo unclear. Please try again.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );

      return;
    }

    // Proceed with allergen matching logic
    AllergyProvider allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
    List<String> allergies = allergyProvider.allergies;
    List<String> matchingAllergens = [];

    // Check if any allergen matches with the recognized text
    bool isSafe = true;
    if (recognizedText.text.isNotEmpty) {
      for (String allergy in allergies) {
        // Check both singular and plural forms
        String singular = Pluralize().singular(allergy);
        String plural = Pluralize().plural(allergy);

        RegExp regexSingular = RegExp(r"\b" + RegExp.escape(singular) + r"\b", caseSensitive: false);
        RegExp regexPlural = RegExp(r"\b" + RegExp.escape(plural) + r"\b", caseSensitive: false);

        print('Checking: Singular: $singular, Plural: $plural');

        if (regexSingular.hasMatch(recognizedText.text) || regexPlural.hasMatch(recognizedText.text)) {
          print('MATCH FOUND: "$allergy"');
          isSafe = false;
          matchingAllergens.add(allergy); // Add matching allergen to the list
        }
      }
    } else {
      // No text was recognized
      isSafe = false;
    }

    textRecognizer.close(); // Close the text recognizer

    // Show dialog with scan result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Scan Result')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                recognizedText.text.isNotEmpty
                    ? (isSafe ? 'The product is safe to eat!' : 'The product contains allergens!')
                    : 'No text was recognized!',
              ),
            ),
            if (!isSafe && recognizedText.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the current dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchingAllergensScreen(matchingAllergens: matchingAllergens),
                    ),
                  );
                },
                child: Text('See Details'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Function to navigate to manage allergies screen
  void manageAllergies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageAllergiesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Allergy Scanner'),
      ),
      body: Consumer<AllergyProvider>(
        builder: (context, allergyProvider, child) {
          bool hasAllergies = allergyProvider.allergies.isNotEmpty;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Scan a product to check for allergens!',
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: hasAllergies
                      ? () => scanProduct(context)
                      : () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Please add at least one allergen before scanning.')),
                          );
                        },
                  child: Text('Scan Product'),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => manageAllergies(context),
        tooltip: 'Manage Allergies',
        child: Icon(Icons.edit),
      ),
    );
  }
}
