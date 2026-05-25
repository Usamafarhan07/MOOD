import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';

class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List?> pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
    );
    if (pickedFile != null) {
      return await pickedFile.readAsBytes();
    }
    return null;
  }

  Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    try {
      final result = await FlutterImageCompress.compressWithList(
        imageBytes,
        minWidth: 600,
        minHeight: 600,
        quality: 70,
        format: CompressFormat.jpeg,
      );
      return result;
    } catch (e) {
      // Fallback if compression fails (e.g., unsupported platform like Windows)
      return imageBytes;
    }
  }

  String convertToBase64(Uint8List bytes) {
    return base64Encode(bytes);
  }
}
