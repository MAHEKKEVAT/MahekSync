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
  static const String _uploadEndpoint = 'https://upload.imagekit.io/api/v1/files/upload';

  static final ImagePicker _picker = ImagePicker();

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

  static Future<List<XFile>> pickMultipleImages() async {
    try {
      final images = await _picker.pickMultiImage(
        imageQuality: 85,
        maxWidth: 1200,
      );
      return images;
    } catch (e) {
      print('Error picking images: $e');
      return [];
    }
  }

  static Future<String?> uploadImage({
    required XFile imageFile,
    required String folderName,
  }) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final fileName = '${MahekConstant.getUuid()}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final fullPath = '/$folderName/$fileName';

      // Create multipart request for proper authentication
      final uri = Uri.parse(_uploadEndpoint);
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}';

      // Add fields
      request.fields['fileName'] = fullPath;
      request.fields['folder'] = '/$folderName';
      request.fields['useUniqueFileName'] = 'false';
      request.fields['publicKey'] = _publicKey;

      // Add file
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['url'];
      } else {
        print('ImageKit upload failed: $responseBody');
        return null;
      }
    } catch (e) {
      print('ImageKit upload error: $e');
      return null;
    }
  }

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

  static Future<String?> uploadImageBytes({
    required Uint8List imageBytes,
    required String folderName,
    required String fileName,
  }) async {
    try {
      final base64Image = base64Encode(imageBytes);
      final fullPath = '/$folderName/$fileName';

      final uri = Uri.parse(_uploadEndpoint);
      final request = http.MultipartRequest('POST', uri);

      request.headers['Authorization'] = 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}';
      request.fields['fileName'] = fullPath;
      request.fields['folder'] = '/$folderName';
      request.fields['useUniqueFileName'] = 'false';

      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: fileName,
        ),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('ImageKit bytes upload error: $e');
      return null;
    }
  }
}