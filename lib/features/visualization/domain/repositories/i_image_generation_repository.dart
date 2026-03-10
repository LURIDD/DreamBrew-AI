/// DreamBrew AI — Image Generation Repository Interface
///
/// AI görsel üretimi için domain katmanı sözleşmesi.
library;

import 'dart:typed_data';

/// Metin girdisine (prompt) göre görsel üretir ve byte dizisi döndürür.
abstract class IImageGenerationRepository {
  /// Verilen anahtar kelimeleri kullanarak görsel üretir.
  /// 
  /// [keywords] semboller, temalar veya serbest metin olabilir.
  Future<Uint8List> generateImage(List<String> keywords);
}
