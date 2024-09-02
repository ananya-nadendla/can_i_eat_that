import 'package:flutter/material.dart';

class ProcessingDialog extends StatelessWidget {
  final Color progressColor; // Progress indicator color

  ProcessingDialog({this.progressColor = const Color.fromARGB(255, 101, 156, 103)}); // Progress indicator color

  @override
  Widget build(BuildContext context) {
    // Popup dialog for processing image
    return Dialog(
      backgroundColor: Theme.of(context).dialogTheme.backgroundColor, // Dialog background color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content without taking up full height
          children: [
            // Title text for the dialog
            Text(
              'Scanning Photo',
              style: Theme.of(context).dialogTheme.titleTextStyle, // Uses the dialog title text style from theme
            ),
            const SizedBox(height: 20), // Spacer to separate title and progress indicator
            CircularProgressIndicator( // Circular progress indicator
              valueColor: AlwaysStoppedAnimation<Color>(progressColor), // Set the color for the progress indicator
            ),
            const SizedBox(height: 20),
            Text(
              'Please wait while we process the photo.', //Message
              style: Theme.of(context).dialogTheme.contentTextStyle, // Uses the dialog content text style from theme
            ),
          ],
        ),
      ),
    );
  }
}
