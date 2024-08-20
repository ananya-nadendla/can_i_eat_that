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
import 'package:food_allergy_scanner/widgets/validation_loading_dialog_widget.dart'; // Import the widget file


class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  bool _isProcessingImage = true;
  File? _croppedFile;

  String removePunctuation(String text) {
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

  List<String> words = text.split(RegExp(r'[\s,.;!?()\[\]]+'));
  words = words.where((word) => word.isNotEmpty).toList(); // Remove empty words
  List<String> toValidate = [];

  List<String> ingredients = text.split(RegExp(r'\s*[\(\)\[\],.!?]+\s*'));
  Map<String, List<String>> ingredientWordsMap = {}; // Map to keep track of which words belong to which ingredient

  for (String ingredient in ingredients) {
    String normalizedIngredient = normalizeAccents(ingredient);
    ingredientWordsMap[ingredient] = normalizedIngredient.split(RegExp(r'[\s,]+')).map((word) => word.trim()).toList();
  }

  for (String word in words) {
    String normalizedWord = normalizeAccents(word);
    String cleanedWord = removePunctuation(normalizedWord.trim());

    if (cleanedWord.isNotEmpty) {
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // i.e. "B3" in Vitamin B3
        continue;
      }

      if (predefinedValidWords.contains(cleanedWord.toLowerCase())) {
        validCount++;
        checkedCount++;
        print('Skipping - PREDEFINED VALID ($validCount): $cleanedWord');
        progressStream.add(checkedCount); // Update progress for each checked word
        continue;
      } else {
        toValidate.add(cleanedWord);
      }
    }
  }

  // Perform API validation in parallel
  List<Future<void>> validationFutures = toValidate.map((word) async {
    checkedCount++;
    print('Validating word ($checkedCount): $word');
    bool isValid = await merriamWebsterService.isValidWord(word.toLowerCase());

    if (isValid) {
      validCount++;
      print("WORD VALID!! ($validCount): $word");
    } else {
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
        invalidIngredients.add(ingredient);
      }

     
    }
    progressStream.add(checkedCount); // Update progress for each checked word
  }).toList();

  // Wait for all validations to complete
  await Future.wait(validationFutures);
  double validityPercentage = (validCount / totalCount) * 100;
  print('Valid Count: $validCount, TotalCount: $totalCount'); // Check the correct total count
  print('Validity Percentage: $validityPercentage%');

  return {
    'isValidIngredients': isValidIngredients,
    'validityPercentage': validityPercentage,
    'invalidIngredients': invalidIngredients
  };
}

Future<void> scanProduct(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.camera);

  if (image == null) {
    // User canceled the picker
    setState(() {
      _isProcessingImage = false; // Stop processing
    });
    return;
  }

  // Crop the image
  bool isCropped = await _cropImage(File(image.path));

  if (!isCropped) {
    // User canceled cropping
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
  setState(() {
    _isProcessingImage = true; // Start processing
  });

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

  // Combine split lines into single ingredients
  String combinedText = recognizedText.text.replaceAll(RegExp(r'\n'), ' ');
  
  // Remove "Ingredient" and "Ingredients" from list
  combinedText = combinedText.replaceAll(RegExp(r'\bIngredient\b', caseSensitive: false), '');
  combinedText = combinedText.replaceAll(RegExp(r'\bIngredients\b', caseSensitive: false), '');
  // Optionally, remove extra spaces that may result from the replacements
  combinedText = combinedText.replaceAll(RegExp(r'\s+'), ' ').trim();

  print("!! Combined Text: $combinedText");

  // Show ValidationLoadingDialog for validation
  final progressStream = StreamController<int>();

  // Prepare the list of words and handle replacements
  List<String> words = combinedText.split(RegExp(r'[\s,.;!?()]+'));
  int totalCount = 0;

  for (String word in words) {
    String normalizedWord = normalizeAccents(word);
    String cleanedWord = removePunctuation(normalizedWord.trim());

    if (cleanedWord.isNotEmpty) {
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // i.e. "B3" in Vitamin B3
        continue;
      }
      totalCount++;
    }
  }

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

  if (validityPercentage < 90) {
    print('Invalid ingredients scanned');
    textRecognizer.close();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Center(child: Text('Scan Result')),
        content: Column(
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
            child: Text('OK'),
          ),
        ],
      ),
    );
    return;
  }

  AllergyProvider allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
  List<String> allergies = allergyProvider.allergies;
  List<String> matchingAllergens = [];
  List<String> safeIngredients = []; // Add this line
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

    // Populate safeIngredients with the ingredients that do not match allergens
    List<String> ingredients = combinedText.split(RegExp(r'\s*[\(\)\[\],.!?]+\s*'));
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

  //Debugging array contents
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
      title: Center(child: Text('Scan Result')),
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
                padding: EdgeInsets.all(8.0),
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
          if (/*!isSafe &&*/ combinedText.isNotEmpty) //See Details shows for safe / unsafe products
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MatchingAllergensScreen(
                      matchingAllergens: matchingAllergens,
                      invalidAllergens: invalidAllergens,
                      safeIngredients: safeIngredients, // Pass safeIngredients here
                    ),
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
                  style: TextStyle(fontSize: 20),
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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => manageAllergies(context),
                  child: Text('Manage Allergies'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}