/// DreamBrew AI — Pollinations AI Görsel Üretim Implementasyonu
///
/// Ücretsiz bir endpoint olan image.pollinations.ai kullanarak
/// prompt tabanlı görsel üretimi gerçekleştirir.
library;

import 'dart:typed_data';
import 'package:dio/dio.dart';
import '../../domain/repositories/i_image_generation_repository.dart';

/// Pollinations AI tabanlı ImageGenerationRepository gerçekleştirimi
class ImageGenerationRepository implements IImageGenerationRepository {
  final Dio _dio;

  ImageGenerationRepository(this._dio);

  @override
  Future<Uint8List> generateImage(List<String> keywords) async {
    try {
      // 1. Prompt Hazırlığı
      // Eğer kelime yoksa varsayılan mistik bir manzara üret.
      // Eğer kelime varsa, sonuna güzel bir rüya/fal atmosferi katan kelimeler ekle.
      final basePrompt = keywords.isEmpty
          ? 'mystical dreamscape with stars and moon'
          : keywords.join(', ');
      
      final enhancedPrompt = '$basePrompt, mystical, highly detailed, beautiful digital art, atmospheric lighting, dreamy background';
      
      // 2. URL Encode (Örn: boşluklar %20 olur)
      final encodedPrompt = Uri.encodeComponent(enhancedPrompt);
      
      // 3. İstek Atma
      // Pollinations AI, GET isteğiyle doğrudan resmi döndürür.
      final url = 'https://image.pollinations.ai/prompt/$encodedPrompt';
      
      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.bytes,
          // Pollinations biraz ağır olabilir, timeout sürelerini uzun tutalım
          receiveTimeout: const Duration(seconds: 45),
          sendTimeout: const Duration(seconds: 45),
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        return Uint8List.fromList(response.data as List<int>);
      } else {
        throw Exception('Görsel üretilemedi. Sunucu hatası: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Görsel üretimi başarısız oldu: $e');
    }
  }
}
