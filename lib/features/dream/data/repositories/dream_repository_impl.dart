/// DreamBrew AI — Gerçek Rüya Yorumu Repository Implementasyonu
///
/// Google Gemini LLM API'si ile çalışan rüya yorumu servisi.
/// Kullanıcının rüya metnini ve seçtiği yorum tarzını alarak
/// yapay zekadan yapılandırılmış bir yorum alır ve [DreamReading]
/// entity'sine dönüştürür.
///
/// ### Desteklenen Tarzlar
/// - **Mystical** — Mistik, spiritüel, kozmik enerji odaklı
/// - **Fun** — Eğlenceli, samimi, emoji dolu
/// - **Psychological** — Bilimsel, Jung/Freud yaklaşımlı
library;

import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/app_exceptions.dart';
import '../../domain/entities/dream_reading.dart';
import '../../domain/repositories/i_dream_repository.dart';

/// [IDreamRepository]'nin gerçek (production) implementasyonu.
///
/// DI container'a kayıtlıdır. [ApiClient] üzerinden Gemini API'ye
/// istek atar ve dönen JSON yanıtı [DreamReading] modeline parse eder.
final class DreamRepositoryImpl implements IDreamRepository {
  final ApiClient _apiClient;

  const DreamRepositoryImpl(this._apiClient);

  // ─── Sistem Promptları ──────────────────────────────────────────────────

  /// Tüm tarzlar için ortak temel sistem talimatı.
  ///
  /// AI'a rolünü, çıktı formatını ve dil kurallarını bildirir.
  static const _baseSystemPrompt = '''
Sen "DreamBrew AI" uygulamasındaki yapay zeka rüya yorumcususun.
Görevin: Kullanıcının anlattığı rüyayı derinlemesine analiz etmek,
sembollerini çözmek ve anlamlı bir yorum sunmak.

MUTLAKA aşağıdaki JSON formatında yanıt ver. Başka hiçbir metin ekleme:
{
  "themes": ["tema1", "tema2", "tema3"],
  "symbols": [
    {"symbol": "sembol_adı", "meaning": "detaylı yorum (en az 2 cümle)"},
    {"symbol": "sembol_adı", "meaning": "detaylı yorum (en az 2 cümle)"}
  ],
  "emotionalTone": "rüyanın duygusal tonu (2-4 kelime)",
  "suggestions": [
    "pratik öneri 1",
    "pratik öneri 2",
    "pratik öneri 3",
    "pratik öneri 4"
  ],
  "overallMessage": "rüyanın genel mesajı ve özeti (en az 3 cümle, içten ve etkileyici)"
}

KURALLAR:
- Yanıtı yalnızca Türkçe yaz.
- En az 3 tema, 2-5 sembol, 4 öneri belirle.
- Sembol yorumları en az 2 cümle olmalı.
- overallMessage en az 3 cümle, içten ve etkileyici olmalı.
- Önerileri kullanıcının günlük hayatına uygulanabilir şekilde yaz.
- Hiçbir zaman JSON dışında metin ekleme.
''';

