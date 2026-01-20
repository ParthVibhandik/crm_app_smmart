import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Prefer camera plugin to force front camera; fall back to image_picker if needed
  Future<XFile?> takeSelfie({
    required BuildContext context,
    int imageQuality = 80,
  }) async {
    try {
      print('CameraService: Starting selfie capture with camera plugin...');
      return await _captureWithCameraPlugin(
        context: context,
      );
    } catch (e) {
      print(
          'CameraService: Camera plugin failed ($e), trying image_picker fallback');
      return await _fallbackPickImage(imageQuality: imageQuality);
    }
  }

  Future<XFile?> _captureWithCameraPlugin({
    required BuildContext context,
  }) async {
    final cameras = await availableCameras();
    final frontCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => throw Exception('No front camera available'),
    );

    return Navigator.of(context).push<XFile?>(
      MaterialPageRoute(
        builder: (_) => _FrontCameraCapturePage(camera: frontCamera),
        fullscreenDialog: true,
      ),
    );
  }

  /// Take a photo from gallery as fallback option
  Future<XFile?> pickFromGallery({
    int maxWidth = 600,
    int imageQuality = 80,
  }) async {
    try {
      print('CameraService: Opening photo gallery...');

      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth.toDouble(),
        imageQuality: imageQuality,
      );

      if (photo == null) {
        print('CameraService: User cancelled gallery picker');
        return null;
      }

      print('CameraService: Photo selected from gallery: ${photo.path}');
      return photo;
    } on PlatformException catch (e) {
      print(
          'CameraService: Error picking from gallery: ${e.code} - ${e.message}');
      throw Exception(
          'Gallery error: ${e.message ?? 'Failed to access photo library'}');
    } catch (e) {
      print('CameraService: Unexpected gallery error: $e');
      throw Exception('Failed to select photo: $e');
    }
  }

  /// Show option dialog for camera or gallery (for fallback scenarios)
  Future<XFile?> pickImageWithOptions({
    required BuildContext context,
    int imageQuality = 80,
  }) async {
    try {
      final cameraPhoto = await takeSelfie(
        context: context,
        imageQuality: imageQuality,
      );

      if (cameraPhoto != null) {
        return cameraPhoto;
      }

      print(
          'CameraService: Camera failed or cancelled, offering gallery fallback...');
      return await _fallbackPickImage(imageQuality: imageQuality);
    } catch (e) {
      print('CameraService: Error in pickImageWithOptions: $e');
      throw Exception('Failed to capture or select image: $e');
    }
  }

  Future<XFile?> _fallbackPickImage({
    int maxWidth = 600,
    int imageQuality = 80,
  }) async {
    final XFile? photo = await _picker.pickImage(
      source: ImageSource.camera,
      preferredCameraDevice: CameraDevice.front,
      maxWidth: maxWidth.toDouble(),
      imageQuality: imageQuality,
    );

    if (photo == null) {
      print('CameraService: User cancelled camera');
      return null;
    }

    final file = File(photo.path);
    if (!await file.exists()) {
      throw Exception('Captured photo file does not exist');
    }

    final fileSize = await file.length();
    if (fileSize == 0) {
      throw Exception('Captured photo file is empty');
    }

    print('CameraService: Photo file size: $fileSize bytes');
    return photo;
  }
}

class _FrontCameraCapturePage extends StatefulWidget {
  const _FrontCameraCapturePage({
    required this.camera,
  });

  final CameraDescription camera;

  @override
  State<_FrontCameraCapturePage> createState() =>
      _FrontCameraCapturePageState();
}

class _FrontCameraCapturePageState extends State<_FrontCameraCapturePage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    _initializeControllerFuture = _controller.initialize();
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
        title: const Text('Capture Selfie'),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).maybePop(),
          ),
        ],
      ),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          return Stack(
            children: [
              Positioned.fill(child: CameraPreview(_controller)),
              Positioned(
                bottom: 32,
                left: 0,
                right: 0,
                child: Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.camera_front),
                    label:
                        Text(_capturing ? 'Capturing...' : 'Use Front Camera'),
                    onPressed: _capturing ? null : _capture,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _capture() async {
    setState(() => _capturing = true);
    try {
      await _initializeControllerFuture;
      await _controller.setFlashMode(FlashMode.off);
      final XFile file = await _controller.takePicture();
      Navigator.of(context).pop(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to capture photo: $e')),
      );
    } finally {
      if (mounted) setState(() => _capturing = false);
    }
  }
}
