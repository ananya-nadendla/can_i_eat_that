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

  @override
  void initState() {
    super.initState();
    _cropController = widget.cropController;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Indicate cropping was canceled
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _cropController.crop(); // Trigger cropping
            },
            child: const Text('Continue'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Crop(
              image: File(widget.imageFile.path).readAsBytesSync(),
              controller: _cropController,
              onCropped: (croppedData) {
                Navigator.of(context).pop(croppedData); // Return the cropped data
              },
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
    );
  }
}