  /// Tarz'a göre ek sistem talimatını döner.
  static String _getStyleInstruction(String style) {
    switch (style) {
      case 'Mystical':
        return '''
TARZ: MİSTİK & SPİRİTÜEL
- Kozmik enerji, evren, yıldızlar, ruhani rehberlik ifadelerini kullan.
- Her sembolü astrolojik ve spiritüel bir perspektiften yorumla.
- "Evren sana bir mesaj gönderiyor", "Kozmik enerjiler..." gibi girişler yap.
- Emojiler kullan: ✨🌙🔮🌟💫⭐🌌🌠
- overallMessage'ı "Evrenin sana fısıldadığı..." gibi mistik bir tonla bitir.
- Önerilerde kristal, meditasyon, ay ışığı gibi spiritüel öğelere yer ver.
''';

      case 'Fun':
        return '''
TARZ: EĞLENCELİ & SAMİMİ
- Arkadaş gibi sıcak, samimi ve neşeli bir dil kullan.
- Bol emoji ekle: 😄🎉🚀💪🎯🌈🦋🎊
- Espritüel ve hafif mecazlar kur, abartılı karşılaştırmalar yap.
- "Vay be, bu rüya aşırı epik!", "Bilinçaltın parti vermiş!" gibi giriş yap.
- overallMessage'ı motivasyonel ve enerjik bir tonla yaz.
- Önerilerde eğlenceli aktiviteler ve sosyal etkinliklere yer ver.
''';

      case 'Psychological':
        return '''
TARZ: PSİKOLOJİK & BİLİMSEL
- Carl Jung, Sigmund Freud ve modern psikoloji terminolojisini kullan.
- Bilinçdışı, arketip, gölge benlik, ego gibi kavramları doğal şekilde entegre et.
- Her sembolü analitik bir perspektiften yorumla.
- "Bilinçaltınız size... iletmeye çalışıyor", "Bu arketipsel figür..." gibi giriş yap.
- overallMessage'ı kişisel gelişim odaklı ve farkındalık artırıcı bir tonla yaz.
- Önerilerde öz-düşünme, günlük tutma, farkındalık pratiği gibi öğelere yer ver.
''';

      default:
        return _getStyleInstruction('Mystical');
    }
  }

  // ─── Repository Metotları ───────────────────────────────────────────────

  @override
  Future<DreamReading> interpretDream(
    String dreamText, {
    required String style,
  }) async {
    // Sistem promptunu birleştir
    final systemPrompt = '$_baseSystemPrompt\n${_getStyleInstruction(style)}';

    // Kullanıcı promptu
    final userPrompt =
        '''
Aşağıdaki rüyayı "$style" tarzında yorumla:

---
$dreamText
---
''';

    // API çağrısı
    final responseText = await _apiClient.generateContent(
      prompt: userPrompt,
      systemInstruction: systemPrompt,
    );

    // JSON parse ve entity dönüşümü
    return _parseResponse(responseText, dreamText);
  }

  @override
  Future<List<DreamReading>> getDreamHistory() async {
    // Geçmiş artık Hive (yerel depolama) üzerinden yönetiliyor.
    // Bu metot geriye dönük uyumluluk için boş liste döner.
    return const [];
  }

  // ─── Yardımcı Metotlar ─────────────────────────────────────────────────

  /// AI'dan gelen JSON yanıtı [DreamReading] entity'sine dönüştürür.
  ///
  /// Parse hatasında [InvalidResponseException] fırlatır.
  DreamReading _parseResponse(String responseText, String dreamText) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseText);

      // Zorunlu alanların varlığını kontrol et
      _validateRequiredFields(json);

      return DreamReading(
        id: 'dream-${DateTime.now().millisecondsSinceEpoch}',
        dreamDescription: dreamText,
        interpretedAt: DateTime.now(),
        themes: List<String>.from(json['themes'] as List),
        symbols: (json['symbols'] as List)
            .map((e) => DreamSymbol.fromMap(e as Map<String, dynamic>))
            .toList(),
        emotionalTone: json['emotionalTone'] as String,
        suggestions: List<String>.from(json['suggestions'] as List),
        overallMessage: json['overallMessage'] as String,
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw InvalidResponseException(
        message:
            'Rüya yorumu yanıtı işlenemedi. '
            'Kozmik sinyaller karıştı… Lütfen tekrar deneyin. 🌌',
        originalError: e,
      );
    }
  }

  /// JSON yanıtındaki zorunlu alanları doğrular.
  void _validateRequiredFields(Map<String, dynamic> json) {
    final requiredKeys = [
      'themes',
      'symbols',
      'emotionalTone',
      'suggestions',
      'overallMessage',
    ];

    for (final key in requiredKeys) {
      if (!json.containsKey(key) || json[key] == null) {
        throw InvalidResponseException(
          message:
              'AI yanıtında "$key" alanı eksik. '
              'Lütfen tekrar deneyin. 🔮',
        );
      }
    }
  }
}
