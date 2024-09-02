import 'package:flutter/material.dart';

class ValidationLoadingDialog extends StatelessWidget {
  final int totalIngredients; // Total number of ingredients to be validated
  final Stream<int> progressStream; // Stream to track progress of the validation process
  final Color progressColor; // Add a parameter for the progress indicator color
  final Color backgroundColor; // Background color of the progress bar

  ValidationLoadingDialog({
    required this.totalIngredients,
    required this.progressStream,
    this.progressColor = const Color.fromARGB(255, 90, 6, 100), // progress bar (moving part) color
    this.backgroundColor = const Color.fromARGB(255, 218, 205, 180), // progress bar background color
    
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // Use the dialog background color from theme
      child: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the dialog content
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content vertically to minimum space needed
          children: [
            // Title text for the dialog
            Text(
              'Analyzing Ingredients',
              style: Theme.of(context).dialogTheme.titleTextStyle, // Uses the dialog title text style from theme
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
                    LinearProgressIndicator( 
                      value: progress / totalIngredients,
                      valueColor: AlwaysStoppedAnimation<Color>(progressColor), // Progress indicator color
                      backgroundColor: backgroundColor, // Progress indicator background color
                    ),
                    const SizedBox(height: 10), //Spacer
                    Text(
                      '$progress / $totalIngredients', // Text showing progress count
                      style: Theme.of(context).dialogTheme.contentTextStyle, // Uses the dialog content text style from theme
                    ),
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
