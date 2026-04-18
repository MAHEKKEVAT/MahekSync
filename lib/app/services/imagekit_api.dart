// lib/app/services/imagekit_api.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:maheksync/app/constant/constants.dart';

class ImageKitAPI {
  static const String _privateKey = 'private_u6KRAwruwE6w8xR63Vl7enrhpzk=';
  static const String _publicKey = 'public_AeErSlpNO37JZd9nLBeyqH1SPS8=';
  static const String _urlEndpoint = 'https://upload.imagekit.io/api/v1/files/upload';
  static const String _baseUrl = 'https://ik.imagekit.io/fsp5dxfxe';

  static final ImagePicker _picker = ImagePicker();

  // Pick single image
  static Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  // Pick multiple images
  static Future<List<XFile>?> pickMultipleImages() async {
    try {
      return await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );
    } catch (e) {
      print('Error picking images: $e');
      return null;
    }
  }

  // Upload image to ImageKit
  static Future<String?> uploadImage({
    required XFile imageFile,
    required String folderName,
    String? customFileName,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final fileName = customFileName ??
          '${MahekConstant.getUuid()}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final fullPath = '$folderName/$fileName';

      final response = await http.post(
        Uri.parse(_urlEndpoint),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64Image,
          'fileName': fullPath,
          'useUniqueFileName': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      print('ImageKit upload failed: ${response.body}');
      return null;
    } catch (e) {
      print('ImageKit upload error: $e');
      return null;
    }
  }

  // Upload multiple images
  static Future<List<String>> uploadMultipleImages({
    required List<XFile> imageFiles,
    required String folderName,
  }) async {
    List<String> uploadedUrls = [];

    for (var imageFile in imageFiles) {
      final url = await uploadImage(
        imageFile: imageFile,
        folderName: folderName,
      );
      if (url != null) {
        uploadedUrls.add(url);
      }
    }

    return uploadedUrls;
  }

  // Store image for web (bytes)
  static Future<String?> uploadImageBytes({
    required Uint8List imageBytes,
    required String folderName,
    required String fileName,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final fullPath = '$folderName/$fileName';

      final response = await http.post(
        Uri.parse(_urlEndpoint),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64Image,
          'fileName': fullPath,
          'useUniqueFileName': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('ImageKit bytes upload error: $e');
      return null;
    }
  }

  // Delete image from ImageKit (optional)
  static Future<bool> deleteImage(String fileId) async {
    try {
      final response = await http.delete(
        Uri.parse('https://api.imagekit.io/v1/files/$fileId'),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}