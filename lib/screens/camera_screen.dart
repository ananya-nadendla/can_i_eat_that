import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _selectedCamera;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get the list of available cameras
    final cameras = await availableCameras();

    // Find the back camera
    _selectedCamera = cameras.firstWhere(
      (camera) => camera.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    // Initialize the camera controller
    _controller = CameraController(_selectedCamera, ResolutionPreset.max);
    return _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Photo'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Cancel image capture
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await _initializeControllerFuture;
                final image = await _controller.takePicture();
                Navigator.of(context)
                    .pop(File(image.path)); // Return the captured image
              } catch (e) {
                print(e);
              }
            },
            child: const Text('Capture'),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16.0), //issue
        child: Text(
          'Take a photo of an ingredients label. \n Up Next: Crop your photo',
          style: TextStyle(color: Colors.black),
          softWrap: true,
          overflow: TextOverflow.visible,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
