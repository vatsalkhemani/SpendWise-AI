import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import '../config/config.dart';

/// Service for OCR (Optical Character Recognition) using Azure Computer Vision API
/// Handles image capture, compression, and text extraction from receipts
class OcrService {
  static final OcrService _instance = OcrService._internal();
  factory OcrService() => _instance;
  OcrService._internal();

  final ImagePicker _picker = ImagePicker();

  /// Capture or select a receipt image from camera or gallery
  ///
  /// [source] - ImageSource.camera or ImageSource.gallery
  /// Returns XFile if successful, null if canceled
  Future<XFile?> captureReceiptImage({required ImageSource source}) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: 1920, // Limit resolution to reduce file size
        maxHeight: 1920,
        imageQuality: 85, // Compress slightly for faster upload
      );

      return image;
    } catch (e) {
      print('Error capturing image: $e');
      rethrow;
    }
  }

  /// Extract text from a receipt image using Azure Computer Vision API
  ///
  /// Process:
  /// 1. Compress image if needed (< 4MB limit)
  /// 2. Upload to Azure Computer Vision Read API
  /// 3. Poll for OCR results
  /// 4. Extract and return recognized text
  ///
  /// Throws exception if OCR fails or no text detected
  Future<String> extractTextFromImage(XFile image) async {
    try {
      // Read image bytes
      final bytes = await image.readAsBytes();

      // Compress if needed (Azure limit is 4MB)
      final compressedBytes = await _compressImageIfNeeded(bytes);

      // Step 1: Submit image for OCR processing
      final operationUrl = await _submitImageForOcr(compressedBytes);

      // Step 2: Poll for results
      final ocrResult = await _pollForOcrResults(operationUrl);

      // Step 3: Extract text from result
      final extractedText = _extractTextFromResult(ocrResult);

      if (extractedText.isEmpty) {
        throw Exception('No text detected in image');
      }

      return extractedText;
    } catch (e) {
      print('Error extracting text from image: $e');
      rethrow;
    }
  }

  /// Compress image if it exceeds 4MB (Azure API limit)
  Future<Uint8List> _compressImageIfNeeded(Uint8List bytes) async {
    const maxSizeBytes = 4 * 1024 * 1024; // 4MB

    if (bytes.length <= maxSizeBytes) {
      return bytes;
    }

    print('Compressing image from ${bytes.length} bytes...');

    // Decode image
    final image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }

    // Calculate new dimensions (reduce by 50%)
    final newWidth = (image.width * 0.7).toInt();
    final newHeight = (image.height * 0.7).toInt();

    // Resize and compress
    final resized = img.copyResize(image, width: newWidth, height: newHeight);
    final compressed = img.encodeJpg(resized, quality: 80);

    print('Compressed to ${compressed.length} bytes');

    return Uint8List.fromList(compressed);
  }

  /// Submit image to Azure Computer Vision Read API
  /// Returns operation URL for polling results
  Future<String> _submitImageForOcr(Uint8List imageBytes) async {
    final endpoint = Config.azureVisionEndpoint;
    final apiKey = Config.azureVisionApiKey;

    // Azure Computer Vision Read API endpoint
    final url = Uri.parse('$endpoint/vision/v3.2/read/analyze');

    final response = await http.post(
      url,
      headers: {
        'Ocp-Apim-Subscription-Key': apiKey,
        'Content-Type': 'application/octet-stream',
      },
      body: imageBytes,
    );

    if (response.statusCode == 202) {
      // Success - operation URL is in Location header
      final operationUrl = response.headers['operation-location'];
      if (operationUrl == null) {
        throw Exception('No operation URL in response');
      }
      return operationUrl;
    } else {
      throw Exception(
          'Failed to submit image: ${response.statusCode} ${response.body}');
    }
  }

  /// Poll Azure Computer Vision API for OCR results
  /// Retries every 1 second until status is "succeeded" or timeout (30s)
  Future<Map<String, dynamic>> _pollForOcrResults(String operationUrl) async {
    final apiKey = Config.azureVisionApiKey;
    const maxAttempts = 30; // 30 seconds timeout
    const pollInterval = Duration(seconds: 1);

    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      await Future.delayed(pollInterval);

      final response = await http.get(
        Uri.parse(operationUrl),
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey,
        },
      );

      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        final status = result['status'];

        if (status == 'succeeded') {
          return result;
        } else if (status == 'failed') {
          throw Exception('OCR processing failed');
        }
        // If status is "running", continue polling
      } else {
        throw Exception('Failed to get OCR results: ${response.statusCode}');
      }
    }

    throw TimeoutException('OCR processing timed out');
  }

  /// Extract text lines from Azure Computer Vision OCR result
  /// Concatenates all recognized text with line breaks
  String _extractTextFromResult(Map<String, dynamic> result) {
    try {
      final analyzeResult = result['analyzeResult'];
      if (analyzeResult == null) {
        return '';
      }

      final readResults = analyzeResult['readResults'] as List?;
      if (readResults == null || readResults.isEmpty) {
        return '';
      }

      // Concatenate all text lines
      final textLines = <String>[];
      for (final page in readResults) {
        final lines = page['lines'] as List?;
        if (lines != null) {
          for (final line in lines) {
            final text = line['text'] as String?;
            if (text != null && text.isNotEmpty) {
              textLines.add(text);
            }
          }
        }
      }

      return textLines.join('\n');
    } catch (e) {
      print('Error extracting text from OCR result: $e');
      return '';
    }
  }
}
