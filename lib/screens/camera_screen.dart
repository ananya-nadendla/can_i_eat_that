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
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
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

      _controller = CameraController(
        _selectedCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

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
              openAppSettings();
            },
            child: const Text('Settings'),
          ),
          TextButton(
            onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => HomeScreen()), //when user hits "Ok", send back to HomeScreen
                (route) => false,
              );
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _captureImage() async {
    if (_controller != null) {
      try {
        await _initializeControllerFuture;
        final image = await _controller!.takePicture();
        setState(() {
          _capturedImage = File(image.path);
        });
      } catch (e) {
        print(e);
      }
    }
  }

  void _resetCamera() {
    setState(() {
      _capturedImage = null;
    });
  }

  void _cancelCameraCapture() {
    Navigator.of(context).pop(null); // Return null to indicate cancellation
  }

  @override
  Widget build(BuildContext context) {
    // Fetch screen dimensions
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Define dynamic sizes based on screen dimensions
    final buttonSize = screenWidth * 0.15; // 15% of screen width
    final buttonSpacing = screenWidth * 0.1; // 10% of screen width
    final bottomPadding = screenHeight * 0.05; // 5% of screen height
    
    if (_permissionDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCameraPermissionDeniedDialog();
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture Photo'),
      ),
      body: Column(
        children: [
          // Camera Preview Section
          Expanded(
            child: Stack(
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      if (_controller != null && _controller!.value.isInitialized) {
                        return _capturedImage == null
                            ? CameraPreview(_controller!)
                            : Image.file(_capturedImage!);
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
                
                // Camera Buttons Section
                if (_capturedImage == null)
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: _captureImage,
                          child: Container(
                            width: buttonSize,
                            height: buttonSize,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(width: buttonSize * 0.07, color: Colors.black), // 7% of button size
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Positioned(
                    bottom: bottomPadding,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.red),
                          iconSize: buttonSize,
                          onPressed: _cancelCameraCapture, // Return null instead of navigating to HomeScreen
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: Colors.blue),
                          iconSize: buttonSize,
                          onPressed: _resetCamera,
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.green),
                          iconSize: buttonSize,
                          onPressed: () {
                            Navigator.of(context).pop(_capturedImage); // Return the captured image
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          
          // Camera Message Section
          Padding(
            padding: EdgeInsets.symmetric(vertical: screenHeight * 0.02), // 2% of screen height
            child: const Text(
              'Take a photo of an ingredients label. \n Up Next: Crop your photo',
              style: TextStyle(color: Colors.black),
              softWrap: true,
              overflow: TextOverflow.visible,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
