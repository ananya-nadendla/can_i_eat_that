import 'package:flutter/material.dart';

class ProcessingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Popup dialog for processing image
    return const Dialog(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Wrap content without taking up full height
          children: [
            // Title text for the dialog
            Text(
              'Scanning Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20), // Spacer to separate title and progress indicator
            CircularProgressIndicator(), // Circular progress indicator
            SizedBox(height: 20), // Spacer to separate progress indicator and message
            Text('Please wait while we process the photo.'), //Message
          ],
        ),
      ),
    );
  }
}
