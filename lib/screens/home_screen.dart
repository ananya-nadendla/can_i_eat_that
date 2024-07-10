import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:pluralize/pluralize.dart';


import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';
import 'package:food_allergy_scanner/screens/matching_allergens_screen.dart';


class HomeScreen extends StatelessWidget {
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

    // Access the allergy provider and existing allergies list
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

        print('Checking: Singular: $singular, Plural: $plural'); // Debugging - print singular and plural forms

        if (regexSingular.hasMatch(recognizedText.text) || regexPlural.hasMatch(recognizedText.text)) {
          print('MATCH FOUND: "$allergy"'); // Debugging - prints match between ingredients & allergen
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
        title: Center(child: Text('Scan Result')), // Centered title of the dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Text(
                recognizedText.text.isNotEmpty
                    ? (isSafe ? 'The product is safe to eat!' : 'The product contains allergens!')
                    : 'No text was recognized!',
              ),
            ), // Centered result message
            if (!isSafe && recognizedText.text.isNotEmpty)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the current dialog
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MatchingAllergensScreen(matchingAllergens: matchingAllergens), // Navigate to MatchingAllergensScreen with matching allergens
                    ),
                  );
                },
                child: Text('See Details'), // Button to see details of matching allergens
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Close the dialog
            child: Text('OK'), // OK button to dismiss dialog
          ),
        ],
      ),
    );
  }

  // Function to navigate to manage allergies screen
  void manageAllergies(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ManageAllergiesScreen()), // Navigate to ManageAllergiesScreen
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Food Allergy Scanner'), // Title of the app bar
      ),
      body: Consumer<AllergyProvider>(
        builder: (context, allergyProvider, child) {
          bool hasAllergies = allergyProvider.allergies.isNotEmpty;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Scan a product to check for allergens!', // Instruction text
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
                  child: Text('Scan Product'), // Button text
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => manageAllergies(context), // Floating action button to manage allergies
        tooltip: 'Manage Allergies', // Tooltip text
        child: Icon(Icons.edit), // Icon for editing allergies
      ),
    );
  }
}
