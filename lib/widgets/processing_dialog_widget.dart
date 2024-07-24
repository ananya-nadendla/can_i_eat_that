import 'package:flutter/material.dart';
import 'package:flutter/material.dart';

class ProcessingDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Processing Image',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(), // Circular progress indicator
            SizedBox(height: 20),
            Text('Please wait while we process the image.'),
          ],
        ),
      ),
    );
  }
}
