/// DreamBrew AI — Özel Hata (Exception) Sınıfları
///
/// API katmanında oluşabilecek tüm hataları temsil eden exception hiyerarşisi.
/// BLoC katmanı bu exception'ları yakalayarak kullanıcıya anlamlı mesajlar gösterir.
///
/// Hiyerarşi:
/// ```
/// AppException (base)
/// ├── NetworkException      — İnternet bağlantısı yok
/// ├── TimeoutException      — İstek zaman aşımına uğradı
/// ├── ApiLimitException     — API rate limit'e takıldı (429)
/// ├── ServerException       — Sunucu hatası (5xx)
/// ├── InvalidResponseException — Yanıt parse edilemedi
/// └── UnauthorizedException — API anahtarı geçersiz (401/403)
/// ```
library;

/// Tüm uygulama hatalarının temel sınıfı.
///
/// Alt sınıflar spesifik hata senaryolarını temsil eder.
/// Her exception, kullanıcıya gösterilecek Türkçe bir [message] taşır.
sealed class AppException implements Exception {
  /// Kullanıcıya gösterilecek hata açıklaması
  final String message;

  /// Opsiyonel: orijinal hata (debug amaçlı)
  final dynamic originalError;

  const AppException({required this.message, this.originalError});

  @override
  String toString() => '$runtimeType: $message';
}

/// İnternet bağlantısı olmadığında fırlatılır.
///
/// Tetikleme: `DioExceptionType.connectionError` veya `SocketException`
final class NetworkException extends AppException {
  const NetworkException({
    super.message =
        'İnternet bağlantısı bulunamadı. '
        'Lütfen bağlantınızı kontrol edip tekrar deneyin. 📡',
    super.originalError,
  });
}

/// İstek zaman aşımına uğradığında fırlatılır.
///
/// AI API'leri bazen yoğun olabilir; kullanıcıya bekleme mesajı gösterilir.
/// Tetikleme: `DioExceptionType.connectTimeout`, `receiveTimeout`, `sendTimeout`
final class TimeoutException extends AppException {
  const TimeoutException({
    super.message =
        'İstek zaman aşımına uğradı. '
        'Yıldızlar biraz yoğun görünüyor… Lütfen tekrar deneyin. ⏳',
    super.originalError,
  });
}

/// API kullanım limitine ulaşıldığında fırlatılır (HTTP 429).
///
/// Kullanıcıya kısa süre sonra tekrar denemesi önerilir.
final class ApiLimitException extends AppException {
  const ApiLimitException({
    super.message =
        'API kullanım limiti aşıldı. '
        'Kozmik enerji biraz dinlenmeye ihtiyaç duyuyor… '
        'Birkaç dakika sonra tekrar deneyin. 🌙',
    super.originalError,
  });
}

/// Sunucu taraflı bir hata oluştuğunda fırlatılır (HTTP 5xx).
final class ServerException extends AppException {
  const ServerException({
    super.message =
        'Sunucu tarafında bir sorun oluştu. '
        'Yıldız haritası geçici olarak erişilemiyor. Lütfen tekrar deneyin. 🔮',
    super.originalError,
  });
}

/// API yanıtı beklenilen formata uymadığında fırlatılır.
///
/// AI bazen yapılandırılmış JSON yerine düz metin dönebilir;
/// bu durumda parse hatası oluşur.
final class InvalidResponseException extends AppException {
  const InvalidResponseException({
    super.message =
        'Yapay zekadan gelen yanıt anlaşılamadı. '
        'Kozmik sinyaller karıştı… Lütfen tekrar deneyin. 🌌',
    super.originalError,
  });
}

/// API anahtarı geçersiz veya yetkisiz erişim (HTTP 401/403).
final class UnauthorizedException extends AppException {
  const UnauthorizedException({
    super.message =
        'API anahtarı geçersiz veya süresi dolmuş. '
        'Lütfen .env dosyanızdaki GEMINI_API_KEY değerini kontrol edin. 🔑',
    super.originalError,
  });
}
