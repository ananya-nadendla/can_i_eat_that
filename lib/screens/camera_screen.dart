import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:food_allergy_scanner/screens/home_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late Future<void> _initializeControllerFuture;
  late CameraDescription _selectedCamera;
  bool _permissionDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Request camera permission only
    final permissionStatus = await Permission.camera.request();

    if (!permissionStatus.isGranted) {
      setState(() {
        _permissionDenied = true;
      });
      return;
    }

    try {
      final cameras = await availableCameras();
      _selectedCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _controller = CameraController(_selectedCamera, ResolutionPreset.max, enableAudio: false);

      await _controller!.initialize();
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _showCameraPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Center(child: Text('Camera Permission Denied')),
        content: const Text(
          'The camera permission is required to use this feature. Please enable it in your device settings.',
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () {
              openAppSettings(); // Opens app settings
            },
            child: const Text('Settings'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()),
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCameraPermissionDeniedDialog();
      });
    }

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
              if (_controller != null) {
                try {
                  await _initializeControllerFuture;
                  final image = await _controller!.takePicture();
                  Navigator.of(context).pop(File(image.path)); // Return the captured image
                } catch (e) {
                  print(e);
                }
              } else {
                print('Camera controller is not initialized');
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
            if (_controller != null && _controller!.value.isInitialized) {
              return CameraPreview(_controller!);
            } else {
              return const Center(child: Text('Camera not initialized'));
            }
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16.0),
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
