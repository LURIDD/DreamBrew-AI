/// DreamBrew AI — Gemini Image Generation Repository
///
/// Google Gemini API'nin `gemini-2.5-flash-preview-image-generation` modeline istek atarak
/// anahtar kelimelerden mistik bir görsel üretir.
/// Üretilen görsel Base64 formatında döndürülür.
library;

import '../../../../core/network/api_client.dart';
import '../../domain/repositories/i_image_generation_repository.dart';

/// Gemini API tabanlı görsel üretim implementasyonu.
///
/// [ApiClient] üzerinden Gemini Image Generation endpoint'ine
/// POST isteği gönderir. Dönen JSON yanıtından Base64 görsel
/// verisini parse ederek döndürür.
class ImageGenerationRepository implements IImageGenerationRepository {
  final ApiClient _apiClient;

  ImageGenerationRepository(this._apiClient);

  @override
  Future<String> generateImage(List<String> keywords) async {
    // 1. Prompt Hazırlığı
    final basePrompt = keywords.isEmpty
        ? 'mystical dreamscape with stars and moon'
        : keywords.join(', ');

    final prompt = 'Generate a mystical, highly detailed digital art image '
        'inspired by these symbols: $basePrompt. '
        'The style should be ethereal, dreamy, with atmospheric lighting, '
        'fantasy illustration vibes, and a magical cosmic background. '
        'Do NOT include any text or writing in the image.';

    // 2. Gemini Image API'ye istek at ve Base64 görsel al
    try {
      final base64Image = await _apiClient.generateImageFromPrompt(
        prompt: prompt,
      );
      return base64Image;
    } catch (e) {
      // Hata mesajını kullanıcı dostu hale getir
      throw Exception(
        'Kozmik bağlantıda bir sorun oluştu, '
        'lütfen internetinizi kontrol edip tekrar deneyin.',
      );
    }
  }
}
