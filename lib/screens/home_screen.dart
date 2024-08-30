import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
import 'package:crop_your_image/crop_your_image.dart';

import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';
import 'package:food_allergy_scanner/screens/matching_allergens_screen.dart';
import 'package:food_allergy_scanner/screens/crop_image_screen.dart';
import 'package:food_allergy_scanner/screens/camera_screen.dart';

import 'package:food_allergy_scanner/services/merriam_webster_service.dart';
import 'package:food_allergy_scanner/widgets/processing_dialog_widget.dart';
import 'package:food_allergy_scanner/widgets/validation_loading_dialog_widget.dart';
import 'package:food_allergy_scanner/utils/utils.dart';

//Removed ingredients/words/totalCount from being returned in validateIngredients, since normalizeIngredients already does so

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isProcessingImage =
      false; //Controls CircularProgressIndicator in Widget built
  File? _croppedFile;
  final CropController _cropController = CropController();


  String removeWordPunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s-&]'), ''); //allow '&', '-' (for "fd&c", "semi-skimmed")
  }

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

  Future<bool> _cropImage(File imageFile) async {
  final dynamic croppedData = await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CropScreen(
        imageFile: imageFile,
        cropController: _cropController,
      ),
    ),
  );

  if (croppedData == null || croppedData is! List<int>) {
    return false; // Indicate cropping was canceled or data is not valid
  }

  setState(() {
    _croppedFile = File('${imageFile.path}_cropped.jpg');
    _croppedFile!.writeAsBytesSync(croppedData);
  });

  return true; // Indicate cropping was confirmed
}

  Future<Map<String, dynamic>> validateIngredients(
  BuildContext context,
  String text,
  StreamController<int> progressStream,
  {
    int batchSize = 5, //Api request batch size
  }) async {
  final merriamWebsterService = MerriamWebsterService();
  final allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
  final predefinedValidWords = allergyProvider.predefinedValidWords;
  bool isValidIngredients = true;
  int validCount = 0;
  int checkedCount = 0;

  // Parse ingredients and words once --> next: validation
  final normalizedData = normalizeIngredients(text);
  final ingredients = normalizedData['ingredients'] as List<String>;
  final allWords = normalizedData['words'] as List<String>;
  final ingredientWordsMap = normalizedData['ingredientWordsMap'] as Map<String, List<String>>;
  final totalCount = normalizedData['totalCount'] as int;

  List<String> invalidIngredients = [];
  List<String> toValidate = [];

  print('validateIngredients() INGREDIENTS: $ingredients');

  for (String word in allWords) {
    String cleanedWord = removeWordPunctuation(word); // Remove punctuation from word

    if (cleanedWord.isNotEmpty) {
      // Special Case: Digits
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // e.g., "B3" in Vitamin B3
        continue;
      }

      // Special Case: Predefined valid words (i.e 'vit', 'fd&c', 'd&c')
      if (predefinedValidWords.contains(cleanedWord.toLowerCase())) {
        validCount++;
        checkedCount++;
        print('Skipping - PREDEFINED VALID ($validCount): $cleanedWord');
        progressStream.add(checkedCount); // Update progress for each checked word
        continue;
      } else {
        toValidate.add(cleanedWord); // Send word for validation
      }
    }
  }

  // Batch processing
  for (int i = 0; i < toValidate.length; i += batchSize) {
    final batch = toValidate.sublist(
      i,
      i + batchSize > toValidate.length ? toValidate.length : i + batchSize,
    );

    List<Future<void>> validationFutures = batch.map((word) async {
      checkedCount++;
      print('Validating word ($checkedCount): $word');
      bool isValid = await merriamWebsterService.isValidWord(word.toLowerCase());

      if (isValid) {
        //Ingredient is valid
        validCount++;
        print("WORD VALID!! ($validCount): $word");
      } else {
        isValidIngredients = false;
        //Ingredient is invalid
        print('WORD INVALID!! - Word not found in dictionary: [$word]');

        // Mark the entire ingredient as invalid
        String? ingredient;
        try {
          ingredient = ingredientWordsMap.entries
              .firstWhere((entry) => entry.value.contains(word))
              .key;
        } catch (e) {
          ingredient = null; // Handle the case where the word is not found
        }

        if (ingredient != null && !invalidIngredients.contains(ingredient)) {
          invalidIngredients.add(ingredient); //Add invalid ingredient to array
        }
      }
      progressStream.add(checkedCount); // Update progress for each checked word
    }).toList();

    // Wait for the batch to complete before moving on
    await Future.wait(validationFutures);
  }

  double validityPercentage = (validCount / totalCount) * 100;
  print('Valid Count: $validCount, Total Count: $totalCount');
  print('Validity Percentage: $validityPercentage%');

  return {
    'isValidIngredients': isValidIngredients,
    'validityPercentage': validityPercentage,
    'invalidIngredients': invalidIngredients,
  };
}

  
  
  Map<String, dynamic> normalizeIngredients(String text) {
   
    //Removes newlines from scanned text + "Ingredient(s), "May Contain", "Contain(s)"
    String removedWordsText = text
      .replaceAll(RegExp(r'\n'), ' ')
      .replaceAll(RegExp(r'\bIngredient\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bIngredients\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bMay\s+contain\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bContains\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\bContain\b', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  List<String> ingredients = removedWordsText
    .toLowerCase() // Convert the entire text to lowercase for uniformity
    .replaceAllMapped(
      // Special Case: Temporarily replace "natural and artificial flavouring/flavoring/flavors"
      RegExp(r'natural and artificial'), // Match the specific phrase "natural and artificial"
      (match) => 'natural_and_artificial' // Replace it with "natural_and_artificial" using underscores
    )
    .split(
      // Split the text into individual ingredients
      RegExp(
          r'\s*(?:\band\b|\bor\b|[\(\)\[\],.!?:])\s*') // Remove "and", "or", and punctuation
    )
    .map((ingredient) => ingredient.trim()) // Trim whitespace from each ingredient
    .where((ingredient) =>
        ingredient.isNotEmpty && // Exclude empty strings resulting from split
        ingredient.length > 1 && // Exclude single characters
        ingredient != '/') // Exclude slashes (if ingredient says "and/or")
    .map((ingredient) => 
        ingredient.replaceAll('_', ' ') // Special Case: Revert "natural_and_artificial" back to "natural and artificial"
    )
    .toList(); // Convert Iterable back to a List


  // Remove duplicate ingredients
  ingredients = ingredients.toSet().toList();

  // Map to keep track of which words belong to which ingredient
  Map<String, List<String>> ingredientWordsMap = {};
  List<String> allWords = [];

  for (String ingredient in ingredients) {
    String normalizedIngredient = normalizeAccents(ingredient); //Remove special accents from ingredients

    // Extract words from ingredients
    List<String> words = normalizedIngredient
        .split(RegExp(r'[\s,]+'))
        .map((word) => word.trim())
        .toList();

    ingredientWordsMap[ingredient] = words;
    allWords.addAll(words);
  }

  int totalCount = allWords.where((word) {
    String cleanedWord = removeWordPunctuation(word);
    return cleanedWord.isNotEmpty && !RegExp(r'\d').hasMatch(cleanedWord);
  }).length;

  return {
    'ingredients': ingredients,
    'words': allWords,
    'ingredientWordsMap': ingredientWordsMap,
    'totalCount': totalCount,
  };
}


  Future<void> scanProduct(BuildContext context) async {
    // Navigate to the CameraScreen and get the captured image file
  final File? imageFile = await Navigator.of(context).push<File>(
    MaterialPageRoute(builder: (context) => const CameraScreen()),
  );

  // User canceled the camera capture
  if (imageFile == null) {
    setState(() {
      _isProcessingImage = false;
    });
    showSnackBar(context, 'Scanning successfully cancelled.');
    return;
  }

  // Set the state to show the loading indicator
  setState(() {
    _isProcessingImage = true;
  });

  // Crop the image
  bool isCropConfirmed = await _cropImage(File(imageFile.path));

  if (!isCropConfirmed || _croppedFile == null) {
    setState(() {
      _isProcessingImage = false;
    });
    showSnackBar(context, 'Scanning successfully cancelled.');
    return;
  }

  // Show ProcessingDialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProcessingDialog(),
  );

  final InputImage inputImage = InputImage.fromFilePath(_croppedFile!.path);
  final textRecognizer = TextRecognizer();
  final RecognizedText recognizedText =
      await textRecognizer.processImage(inputImage);

  print('Scanned Ingredients: ${recognizedText.text}');

  Navigator.of(context).pop();
  setState(() {
    _isProcessingImage = false;
  });

  setState(() {
    _isProcessingImage = true;
  });
  
  // parse ingredients to get... 
  final normalizedData = normalizeIngredients(recognizedText.text);
  int totalCount = normalizedData['totalCount'] as int; //...totalCount (for validation loading dialog)
  List<String> ingredients = normalizedData['ingredients']; //...ingredients (for matching algorithm)
  List<String> words = normalizedData['words']; //...words

  final progressStream = StreamController<int>();

  // Show validation loading dialog with pre-calculated total count
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return ValidationLoadingDialog(
        totalIngredients: totalCount,
        progressStream: progressStream.stream,
      );
    },
  );

  // Convert the list of ingredients to a single string to send to validateIngredients
  final String ingredientsText = ingredients.join(', '); // Join ingredients with a comma separator


  //Validate Ingredients
  final validationResult = await validateIngredients(context, ingredientsText, progressStream);
  
  //Catch return values
    bool isValidIngredients = validationResult['isValidIngredients'];
    double validityPercentage = validationResult['validityPercentage'];
    List<String> invalidAllergens = validationResult['invalidIngredients'];

    //print("IMPORTED INGREDIENTS: $allIngredients");
    //print("IMPORTED WORDS: $allWords");
    //print("IMPORTED TOTALCOUNT: $totalCount2");

    // Close the StreamController
    progressStream.close();
    Navigator.of(context).pop(); // Close loading dialog

    //Reset the processing state for validationLoadingDialog
    setState(() {
      _isProcessingImage = false;
    });

    if (validityPercentage < 90) {
      print('Invalid ingredients scanned');
      textRecognizer.close();
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Center(child: Text('Scan Result')),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Text(
                  'Photo unclear or label contains many typos. Please try again.',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    AllergyProvider allergyProvider =
        Provider.of<AllergyProvider>(context, listen: false);
    List<String> allergies = allergyProvider.allergies;
    List<String> matchingAllergens = [];
    List<String> safeIngredients = [];
    bool isSafe = true;

    //NEW2 - concise matching logic

    if (ingredients.isNotEmpty) {
  print('scanProduct() INGREDIENTS: $ingredients');

  for (String ingredient in ingredients) {
    String cleanedIngredient = ingredient.trim();

    // Exclude words with percentages and empty words
    if (cleanedIngredient.isNotEmpty &&
        !RegExp(r'\d+%').hasMatch(cleanedIngredient)) {
      bool matchesAllergy = false;
      for (String allergy in allergies) {

        //Check ingredient against single + plural versions of allergen
        String singular = Pluralize().singular(allergy);
        String plural = Pluralize().plural(allergy);
        RegExp regexSingular = RegExp(r"\b" + RegExp.escape(singular) + r"\b", caseSensitive: false);
        RegExp regexPlural = RegExp(r"\b" + RegExp.escape(plural) + r"\b", caseSensitive: false);

        print('[Checking: Singular]: $singular, [Plural: $plural] --> In [ingredient: $cleanedIngredient]');

        if (regexSingular.hasMatch(cleanedIngredient) ||
            regexPlural.hasMatch(cleanedIngredient)) {
          print('MATCH FOUND: "$allergy" in ingredient: "$cleanedIngredient"');
          matchesAllergy = true;
          isSafe = false; // Set isSafe to false if any match is found
          matchingAllergens.add(allergy);
          break; // Stop checking other allergies if a match is found
        }
      }
      
      // If no allergies matched and the ingredient is not invalid, add it to safeIngredients
      if (!matchesAllergy && !invalidAllergens.contains(cleanedIngredient)) {
        safeIngredients.add(cleanedIngredient);
      }
    }
  }
} else {
  isSafe = false; // Set isSafe to false if no ingredients are found
}

// Remove duplicates from matchingAllergens
matchingAllergens = matchingAllergens.toSet().toList();


    //Debugging - array contents
    print('Matching Allergens: ${matchingAllergens.length}');
    print(matchingAllergens);

    print('Invalid Allergens: ${invalidAllergens.length}');
    print(invalidAllergens);

    print('Safe Ingredients: ${safeIngredients.length}');
    print(safeIngredients);

    textRecognizer.close();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Scan Result')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                //NEW2 - combinedText.isNotEmpty
                ingredients.isNotEmpty
                    ? (isSafe
                        ? 'The product is safe to eat!'
                        : 'The product contains allergens!')
                    : 'No text was recognized!',
              ),
            ),
            if (validityPercentage >= 90 && validityPercentage < 100)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.yellow[100],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Some ingredients were not recognized due to typos or an unclear photo. Visit "See Details" for more information.',
                          style: TextStyle(color: Colors.orange),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (ingredients //NEW2 - combinedText
                .isNotEmpty) // //See Details shows for safe / unsafe products
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchingAllergensScreen(
                        matchingAllergens: matchingAllergens,
                        invalidAllergens: invalidAllergens,
                        safeIngredients: safeIngredients,
                      ),
                    ),
                  );
                },
                child: const Text('See Details'),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

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
        title: const Text('Food Allergy Scanner'),
      ),
      body: Consumer<AllergyProvider>(
        builder: (context, allergyProvider, child) {
          bool hasAllergies = allergyProvider.allergies.isNotEmpty;
          return Center(
            child: _isProcessingImage
                ? const CircularProgressIndicator() // v0.8.9 - loading indicator. Starts from image capture, Ends at Scan Results
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      const Text(
                        'Scan a product to check for allergens!',
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: hasAllergies
                            ? () => scanProduct(context)
                            : () {
                                showSnackBar(context,
                                    'Please add at least one allergen before scanning.');
                              },
                        child: const Text('Scan Product'),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => manageAllergies(context),
                        child: const Text('Manage Allergies'),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}
