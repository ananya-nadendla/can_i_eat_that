import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
import 'package:image_cropper/image_cropper.dart';

import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';
import 'package:food_allergy_scanner/screens/matching_allergens_screen.dart';
import 'package:food_allergy_scanner/services/merriam_webster_service.dart';
import 'package:food_allergy_scanner/widgets/processing_dialog_widget.dart'; 
import 'package:food_allergy_scanner/widgets/validation_loading_dialog_widget.dart'; 
import 'package:food_allergy_scanner/utils/utils.dart';


//NOTES - v0.8.5
    //v0.8.3 issue - 'and/or' still being validated because they werent removed from words list, only ingredients
    //solution - derive words from ingredients list, NOT words from text
//DONE - for both validateIngredients and scanProducts, words are derived the same way

//Question - why is the words array in scanproduct?

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _isProcessingImage = false; //Controls CircularProgressIndicator in Widget built
  File? _croppedFile;

  String removeWordPunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s-&]'), '');
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
  final croppedFile = await ImageCropper().cropImage(
    sourcePath: imageFile.path,
    compressFormat: ImageCompressFormat.jpg,
    compressQuality: 100,
    uiSettings: [
      AndroidUiSettings(
        toolbarTitle: 'Cropper',
        toolbarColor: Colors.deepOrange,
        toolbarWidgetColor: Colors.white,
        initAspectRatio: CropAspectRatioPreset.original,
        lockAspectRatio: false,
      ),
      IOSUiSettings(
        title: 'Cropper',
      ),
      WebUiSettings(
        context: context,
        presentStyle: WebPresentStyle.dialog,
        size: const CropperSize(
          width: 520,
          height: 520,
        ),
      ),
    ],
  );

  if (croppedFile != null) {
    setState(() {
      _croppedFile = File(croppedFile.path);
    });
    return true; // Cropping was successful
  } else {
    return false; // Cropping was canceled
  }
}

Future<Map<String, dynamic>> validateIngredients(
    BuildContext context,
    String text,
    StreamController<int> progressStream,
    int totalCount,
) async {

  final merriamWebsterService = MerriamWebsterService();
  final allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
  final predefinedValidWords = allergyProvider.predefinedValidWords;
  bool isValidIngredients = true;
  int validCount = 0;
  int checkedCount = 0;

  List<String> invalidIngredients = [];
  List<String> toValidate = [];

  // Split ingredients list into ingredients (can contain multiple words) + cleanup
  List<String> ingredients = text
  .split(RegExp(r'\s*(?:\band\b|\bor\b|[\(\)\[\],.!?:])\s*')) //v0.8.3 - Remove AND, OR, and COLON
  .map((ingredient) => ingredient.trim()) //Remove whitespace
  .where((ingredient) => ingredient.isNotEmpty) //Remove empty strings after splitting
  .toList();
  
  print('validateIngredients() INGREDIENTS: $ingredients');

  // Map to keep track of which words belong to which ingredient
  Map<String, List<String>> ingredientWordsMap = {}; 

  // Send ingredients to validation program
  for (String ingredient in ingredients) {
    String normalizedIngredient = normalizeAccents(ingredient); //Remove special accents from ingredients

    //Extract words from ingredients
    List<String> words = normalizedIngredient.split(RegExp(r'[\s,]+')).map((word) => word.trim()).toList();
    print('validateIngredients() WORDS: $words'); //Debugging - print split words in an ingredient
    ingredientWordsMap[ingredient] = words;

    for (String word in words) {
      String cleanedWord = removeWordPunctuation(word); //Remove punctuation from word

      if (cleanedWord.isNotEmpty) {
        //Special Case: Digits
        if (RegExp(r'\d').hasMatch(cleanedWord)) {
          print('Skipping word with digits: $cleanedWord'); // e.g., "B3" in Vitamin B3
          continue;
        }

        //Special Case: Predefined valid words (i.e 'vit', 'fd&c', 'd&c')
        if (predefinedValidWords.contains(cleanedWord.toLowerCase())) {
          validCount++;
          checkedCount++;
          print('Skipping - PREDEFINED VALID ($validCount): $cleanedWord');
          progressStream.add(checkedCount); // Update progress for each checked word
          continue;
        } else {
          toValidate.add(cleanedWord); //Send word for validation
        }
      }
    }
  }

  // Word Validation - Perform API validation in parallel
  List<Future<void>> validationFutures = toValidate.map((word) async {
    checkedCount++;
    print('Validating word ($checkedCount): $word');
    bool isValid = await merriamWebsterService.isValidWord(word.toLowerCase());


    if (isValid) { //Ingredient is valid
      validCount++;
      print("WORD VALID!! ($validCount): $word");
    } 
    
    else { //Ingredient is invalid
      print('Word not found in dictionary: $word');
      isValidIngredients = false;

      // Mark the entire ingredient as invalid
      String? ingredient;
      try {
        ingredient = ingredientWordsMap.entries.firstWhere((entry) => entry.value.contains(word)).key;
      } catch (e) {
        // Handle the case where the word is not found
        ingredient = null;
      }

      if (ingredient != null && !invalidIngredients.contains(ingredient)) {
        invalidIngredients.add(ingredient); //Add invalid ingredient to array
      }
    }
    progressStream.add(checkedCount); // Update progress for each checked word
  }).toList();

  // Wait for all validations to complete
  await Future.wait(validationFutures);
  double validityPercentage = (validCount / totalCount) * 100;
  print('Valid Count: $validCount, Total Count: $totalCount');
  print('Validity Percentage: $validityPercentage%');

  return {
    'isValidIngredients': isValidIngredients,
    'validityPercentage': validityPercentage,
    'invalidIngredients': invalidIngredients,
  };
}
Future<void> scanProduct(BuildContext context) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  // User canceled the picker
  if (image == null) {
    setState(() {
      _isProcessingImage = false; // Stop processing
    });
    return;
  }

  // Set the state to show the loading indicator
  setState(() {
    _isProcessingImage = true;
  });

  // Crop the image
  bool isCropped = await _cropImage(File(image.path));

  // User canceled cropping
  if (!isCropped) {
    setState(() {
      _isProcessingImage = false; // Stop processing
    });
    return; // Exit scanProduct without continuing to process the image
  }

  // Show ProcessingDialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => ProcessingDialog(),
  );

  final InputImage inputImage = InputImage.fromFilePath(_croppedFile!.path);
  final textRecognizer = TextRecognizer();
  final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);

  // Print out all the ingredients that were scanned
  print('Scanned Ingredients: ${recognizedText.text}');

  // Close ProcessingDialog
  Navigator.of(context).pop();
  setState(() {
    _isProcessingImage = false; // Stop processing
  });

  //Continue showing CircularProgressIndicator for validationLoadingDialog
  setState(() {
    _isProcessingImage = true;
  });

  // Remove newlines + extra spaces to create single continous block of text
  // Remove Keywords: "Ingredient", "Ingredients", "Contains", "May Contain"
  String combinedText = recognizedText.text.replaceAll(RegExp(r'\n'), ' ')
    .replaceAll(RegExp(r'\bIngredient\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\bIngredients\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\bMay\s+contain\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\bContains\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\bContain\b', caseSensitive: false), '')
    .replaceAll(RegExp(r'\s+'), ' ').trim(); // Remove extra spaces that may result from the above replacements

  
