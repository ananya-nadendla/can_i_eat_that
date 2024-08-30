import 'package:flutter/material.dart';

class ValidationLoadingDialog extends StatelessWidget {
  final int totalIngredients; // Total number of ingredients to be validated
  final Stream<int> progressStream; // Stream to track progress of the validation process

  ValidationLoadingDialog(
      {required this.totalIngredients, required this.progressStream}); 

  @override
  Widget build(BuildContext context) {
    //Modal dialog widget
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the dialog content
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically to minimum space needed
          children: [
            // Title text for the dialog
            const Text(
              'Analyzing Ingredients',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20), // Spacer to add some vertical space

            // StreamBuilder to listen to progressStream and rebuild the UI accordingly
            StreamBuilder<int>(
              stream: progressStream, // Stream of progress updates
              initialData: 0, // Initial progress value
              builder: (context, snapshot) {
                int progress = snapshot.data!; // Get current progress value from stream
                return Column(
                  children: [
                    // Linear progress bar 
                    LinearProgressIndicator(value: progress / totalIngredients),
                    const SizedBox(height: 10), //Spacer
                    Text('$progress / $totalIngredients'),  // Text showing progress count
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
