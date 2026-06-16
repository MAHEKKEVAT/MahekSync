import 'dart:js_interop';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/show_toast.dart';
import '../services/ocr_service.dart';

@JS('downloadTextFile')
external void _downloadTextFile(JSString filename, JSString content);

class ImageToTextController extends GetxController {
  final selectedFileName = ''.obs;
  final selectedFileBytes = Rxn<Uint8List>();
  final selectedFileType = ''.obs;
  final extractedText = ''.obs;
  final isProcessing = false.obs;
  final processingMessage = ''.obs;
  final selectedLanguage = 'eng'.obs;
  final pdfPageCount = 0.obs;
  final currentPdfPage = 0.obs;
  final pageTexts = <String>[].obs;

  bool _isCancelled = false;

  final Map<String, String> languages = {
    'eng': 'English',
    'hin': 'Hindi',
    'mar': 'Marathi',
    'ben': 'Bengali',
    'tam': 'Tamil',
    'tel': 'Telugu',
    'kan': 'Kannada',
    'guj': 'Gujarati',
    'pan': 'Punjabi',
    'urd': 'Urdu',
  };

  bool get hasFile => selectedFileBytes.value != null;
  bool get hasResult => extractedText.value.isNotEmpty;
  bool get isPdf {
    if (selectedFileType.value == 'pdf') return true;
    final bytes = selectedFileBytes.value;
    if (bytes == null || bytes.length < 4) return false;
    // Check for %PDF magic header
    return bytes[0] == 0x25 && bytes[1] == 0x50 && bytes[2] == 0x44 && bytes[3] == 0x46;
  }

  String get fullDisplayText {
    if (!isPdf || pageTexts.isEmpty) return extractedText.value;
    final buffer = StringBuffer();
    for (int i = 0; i < pageTexts.length; i++) {
      if (i > 0) buffer.writeln('\n${'—' * 40}\n');
      buffer.writeln('--- Page ${i + 1} ---\n');
      buffer.writeln(pageTexts[i]);
    }
    return buffer.toString();
  }

  Future<void> pickFile() async {
    try {
      extractedText.value = '';
      pageTexts.clear();
      pdfPageCount.value = 0;
      currentPdfPage.value = 0;

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'png', 'jpg', 'jpeg', 'webp', 'bmp', 'tiff', 'tif', 'gif', 'pdf'
        ],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;
      if (file.bytes == null) {
        ShowToastDialog.showError('Failed to read file');
        return;
      }

      selectedFileName.value = file.name;
      selectedFileBytes.value = file.bytes;
      selectedFileType.value = file.extension?.toLowerCase() ?? '';

      await processFile();
    } catch (e) {
      ShowToastDialog.showError('Error picking file: $e');
    }
  }

  Future<void> processFile() async {
    if (!hasFile) return;

    _isCancelled = false;
    isProcessing.value = true;
    processingMessage.value = 'Initializing OCR...';
    extractedText.value = '';
    pageTexts.clear();

    try {
      if (isPdf) {
        await _processPdf();
      } else {
        await _processImage();
      }
    } catch (e) {
      if (_isCancelled) return;
      // If PDF processing fails, retry as image
      if (e.toString().contains('InvalidPDF') && !isPdf) {
        try {
          await _processImage();
          return;
        } catch (e2) {
          ShowToastDialog.showError('OCR failed: $e2');
          return;
        }
      }
      final msg = e.toString().contains('Failed to fetch')
          ? 'Failed to fetch — check your internet connection or try again'
          : 'OCR failed: $e';
      ShowToastDialog.showError(msg);
    } finally {
      if (!_isCancelled) {
        isProcessing.value = false;
        processingMessage.value = '';
      }
    }
  }

  Future<void> _processImage() async {
    processingMessage.value = 'Extracting text...';
    final text = await OcrService.recognizeImage(
      selectedFileBytes.value!,
      language: selectedLanguage.value,
      extension: selectedFileType.value,
    );
    if (_isCancelled) return;
    extractedText.value = text.trim();
  }

  Future<void> _processPdf() async {
    processingMessage.value = 'Reading PDF...';
    final count = await OcrService.getPdfPageCount(selectedFileBytes.value!);
    if (_isCancelled) return;
    pdfPageCount.value = count;

    final texts = <String>[];
    for (int i = 1; i <= count; i++) {
      if (_isCancelled) break;
      currentPdfPage.value = i;
      processingMessage.value = 'Processing page $i of $count...';
      final text = await OcrService.recognizePdfPage(
        selectedFileBytes.value!,
        i,
        language: selectedLanguage.value,
      );
      if (_isCancelled) break;
      texts.add(text.trim());
    }

    if (_isCancelled) return;
    pageTexts.value = texts;
    extractedText.value = fullDisplayText;
  }

  void cancelProcessing() {
    _isCancelled = true;
    isProcessing.value = false;
    processingMessage.value = '';
    if (extractedText.value.isEmpty && pageTexts.isEmpty) {
      ShowToastDialog.showSuccess('Processing cancelled');
    } else {
      ShowToastDialog.showSuccess('Cancelled — partial results kept');
    }
  }

  void setLanguage(String lang) {
    if (selectedLanguage.value == lang) return;
    selectedLanguage.value = lang;
    if (hasFile) processFile();
  }

  void copyText() async {
    if (extractedText.value.isEmpty) return;
    await Clipboard.setData(ClipboardData(text: fullDisplayText));
    ShowToastDialog.showSuccess('Text copied to clipboard');
  }

  void downloadText() {
    if (extractedText.value.isEmpty) return;
    final name = selectedFileName.value.isNotEmpty
        ? selectedFileName.value.replaceAll(RegExp(r'\.[^.]+$'), '')
        : 'ocr_output';

    if (kIsWeb) {
      _downloadTextFile('$name.txt'.toJS, fullDisplayText.toJS);
      ShowToastDialog.showSuccess('Text downloaded as $name.txt');
    } else {
      ShowToastDialog.showSuccess('Download available on web only');
    }
  }

  void clearAll() {
    _isCancelled = true;
    selectedFileName.value = '';
    selectedFileBytes.value = null;
    selectedFileType.value = '';
    extractedText.value = '';
    isProcessing.value = false;
    processingMessage.value = '';
    pdfPageCount.value = 0;
    currentPdfPage.value = 0;
    pageTexts.clear();
  }

  @override
  void onClose() {
    clearAll();
    super.onClose();
  }
}
