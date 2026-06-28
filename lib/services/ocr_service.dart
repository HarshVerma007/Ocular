import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:photo_manager/photo_manager.dart';
import 'dart:io';

/// Service for OCR text recognition using Google ML Kit.
class OcrService {
  OcrService._();
  static final OcrService instance = OcrService._();

  TextRecognizer? _textRecognizer;
  final Map<String, String> _ocrCache = {};

  /// Initialize the text recognizer (lazy).
  TextRecognizer get _recognizer {
    _textRecognizer ??= TextRecognizer(script: TextRecognitionScript.latin);
    return _textRecognizer!;
  }

  /// Recognize text from an image file path.
  Future<String> recognizeTextFromFile(String filePath) async {
    try {
      final inputImage = InputImage.fromFilePath(filePath);
      final RecognizedText recognizedText =
          await _recognizer.processImage(inputImage);
      return recognizedText.text;
    } catch (e) {
      return '';
    }
  }

  /// Recognize text from an AssetEntity.
  Future<String> recognizeTextFromAsset(AssetEntity asset) async {
    // Return cached OCR text if available to avoid redundant processing
    final cached = _ocrCache[asset.id];
    if (cached != null) return cached;

    try {
      final File? file = await asset.file;
      if (file == null) return '';
      final text = await recognizeTextFromFile(file.path);
      _ocrCache[asset.id] = text;
      return text;
    } catch (e) {
      return '';
    }
  }

  /// Search screenshots for a query string.
  /// Uses parallel indexing and query normalization for high accuracy.
  Future<List<AssetEntity>> searchScreenshots(
    String query,
    List<AssetEntity> screenshots,
  ) async {
    if (query.trim().isEmpty) return screenshots;

    final List<AssetEntity> results = [];
    final List<Future<void>> futures = [];

    for (final asset in screenshots) {
      futures.add(recognizeTextFromAsset(asset).then((text) {
        if (_matches(text, query)) {
          results.add(asset);
        }
      }));
    }

    await Future.wait(futures);
    return results;
  }

  /// Match check with query normalization (handles spaces/special chars).
  bool _matches(String text, String query) {
    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();

    // 1. Direct contains check
    if (lowerText.contains(lowerQuery)) return true;

    // 2. Alphanumeric normalization (e.g. matches "idcard" with "id card")
    final normalizedText = lowerText.replaceAll(RegExp(r'[^a-z0-9]'), '');
    final normalizedQuery = lowerQuery.replaceAll(RegExp(r'[^a-z0-9]'), '');
    if (normalizedText.contains(normalizedQuery)) return true;

    // 3. Multi-word checklist (e.g. search "college card" -> both must appear in text)
    final words = lowerQuery.split(RegExp(r'\s+')).where((w) => w.length > 1);
    if (words.isNotEmpty) {
      return words.every((word) => lowerText.contains(word));
    }

    return false;
  }

  /// Release ML Kit resources.
  void dispose() {
    _textRecognizer?.close();
    _textRecognizer = null;
    _ocrCache.clear();
  }
}
