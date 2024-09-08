import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:can_i_eat_that/utils/utils.dart';

class CropScreen extends StatefulWidget {
  final File imageFile;
  final CropController cropController;

  CropScreen({
    required this.imageFile, // The image file to be cropped
    required this.cropController, // Controller for the cropper
  });

  @override
  _CropScreenState createState() => _CropScreenState();
}

// State class for CropScreen
class _CropScreenState extends State<CropScreen> {
  late CropController _cropController; // Controller instance for handling cropping operations
  bool _isCropping = false; // Flag to indicate if cropping is in progress
  bool _isImageLoaded = false; // Flag to indicate if the image has been loaded

  @override
  void initState() {
    super.initState();
    _cropController = widget.cropController; // Initialize the crop controller
  }

  // Indicate cropping was canceled
  void _cancelCrop() {
    Navigator.of(context).pop(false);
    widget.imageFile.deleteSync(); // Delete image file 
  }

  // Start cropping process
  void _startCropping() {
    setState(() {
      _isCropping = true; // Set cropping flag to true
    });
    _cropController.crop(); // Trigger the crop method
    LoggerUtil.logger.d('Cropper triggered!');
    
  }

  @override
  Widget build(BuildContext context) {
    // Fetch screen dimensions
    final screenHeight = MediaQuery.of(context).size.height; // Get screen height
    final bottomPadding = screenHeight * 0.05; // 5% of screen height

    return PopScope(
      canPop: false, // Prevent back navigation
      child: Scaffold(
        appBar: AppBar(
          title: const Center( //Center title
            child: Text('Crop Photo'),
          ),
          automaticallyImplyLeading: false, // Remove the default back arrow
        ),
        body: Stack(
          // Use a stack to overlay widgets
          children: [
            Column(
              children: [
                Expanded(
                  // Expands cropper widget to fill available space
                  child: Padding(
                    padding: const EdgeInsets.all(16.0), // Add padding around cropper widget to avoid the edges - prevents back gesture on some phones
                    child: Crop(
                      // Crop widget from crop_your_image package
                      image: File(widget.imageFile.path).readAsBytesSync(), // Load image data
                      controller: _cropController, // Assign crop controller
                      onCropped: (croppedData) {
                        // Callback after cropping is done
                        Navigator.of(context)
                            .pop(croppedData); // Return the cropped data
                      },
                      onStatusChanged: (status) { 
                        if (status == CropStatus.ready) { //Check if cropper has loaded in / is ready
                          setState(() {
                            _isImageLoaded = true; // Image is ready for cropping (Crop button now enabled)
                          });
                        }
                      },
                    ),
                  ),
                ),

                // Cropper Buttons Section
                Padding(
                  padding: EdgeInsets.only(
                      bottom: bottomPadding), // Padding for the button section
                  child: Row(
                    // Row layout for buttons
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly, // Space buttons evenly
                    children: [
                      // Cancel button
                      TextButton(
                        onPressed: _isCropping
                            ? null
                            : _cancelCrop, // Disable button while cropping is in progress
                        child: const Text('Cancel'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.red, // Background color
                          textStyle: const TextStyle(fontSize: 18),
                        ),
                      ),
                      // Crop button
                      TextButton(
                        onPressed: _isCropping || !_isImageLoaded
                            ? null
                            : _startCropping, // Disable button while (1) cropping is in progress or (2) cropper/image didnt load in yet
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

                Align(
                  alignment: Alignment.bottomCenter, // Center the text at the bottom
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // Vertical Padding - 2% of screen height
                    child: const Text(
                      'Crop the image to include only the ingredients you wish to scan.', // Message
                      style: TextStyle(
                        color: Color.fromARGB(255, 90, 6, 100), // Text color
                        fontWeight: FontWeight.bold, 
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      textAlign: TextAlign.center,
                    ),

                  ),
                ),
              ],
            ),

            // Cropping Progress Indicator
            if (_isCropping) // Show only if cropping is in progress
              Container(
                color: Colors.black.withOpacity(0.5), // Tinted background
                child: const Center(
                  child:
                      CircularProgressIndicator(), // Circular progress indicator
                ),
              ),
          ],
        ),
      ),
    );
  }
}