print("!! Combined Text !!: $combinedText");

  // Show ValidationLoadingDialog for validation
  final progressStream = StreamController<int>();

  // Create ingredients list using the same logic as validateIngredients
  List<String> ingredients = combinedText
    .split(RegExp(r'\s*(?:\band\b|\bor\b|[\(\)\[\],.!?:])\s*')) //Splitting logic - v0.8.3 - Remove AND, OR, and COLON
    .map((ingredient) => ingredient.trim()) // Remove whitespace
    .where((ingredient) => ingredient.isNotEmpty) // Remove empty strings after splitting
    .toList();

   print('Ingredients: $ingredients');

  int totalCount = 0; //Number of words

   //Create words list (from ingredients list) using same logic as validateIngredients
  List<String> words = [];
  for (String ingredient in ingredients) {
    
    //Remove special accents from ingredients
    String normalizedIngredient = normalizeAccents(ingredient); 

    //Extract words from ingredients
    words = normalizedIngredient.split(RegExp(r'[\s,]+')).map((word) => word.trim()).toList();
    for (String word in words) {
      String normalizedWord = normalizeAccents(word);
      String cleanedWord = removeWordPunctuation(normalizedWord.trim());

      if (cleanedWord.isNotEmpty) {
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // i.e. "B3" in Vitamin B3
        continue;
      }
      totalCount++;
    }
  }
    print('scanProduct() WORDS: $words'); //Debugging purposes
  }

  print("TOTAL COUNT scanProduct: $totalCount"); //Debugging purposes

   // Show loading dialog
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

  final validationResult = await validateIngredients(context, combinedText, progressStream, totalCount);
  bool isValidIngredients = validationResult['isValidIngredients'];
  double validityPercentage = validationResult['validityPercentage'];
  List<String> invalidAllergens = validationResult['invalidIngredients'];

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

  AllergyProvider allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
  List<String> allergies = allergyProvider.allergies;
  List<String> matchingAllergens = [];
  List<String> safeIngredients = [];
  bool isSafe = true;

  if (combinedText.isNotEmpty) {
    for (String allergy in allergies) {
      String singular = Pluralize().singular(allergy);
      String plural = Pluralize().plural(allergy);
      RegExp regexSingular = RegExp(r"\b" + RegExp.escape(singular) + r"\b", caseSensitive: false);
      RegExp regexPlural = RegExp(r"\b" + RegExp.escape(plural) + r"\b", caseSensitive: false);

      print('Checking: Singular: $singular, Plural: $plural');

      if (regexSingular.hasMatch(combinedText) || regexPlural.hasMatch(combinedText)) {
        print('MATCH FOUND: "$allergy"');
        isSafe = false;
        matchingAllergens.add(allergy);
      }
    }

    print('scanProduct() INGREDIENTS: $ingredients');

    for (String ingredient in ingredients) {
      String cleanedIngredient = ingredient.trim();

      // Exclude words with percentages and empty words
      if (cleanedIngredient.isNotEmpty && !RegExp(r'\d+%').hasMatch(cleanedIngredient)) {
        bool matchesAllergy = false;
        for (String allergy in allergies) {
          String singular = Pluralize().singular(allergy);
          String plural = Pluralize().plural(allergy);
          RegExp regexSingular = RegExp(r"\b" + RegExp.escape(singular) + r"\b", caseSensitive: false);
          RegExp regexPlural = RegExp(r"\b" + RegExp.escape(plural) + r"\b", caseSensitive: false);

          if (regexSingular.hasMatch(cleanedIngredient) || regexPlural.hasMatch(cleanedIngredient)) {
            matchesAllergy = true;
            break;
          }
        }
        if (!matchesAllergy && !invalidAllergens.contains(cleanedIngredient)) {
          safeIngredients.add(cleanedIngredient);
        }
      }
    }
  } else {
    isSafe = false;
  }

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
              combinedText.isNotEmpty
                  ? (isSafe ? 'The product is safe to eat!' : 'The product contains allergens!')
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
          if (combinedText.isNotEmpty) // //See Details shows for safe / unsafe products
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
                            showSnackBar(context, 'Please add at least one allergen before scanning.');
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