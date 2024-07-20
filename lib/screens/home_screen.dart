import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';
import 'package:food_allergy_scanner/screens/matching_allergens_screen.dart';
import 'package:food_allergy_scanner/services/merriam_webster_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String removePunctuation(String text) {
    return text.replaceAll(RegExp(r'[^\w\s-]'), '');
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

 Future<bool> validateIngredients(BuildContext context, String text, StreamController<int> progressStream, int totalCount) async {
  final merriamWebsterService = MerriamWebsterService();
  bool isValidIngredients = true;
  int validCount = 0;

  List<String> words = text.split(RegExp(r'[\s,.;!?()]+'));
  words = words.where((word) => word.isNotEmpty).toList(); // Remove empty words

  List<String> toValidate = [];
  int validationQueueCount = 0;

  for (String word in words) {
    String normalizedWord = normalizeAccents(word);
    String cleanedWord = removePunctuation(normalizedWord.trim());

    if (cleanedWord.isNotEmpty) {
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // i.e. "B3" in Vitamin B3
        continue;
      }

      if (cleanedWord.toLowerCase() == 'vit') { // Replace "vit" with "Vitamin"
        print('Replacing abbreviation: $cleanedWord with "Vitamin"');
        cleanedWord = 'Vitamin';
      }

      validationQueueCount++;
      print('Adding to validation queue ($validationQueueCount): $cleanedWord');
      toValidate.add(cleanedWord);
    }
  }

  // Perform API validation in parallel
  int validatingWordCount = 0;
  int validatedWordCount = 0;

  List<Future<void>> validationFutures = toValidate.map((word) async {
    validatingWordCount++;
    print('Validating word ($validatingWordCount): $word');
    bool isValid = await merriamWebsterService.isValidWord(word.toLowerCase());
    if (isValid) {
      validatedWordCount++;
      print('Word validated ($validatedWordCount): $word');
      validCount++;
    } else {
      print('Word not found in dictionary: $word');
      List<String> suggestions = await merriamWebsterService.getSuggestions(word.toLowerCase());
      if (suggestions.isNotEmpty) {
        print('Suggestions for "$word": ${suggestions.join(', ')}');
      } else {
        print('No suggestions found for "$word".');
      }
      isValidIngredients = false;
    }
    progressStream.add(validCount);
  }).toList();

  // Wait for all validations to complete
  await Future.wait(validationFutures);

  double validityPercentage = (validCount / totalCount) * 100;
  print('Valid Count: $validCount, TotalCount: $totalCount'); // Check the correct total count
  print('Validity Percentage: $validityPercentage%');

  if (validityPercentage < 90) {
    print('Photo unclear. Validity threshold not met.');
    return false;
  } else {
    return true;
  }
}

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

  // Create a StreamController for progress updates
  final progressStream = StreamController<int>();

  // Prepare the list of words and handle replacements
  List<String> words = recognizedText.text.split(RegExp(r'[\s,.;!?()]+'));
  List<String> toValidate = [];
  int totalCount = 0;

  for (String word in words) {
    String normalizedWord = normalizeAccents(word);
    String cleanedWord = removePunctuation(normalizedWord.trim());

    if (cleanedWord.isNotEmpty) {
      if (RegExp(r'\d').hasMatch(cleanedWord)) {
        print('Skipping word with digits: $cleanedWord'); // i.e. "B3" in Vitamin B3
        continue;
      }

      if (cleanedWord.toLowerCase() == 'vit') { // Replace "vit" with "Vitamin"
        print('Replacing abbreviation: $cleanedWord with "Vitamin"');
        cleanedWord = 'Vitamin';
      }

      toValidate.add(cleanedWord);
      totalCount++;
    }
  }

  // Show loading dialog
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return LoadingDialog(
        totalIngredients: totalCount,
        progressStream: progressStream.stream,
      );
    },
  );

  bool isValidIngredients = await validateIngredients(context, recognizedText.text, progressStream, totalCount);

  // Close the StreamController
  progressStream.close();

  Navigator.of(context).pop(); // Close loading dialog

  if (!isValidIngredients) {
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

  bool isSafe = true;
  if (recognizedText.text.isNotEmpty) {
    for (String allergy in allergies) {
      String singular = Pluralize().singular(allergy);
      String plural = Pluralize().plural(allergy);

      RegExp regexSingular = RegExp(r"\b" + RegExp.escape(singular) + r"\b", caseSensitive: false);
      RegExp regexPlural = RegExp(r"\b" + RegExp.escape(plural) + r"\b", caseSensitive: false);

      print('Checking: Singular: $singular, Plural: $plural');

      if (regexSingular.hasMatch(recognizedText.text) || regexPlural.hasMatch(recognizedText.text)) {
        print('MATCH FOUND: "$allergy"');
        isSafe = false;
        matchingAllergens.add(allergy);
      }
    }
  } else {
    isSafe = false;
  }

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
              recognizedText.text.isNotEmpty
                  ? (isSafe ? 'The product is safe to eat!' : 'The product contains allergens!')
                  : 'No text was recognized!',
            ),
          ),
          if (!isSafe && recognizedText.text.isNotEmpty)
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
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
                  onPressed: hasAllergies ? () => scanProduct(context) : null,
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

class LoadingDialog extends StatelessWidget {
  final int totalIngredients;
  final Stream<int> progressStream;

  LoadingDialog({required this.totalIngredients, required this.progressStream});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Validating Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            StreamBuilder<int>(
              stream: progressStream,
              initialData: 0,
              builder: (context, snapshot) {
                int progress = snapshot.data!;
                return Column(
                  children: [
                    LinearProgressIndicator(value: progress / totalIngredients),
                    SizedBox(height: 10),
                    Text('$progress / $totalIngredients'),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
