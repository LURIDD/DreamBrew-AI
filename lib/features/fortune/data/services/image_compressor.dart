/// DreamBrew AI — Görsel Sıkıştırma ve Base64 Dönüşüm Servisi
///
/// Kahve fincanı fotoğraflarını Vision API'ye gönderilebilir formata
/// dönüştürür. Dosyanın gerçek byte'larını okur ve base64'e çevirir.
///
/// ### Kullanım:
/// ```dart
/// final base64 = await ImageCompressor.compress(File('path/to/image.jpg'));
/// // base64 → Vision API'ye gönderilmeye hazır string
/// ```
library;

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';

/// Görsel dosyalarını base64 formatına dönüştüren yardımcı sınıf.
///
/// Tüm metotlar statiktir; instance oluşturmaya gerek yoktur.
abstract final class ImageCompressor {
  /// Verilen [imageFile]'ı okur ve base64 string olarak döner.
  ///
  /// Dosyanın gerçek byte'larını okuyarak base64 encode işlemi yapar.
  /// Vision API bu formatta görsel kabul eder.
  ///
  /// [imageFile] — Sıkıştırılacak görsel dosyası
  /// Dönüş: Base64 formatında string
  static Future<String> compress(File imageFile) async {
    // Dosyanın gerçek byte'larını oku
    final bytes = await imageFile.readAsBytes();

    // Base64'e dönüştür
    final base64String = base64Encode(bytes);

    // Debug bilgisi
    if (kDebugMode) {
      final fileSizeKB = (bytes.length / 1024).toStringAsFixed(1);
      final base64SizeKB = (base64String.length / 1024).toStringAsFixed(1);
      debugPrint(
        '📸 ImageCompressor:\n'
        '   Dosya: ${imageFile.path}\n'
        '   Orijinal boyut: $fileSizeKB KB\n'
        '   Base64 boyut: $base64SizeKB KB',
      );
    }

    return base64String;
  }
}
