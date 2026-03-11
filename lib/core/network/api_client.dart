/// DreamBrew AI — Gemini API Client (Ağ Katmanı)
///
/// [Dio] tabanlı HTTP istemcisi. Google Gemini API ile iletişimi yönetir.
/// Özellikler:
/// - Uzun timeout süreleri (AI yanıtları için)
/// - Otomatik loglama (debug modunda)
/// - Hata yakalama ve custom exception dönüşümü
/// - Text ve Vision endpoint desteği
library;

import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app_exceptions.dart';

/// Gemini API ile iletişim kuran merkezi HTTP istemcisi.
///
/// Singleton olarak DI container'a kaydedilir.
/// Tüm repository'ler bu istemci üzerinden API çağrısı yapar.
///
/// ### Kullanım:
/// ```dart
/// final client = ApiClient();
/// final response = await client.generateContent(
///   prompt: 'Rüyamı yorumla...',
///   systemInstruction: 'Sen bir rüya yorumcususun...',
/// );
/// ```
class ApiClient {
  late final Dio _dio;

  /// Gemini API base URL (sondaki / Dio'nun path'i doğru resolve etmesi için şart)
  static const _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/';

  /// Kullanılacak metin modeli adı
  static const _textModel = 'gemini-2.5-flash';

  /// Görsel üretim modeli adı
  static const _imageModel = 'gemini-2.5-flash-image';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        // AI API'leri yavaş olabilir — timeout'ları uzun tut
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 120),
        sendTimeout: const Duration(seconds: 60),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // ─── Interceptors ─────────────────────────────────────────────────────
    // Debug modunda istek/yanıt loglaması
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          logPrint: (obj) => debugPrint('🌐 API: $obj'),
        ),
      );
    }
  }

  /// `.env` dosyasından API anahtarını okur.
  String get _apiKey {
    final key = dotenv.env['GEMINI_API_KEY'];
    if (key == null || key.isEmpty || key == 'your_api_key_here') {
      throw const UnauthorizedException(
        message:
            'GEMINI_API_KEY tanımlı değil. '
            'Lütfen .env dosyanıza geçerli bir API anahtarı ekleyin. 🔑',
      );
    }
    return key;
  }

  /// Gemini API'ye metin tabanlı istek gönderir (LLM — Rüya Yorumu).
  ///
  /// [prompt] — Kullanıcı promptu (rüya metni + tarz bilgisi)
  /// [systemInstruction] — Sistem promptu (AI'ın rolünü ve çıktı formatını belirler)
  ///
  /// Dönen [String], AI'ın ürettiği ham metin yanıtıdır.
  Future<String> generateContent({
    required String prompt,
    required String systemInstruction,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '$_textModel:generateContent?key=$_apiKey',
        data: {
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.9,
            'topP': 0.95,
            'maxOutputTokens': 4096,
          },
        },
      );

      return _extractTextFromResponse(response.data!);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw InvalidResponseException(originalError: e);
    }
  }

  /// Gemini API'ye görsel + metin tabanlı istek gönderir (Vision — Kahve Falı).
  ///
  /// [prompt] — Kullanıcı promptu (yorum tarzı bilgisi)
  /// [systemInstruction] — Sistem promptu (falcı rolü ve çıktı formatı)
  /// [imageBase64] — Fotoğrafın base64 formatındaki verisi
  /// [mimeType] — Görselin MIME tipi (varsayılan: image/jpeg)
  Future<String> generateContentWithImage({
    required String prompt,
    required String systemInstruction,
    required String imageBase64,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/$_textModel:generateContent?key=$_apiKey',
        data: {
          'system_instruction': {
            'parts': [
              {'text': systemInstruction},
            ],
          },
          'contents': [
            {
              'parts': [
                {'text': prompt},
                {
                  'inline_data': {'mime_type': mimeType, 'data': imageBase64},
                },
              ],
            },
          ],
          'generationConfig': {
            'responseMimeType': 'application/json',
            'temperature': 0.9,
            'topP': 0.95,
            'maxOutputTokens': 4096,
          },
        },
      );

      return _extractTextFromResponse(response.data!);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw InvalidResponseException(originalError: e);
    }
  }

  /// Gemini API'ye metin tabanlı istek gönderip görsel ürettirir.
  ///
  /// [prompt] — Görsel üretimi için kullanılacak açıklama metni.
  ///
  /// Gemini `gemini-2.5-flash-preview-image-generation` modelini kullanır.
  /// Dönen yanıttaki `inlineData` alanından Base64 görsel verisini çıkarır.
  ///
  /// Hata durumunda uygun [AppException] fırlatır.
  Future<String> generateImageFromPrompt({
    required String prompt,
  }) async {
    try {
      // Görsel üretim için timeout'ları uzun tut
      final response = await _dio.post<Map<String, dynamic>>(
        '$_imageModel:generateContent?key=$_apiKey',
        data: {
          'contents': [
            {
              'parts': [
                {'text': prompt},
              ],
            },
          ],
          'generationConfig': {
            'responseModalities': ['TEXT', 'IMAGE'],
            'temperature': 1.0,
            'topP': 0.95,
          },
        },
        options: Options(
          sendTimeout: const Duration(seconds: 60),
          receiveTimeout: const Duration(seconds: 60),
        ),
      );

      return _extractImageFromResponse(response.data!);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw InvalidResponseException(originalError: e);
    }
  }

  /// Gemini Image API yanıtından Base64 görsel verisini çıkarır.
  ///
  /// Yanıt formatı:
  /// ```json
  /// {
  ///   "candidates": [{
  ///     "content": {
  ///       "parts": [
  ///         {"text": "..."},
  ///         {"inlineData": {"mimeType": "image/png", "data": "BASE64..."}}
  ///       ]
  ///     }
  ///   }]
  /// }
  /// ```
  String _extractImageFromResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const InvalidResponseException(
          message: 'AI görsel üretemedi. Kozmik sinyaller kayboldu… 🌠',
        );
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const InvalidResponseException(
          message: 'AI yanıtında görsel verisi bulunamadı.',
        );
      }

      // parts listesinde inlineData içeren part'ı bul
      for (final part in parts) {
        final inlineData = part['inlineData'] as Map<String, dynamic>?;
        if (inlineData != null) {
          final base64Data = inlineData['data'] as String?;
          if (base64Data != null && base64Data.isNotEmpty) {
            return base64Data;
          }
        }
      }

      throw const InvalidResponseException(
        message: 'Yanıtta görsel verisi bulunamadı. Lütfen tekrar deneyin.',
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw InvalidResponseException(originalError: e);
    }
  }

  /// Gemini API yanıtından metin içeriğini çıkarır.
  ///
  /// Yanıt formatı:
  /// ```json
  /// {
  ///   "candidates": [{
  ///     "content": {
  ///       "parts": [{"text": "..."}]
  ///     }
  ///   }]
  /// }
  /// ```
  String _extractTextFromResponse(Map<String, dynamic> data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        throw const InvalidResponseException(
          message:
              'AI yanıt üretemedi. '
              'Kozmik sinyaller kayboldu… Lütfen tekrar deneyin. 🌠',
        );
      }

      final content = candidates[0]['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List?;
      if (parts == null || parts.isEmpty) {
        throw const InvalidResponseException();
      }

      final text = parts[0]['text'] as String?;
      if (text == null || text.trim().isEmpty) {
        throw const InvalidResponseException();
      }

      return text.trim();
    } on AppException {
      rethrow;
    } catch (e) {
      throw InvalidResponseException(originalError: e);
    }
  }

  /// [DioException]'ları uygun [AppException] alt sınıflarına dönüştürür.
  AppException _handleDioError(DioException error) {
    // HTTP durum koduna göre exception seç
    final statusCode = error.response?.statusCode;

    if (statusCode != null) {
      switch (statusCode) {
        case 401:
        case 403:
          return UnauthorizedException(originalError: error);
        case 404:
          return const ServerException(
            message:
                'API endpoint bulunamadı. '
                'Lütfen uygulamanızı güncelleyin veya tekrar deneyin. 🔮',
          );
        case 429:
          return ApiLimitException(originalError: error);
        case >= 500:
          return ServerException(originalError: error);
      }
    }

    // Bağlantı türüne göre exception seç
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return TimeoutException(originalError: error);
      case DioExceptionType.connectionError:
        return NetworkException(originalError: error);
      default:
        // SocketException kontrolü (alt seviye bağlantı hatası)
        if (error.error is SocketException) {
          return NetworkException(originalError: error);
        }
        return ServerException(
          message:
              'Beklenmeyen bir hata oluştu: ${error.message ?? "Bilinmeyen hata"} 💫',
          originalError: error,
        );
    }
  }
}
