/// DreamBrew AI — Görsel Sıkıştırma Servisi (Mock)
///
/// Bu sınıf, kahve fincanı fotoğraflarının sunucuya gönderilmeden önce
/// sıkıştırılmasını simüle eder. Production'da gerçek bir sıkıştırma
/// kütüphanesi (flutter_image_compress vb.) ile değiştirilecektir.
///
/// Şu anki davranış:
/// - 500ms gecikme ile gerçek sıkıştırma süresini taklit eder
/// - Dosya yolundan basit bir base64 benzeri string üretir
/// - Orijinal dosya boyutunu ve sıkıştırılmış boyutu loglar
library;

import 'dart:convert';
import 'dart:io';

/// Görsel dosyalarını sıkıştırmak için kullanılan yardımcı sınıf.
///
/// Tüm metotlar statiktir; instance oluşturmaya gerek yoktur.
///
/// ### Kullanım:
/// ```dart
/// final compressed = await ImageCompressor.compress(File('path/to/image.jpg'));
/// // compressed → base64 formatında string
/// ```
abstract final class ImageCompressor {
  /// Verilen [imageFile]'ı sıkıştırır ve base64 string olarak döner.
  ///
  /// **Mock Davranış:**
  /// - 500ms yapay gecikme uygular
  /// - Dosya yolunun byte'larını base64'e çevirir
  /// - Gerçek görsel verisi ile çalışmaz (production'da değişecek)
  ///
  /// **Production'da:**
  /// - flutter_image_compress ile gerçek sıkıştırma
  /// - Hedef kalite: %70, maks boyut: 800x800
  /// - WebP formatına dönüşüm
  static Future<String> compress(File imageFile) async {
    // Gerçek sıkıştırma süresini simüle et
    await Future<void>.delayed(const Duration(milliseconds: 500));

    // Dosya yolundan base64 string üret (mock)
    // Production'da burada gerçek byte'lar sıkıştırılacak
    final originalBytes = utf8.encode(imageFile.path);
    final compressedBase64 = base64Encode(originalBytes);

    // Debug bilgisi
    assert(() {
      // ignore: avoid_print
      print(
        '📸 ImageCompressor [Mock]:\n'
        '   Orijinal yol: ${imageFile.path}\n'
        '   Simüle edilen çıktı boyutu: ${compressedBase64.length} karakter',
      );
      return true;
    }());

    return compressedBase64;
  }
}
