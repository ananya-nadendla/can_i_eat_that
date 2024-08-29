import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

class CropScreen extends StatefulWidget {
  final File imageFile;
  final CropController cropController;

  CropScreen({
    required this.imageFile,
    required this.cropController,
  });

  @override
  _CropScreenState createState() => _CropScreenState();
}

class _CropScreenState extends State<CropScreen> {
  late CropController _cropController;
  bool _isCropping = false; // Add a flag to track if cropping is in progress

  @override
  void initState() {
    super.initState();
    _cropController = widget.cropController;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle the back navigation
        return false; // Returning false disables the back navigation
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crop Photo'),
          automaticallyImplyLeading: false, // Remove the back arrow
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Indicate cropping was canceled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: _isCropping
                  ? null // Disable button while cropping is in progress (to avoid double tap)
                  : () {
                      setState(() {
                        _isCropping = true; // Set flag to true
                      });
                      _cropController.crop(); // Trigger cropping
                    },
              child: const Text('Continue'),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Add padding to avoid the edges - prevents back gesture on some phones
                child: Crop(
                  image: File(widget.imageFile.path).readAsBytesSync(),
                  controller: _cropController,
                  onCropped: (croppedData) {
                    Navigator.of(context).pop(croppedData); // Return the cropped data
                  },
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Crop the image to include only the ingredients you wish to scan.',
                style: TextStyle(color: Colors.black),
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
