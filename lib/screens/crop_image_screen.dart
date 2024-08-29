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
  bool _isCropping = false;

  @override
  void initState() {
    super.initState();
    _cropController = widget.cropController;
  }

  void _cancelCrop() {
    Navigator.of(context).pop(false); // Indicate cropping was canceled
  }

  void _startCropping() {
    setState(() {
      _isCropping = true;
    });
    _cropController.crop();
  }

  @override
  Widget build(BuildContext context) {
    // Fetch screen dimensions
    final screenHeight = MediaQuery.of(context).size.height;
    final bottomPadding = screenHeight * 0.05; // 5% of screen height

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Crop Photo'),
          automaticallyImplyLeading: false, // Remove the back arrow
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding around cropper widget to avoid the edges - prevents back gesture on some phones
                    child: Crop(
                      image: File(widget.imageFile.path).readAsBytesSync(),
                      controller: _cropController,
                      onCropped: (croppedData) {
                        Navigator.of(context).pop(croppedData); // Return the cropped data
                      },
                    ),
                  ),
                ),
                
                // Cropper Buttons Section with Text Only
                Padding(
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: _isCropping ? null : _cancelCrop, // Disable button while cropping is in progress
                        child: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red, // Background color
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                      TextButton(
                        onPressed: _isCropping ? null : _startCropping, // Disable button while cropping is in progress
                        child: const Text('Crop'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green, // Background color
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Cropping Message Section
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Crop the image to include only the ingredients you wish to scan.',
                    style: TextStyle(color: Colors.black),
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            
            // Cropping Progress Indicator
            if (_isCropping)
              Container(
                color: Colors.black.withOpacity(0.5), // Tinted background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
