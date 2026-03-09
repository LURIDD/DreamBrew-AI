/// DreamBrew AI — Rüya Repository Arayüzü (Domain Katmanı)
///
/// Bu abstract sınıf, Clean Architecture gereği domain katmanında tanımlanır.
/// Concret implementasyonlar (Mock, Real) bu sözleşmeye uymak zorundadır.
/// BLoC ve UseCase'ler yalnızca bu interface'e bağımlıdır — implementasyondan habersizdir.
library;

import '../entities/dream_reading.dart';

/// Rüya yorumu işlemlerine ait repository sözleşmesi.
///
/// Gerçek implementasyon bir LLM API'sine istek atarken,
/// mock implementasyon sahte veriler döner. BLoC bu ayrımı bilmez.
abstract interface class IDreamRepository {
  /// Kullanıcının girdiği rüya metnini seçilen tarzda yorumlar ve [DreamReading] döner.
  ///
  /// [dreamText] — Kullanıcının serbest biçimde yazdığı rüya anlatımı.
  /// [style] — Yorum tarzı: 'Mystical', 'Fun' veya 'Psychological'.
  ///
  /// Hata durumunda [Exception] fırlatabilir.
  Future<DreamReading> interpretDream(
    String dreamText, {
    required String style,
  });

  /// Kullanıcıya ait geçmiş rüya yorumlarını listeler.
  ///
  /// Boş geçmiş durumunda boş liste döner.
  Future<List<DreamReading>> getDreamHistory();
}
