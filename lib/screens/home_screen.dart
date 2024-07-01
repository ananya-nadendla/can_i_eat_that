import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:food_allergy_scanner/providers/allergy_provider.dart';
import 'package:food_allergy_scanner/screens/manage_allergies_screen.dart';

class HomeScreen extends StatelessWidget {
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
        print("Read: '${line.text}'"); //debugging - prints recognized image-to-text from ingredients list
      }
    }

    AllergyProvider allergyProvider = Provider.of<AllergyProvider>(context, listen: false);
    List<String> allergies = allergyProvider.allergies;

    // Check if any allergen matches with the recognized text as a whole word
    bool isSafe = true;
    for (String allergy in allergies) {
      RegExp regex = RegExp(r"\b" + RegExp.escape(allergy) + r"\b", caseSensitive: false);
      if (regex.hasMatch(recognizedText.text)) {
        print('MATCH FOUND: "$allergy"'); //debugging - prints match between ingredients & allergen
        isSafe = false;
        break;
      }
    }

    textRecognizer.close();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Scan Result'),
        content: Text(isSafe ? 'The product is safe to eat!' : 'The product contains allergens!'),
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

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            
            Text(
              'Scan a product to check for allergens!',
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => scanProduct(context),
              child: Text('Scan Product'),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () => manageAllergies(context),
        tooltip: 'Manage Allergies',
        child: Icon(Icons.edit),
      ),
      
    );
  }
}
