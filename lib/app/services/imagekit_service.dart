// lib/app/services/imagekit_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ImageKitService {
  static const String _privateKey = 'private_u6KRAwruwE6w8xR63Vl7enrhpzk=';
  static const String _publicKey = 'public_AeErSlpNO37JZd9nLBeyqH1SPS8=';
  static const String _urlEndpoint = 'https://ik.imagekit.io/fsp5dxfxe';

  static final ImagePicker _picker = ImagePicker();

  static Future<String?> uploadDeviceImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final fileName = 'my_devices/${const Uuid().v4()}_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final response = await http.post(
        Uri.parse(_urlEndpoint),
        headers: {
          'Authorization': 'Basic ${base64Encode(utf8.encode('$_privateKey:'))}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'file': base64Image,
          'fileName': fileName,
          'folder': '/my_devices',
          'useUniqueFileName': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['url'];
      }
      return null;
    } catch (e) {
      print('ImageKit upload error: $e');
      return null;
    }
  }

  static Future<XFile?> pickImage() async {
    try {
      return await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1200,
      );
    } catch (e) {
      return null;
    }
  }
}