import 'dart:convert';
import 'dart:js_interop';
import 'dart:typed_data';

@JS('ocrImageBase64')
external JSPromise<JSString> _ocrImageBase64(JSString base64, JSString lang, JSString mimeType);

@JS('ocrPdfPageCount')
external JSPromise<JSNumber> _ocrPdfPageCount(JSString base64);

@JS('ocrRenderPdfPage')
external JSPromise<JSString> _ocrRenderPdfPage(JSString base64, JSNumber pageNum);

class OcrService {
  static String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'png':
        return 'image/png';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'webp':
        return 'image/webp';
      case 'bmp':
        return 'image/bmp';
      case 'tiff':
      case 'tif':
        return 'image/tiff';
      case 'gif':
        return 'image/gif';
      default:
        return 'image/png';
    }
  }

  static Future<String> recognizeImage(Uint8List imageBytes, {String language = 'eng', String extension = 'png'}) async {
    final base64Str = base64Encode(imageBytes);
    final mimeType = _getMimeType(extension);
    final result = await _ocrImageBase64(base64Str.toJS, language.toJS, mimeType.toJS).toDart;
    return result.toDart;
  }

  static Future<int> getPdfPageCount(Uint8List pdfBytes) async {
    final base64Str = base64Encode(pdfBytes);
    final result = await _ocrPdfPageCount(base64Str.toJS).toDart;
    return result.dartify() as int;
  }

  static Future<String> recognizePdfPage(Uint8List pdfBytes, int pageNum, {String language = 'eng'}) async {
    final base64Str = base64Encode(pdfBytes);
    final pageBase64 = await _ocrRenderPdfPage(base64Str.toJS, pageNum.toJS).toDart;
    final pageBase64Str = pageBase64.toDart;
    final textResult = await _ocrImageBase64(pageBase64Str.toJS, language.toJS, 'image/png'.toJS).toDart;
    return textResult.toDart;
  }
}
