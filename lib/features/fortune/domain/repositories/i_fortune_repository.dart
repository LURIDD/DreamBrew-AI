/// DreamBrew AI — Kahve Falı Repository Arayüzü (Domain Katmanı)
///
/// Bu abstract sınıf, Clean Architecture gereği domain katmanında tanımlanır.
/// Concret implementasyonlar (Mock, Real) bu sözleşmeye uymak zorundadır.
/// BLoC ve UseCase'ler yalnızca bu interface'e bağımlıdır — implementasyondan habersizdir.
library;

import '../entities/fortune_reading.dart';

/// Kahve falı yorumu işlemlerine ait repository sözleşmesi.
///
/// Gerçek implementasyon bir Vision AI API'sine görsel gönderirken,
/// mock implementasyon sahte veriler döner. BLoC bu ayrımı bilmez.
abstract interface class IFortuneRepository {
  /// Kullanıcının gönderdiği kahve fincanı görselini yorumlar ve [FortuneReading] döner.
  ///
  /// [imageBase64] — Fotoğrafın base64 ile kodlanmış string hali.
  ///
  /// Hata durumunda [Exception] fırlatabilir.
  Future<FortuneReading> readFortune(String imageBase64);

  /// Kullanıcıya ait geçmiş kahve falı yorumlarını listeler.
  ///
  /// Boş geçmiş durumunda boş liste döner.
  Future<List<FortuneReading>> getFortuneHistory();
}
