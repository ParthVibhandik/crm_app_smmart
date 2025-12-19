import 'dart:io';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class CameraService {
  final ImagePicker _picker = ImagePicker();

  /// Take a selfie photo with enhanced error handling
  Future<XFile?> takeSelfie({
    int maxWidth = 600,
    int imageQuality = 80,
  }) async {
    try {
      print('CameraService: Starting selfie capture...');

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

      print('CameraService: Selfie captured successfully: ${photo.path}');
      
      // Verify the file exists and has content
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

    } on PlatformException catch (e) {
      print('CameraService: Platform exception during selfie capture: ${e.code} - ${e.message}');
      
      switch (e.code) {
        case 'camera_access_denied':
          throw Exception('Camera access was denied. Please enable camera permissions in Settings.');
        case 'photo_access_denied':
          throw Exception('Photo library access was denied. Please enable photo permissions in Settings.');
        case 'invalid_image':
          throw Exception('The captured image is invalid. Please try again.');
        default:
          throw Exception('Camera error: ${e.message ?? 'Unknown error occurred'}');
      }
    } catch (e) {
      print('CameraService: Unexpected error during selfie capture: $e');
      if (e is Exception) {
        rethrow;
      } else {
        throw Exception('Failed to capture selfie: $e');
      }
    }
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
      print('CameraService: Error picking from gallery: ${e.code} - ${e.message}');
      throw Exception('Gallery error: ${e.message ?? 'Failed to access photo library'}');
    } catch (e) {
      print('CameraService: Unexpected gallery error: $e');
      throw Exception('Failed to select photo: $e');
    }
  }

  /// Show option dialog for camera or gallery (for fallback scenarios)
  Future<XFile?> pickImageWithOptions({
    int maxWidth = 600,
    int imageQuality = 80,
  }) async {
    try {
      // Try camera first (preferred for attendance)
      final cameraPhoto = await takeSelfie(
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );
      
      if (cameraPhoto != null) {
        return cameraPhoto;
      }

      // If camera failed or was cancelled, offer gallery as fallback
      print('CameraService: Camera failed or cancelled, offering gallery fallback...');
      return await pickFromGallery(
        maxWidth: maxWidth,
        imageQuality: imageQuality,
      );

    } catch (e) {
      print('CameraService: Error in pickImageWithOptions: $e');
      throw Exception('Failed to capture or select image: $e');
    }
  }
}