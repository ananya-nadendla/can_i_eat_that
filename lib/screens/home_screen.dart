import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
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

    // Print each block of recognized text to the console
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        print("Read: '${line.text}'"); // Debugging - prints recognized image-to-text from ingredients list
      }
    }

    // Access the allergy provider and existing allergies list
    AllergyProvider allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
    List<String> allergies = allergyProvider.allergies;
    List<String> matchingAllergens = [];

    // Check if any allergen matches with the recognized text as a whole word
    bool isSafe = true;
    for (String allergy in allergies) {
      RegExp regex = RegExp(r"\b" + RegExp.escape(allergy) + r"\b", caseSensitive: false);
      if (regex.hasMatch(recognizedText.text)) {
        print('MATCH FOUND: "$allergy"'); // Debugging - prints match between ingredients & allergen
        isSafe = false;
        matchingAllergens.add(allergy); // Add matching allergen to the list
      }
    }

    textRecognizer.close(); // Close the text recognizer

    // Show dialog with scan result
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Result'), // Title of the dialog
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(isSafe ? 'The product is safe to eat!' : 'The product contains allergens!'), // Show result message
            if (!isSafe)
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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Scan a product to check for allergens!', // Instruction text
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => scanProduct(context), // Button to initiate product scanning
              child: Text('Scan Product'), // Button text
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => manageAllergies(context), // Floating action button to manage allergies
        tooltip: 'Manage Allergies', // Tooltip text
        child: Icon(Icons.edit), // Icon for editing allergies
      ),
    );
  }
}
