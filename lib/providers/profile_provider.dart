import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mood/services/firestore_service.dart';
import 'package:mood/services/image_service.dart';

class ProfileProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  final ImageService _imageService = ImageService();

  bool _isUploading = false;
  bool get isUploading => _isUploading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> uploadProfileImage(ImageSource source) async {
    _setUploading(true);
    _errorMessage = null;

    try {
      final Uint8List? imageBytes = await _imageService.pickImage(source);
      if (imageBytes == null) {
        _setUploading(false);
        return;
      }

      final compressedBytes = await _imageService.compressImage(imageBytes);
      if (compressedBytes == null) {
        throw Exception('Image compression failed');
      }

      final base64String = _imageService.convertToBase64(compressedBytes);
      
      // Upload to Firestore
      await _firestoreService.uploadProfileImageBase64(base64String);
      
      // Success, notify UI to reload or update
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _setUploading(false);
    }
  }

  void _setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      notifyListeners();
    }
  }
}
