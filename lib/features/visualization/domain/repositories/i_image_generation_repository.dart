/// DreamBrew AI — Image Generation Repository Interface
///
/// AI görsel üretimi için domain katmanı sözleşmesi.
/// Gemini gemini-2.5-flash-image modeli ile Base64 görsel üretir.
library;

/// Metin girdisine (prompt) göre görsel üretir ve Base64 dizgesi döndürür.
abstract class IImageGenerationRepository {
  /// Verilen anahtar kelimeleri kullanarak Base64 formatında görsel üretir.
  Future<String> generateImage(List<String> keywords);
}
