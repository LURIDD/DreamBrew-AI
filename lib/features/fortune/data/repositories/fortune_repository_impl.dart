/// DreamBrew AI — Gerçek Kahve Falı Repository Implementasyonu
///
/// Google Gemini Vision API ile çalışan kahve falı yorumu servisi.
/// Kullanıcının yüklediği fincan fotoğrafını ve seçtiği yorum tarzını
/// alarak yapay zekadan yapılandırılmış bir fal yorumu alır ve
/// [FortuneReading] entity'sine dönüştürür.
///
/// ### Desteklenen Tarzlar
/// - **Mystical** — Mistik, gizemli, kozmik fal yorumu
/// - **Fun** — Eğlenceli, samimi, neşeli yorum
/// - **Psychological** — Sembol analizi odaklı derin yorum
library;

import 'dart:convert';

import '../../../../core/network/api_client.dart';
import '../../../../core/network/app_exceptions.dart';
import '../../domain/entities/fortune_reading.dart';
import '../../domain/repositories/i_fortune_repository.dart';

/// [IFortuneRepository]'nin gerçek (production) implementasyonu.
///
/// DI container'a kayıtlıdır. [ApiClient] üzerinden Gemini Vision API'ye
/// görsel + prompt gönderir ve dönen JSON yanıtı [FortuneReading] modeline
/// parse eder.
final class FortuneRepositoryImpl implements IFortuneRepository {
  final ApiClient _apiClient;

  const FortuneRepositoryImpl(this._apiClient);

  // ─── Sistem Promptları ──────────────────────────────────────────────────

  /// Tüm tarzlar için ortak temel sistem talimatı.
  ///
  /// AI'a kahve falcısı rolünü, görsel analiz kurallarını ve
  /// çıktı formatını bildirir.
  static const _baseSystemPrompt = '''
Sen "DreamBrew AI" uygulamasındaki yapay zeka kahve falcısısın.
Görevin: Kullanıcının gönderdiği Türk kahvesi fincanı fotoğrafını
inceleyerek fincandaki ve tabaktaki şekilleri/sembolleri bulmak ve
bunları yorumlamak.

Fotoğrafı dikkatle incele:
1. Fincandaki telve kalıntılarından oluşan şekilleri tespit et.
2. Tabakta (varsa) oluşan desenleri incele.
3. Sembollerin konumlarına (fincan ağzı/dibi, tabak kenarı/ortası) göre
   zaman çerçevesini belirle: ağıza yakın = yakın gelecek, dibe yakın = uzak gelecek.

MUTLAKA aşağıdaki JSON formatında yanıt ver. Başka hiçbir metin ekleme:
{
  "symbols": [
    {
      "name": "sembol_adı",
      "position": "fincan" veya "tabak",
      "meaning": "detaylı yorum (en az 2 cümle)"
    }
  ],
  "themes": ["tema1", "tema2", "tema3"],
  "timeframe": "yakın gelecek (1-3 hafta)" veya "orta vadeli (1-3 ay)" veya "uzak gelecek (3+ ay)",
  "loveMessage": "aşk ve ilişkiler hakkında detaylı mesaj (en az 2 cümle)",
  "careerMessage": "kariyer ve iş hayatı hakkında detaylı mesaj (en az 2 cümle)",
  "generalMessage": "genel hayat mesajı (en az 3 cümle)",
  "luckyNumber": 7,
  "luckyColor": "şans rengi",
  "suggestions": [
    "pratik öneri 1",
    "pratik öneri 2",
    "pratik öneri 3",
    "pratik öneri 4"
  ]
}

KURALLAR:
- Yanıtı yalnızca Türkçe yaz.
- En az 3-5 sembol tespit et (fincan ve tabaktan karışık).
- Her sembolün anlamı en az 2 cümle olmalı.
- luckyNumber 1-99 arasında bir sayı olmalı.
- En az 3 tema belirle.
- 4 pratik ve yaratıcı öneri yaz.
- Hiçbir zaman JSON dışında metin ekleme.
- Eğer görsel bir kahve fincanı değilse, yine de yaratıcı bir şekilde
  görseldeki şekilleri kahve falı gibi yorumla.
''';

  /// Tarz'a göre ek sistem talimatını döner.
  static String _getStyleInstruction(String style) {
    switch (style) {
      case 'Mystical':
        return '''
TARZ: MİSTİK & GİZEMLİ FAL
- Kadim bilgelik, yıldızlar, ay, kozmik enerji ifadelerini kullan.
- "Fincanında kozmik bir harita beliriyor...", "Yıldızların ışığında..." gibi giriş yap.
- Her sembolü spiritüel ve mistik bir derinlikle yorumla.
- Emojiler: ✨🌙🔮🌟💫☕🌌🌠💎
- loveMessage'ı romantik ve kozmik bir tonla yaz.
- careerMessage'ı kader ve yazgı çerçevesinde yaz.
- generalMessage'ı "Evren senin için..." gibi mistik bir tonla bitir.
- Önerilerde tütsü, kristal, meditasyon, ay ışığı gibi spiritüel öğeler olsun.
''';

      case 'Fun':
        return '''
TARZ: EĞLENCELİ & NEŞELİ FAL
- Arkadaş sohbeti gibi sıcak, samimi ve neşeli bir dil kullan.
- "Oooo bu fincan çok konuşkan!", "Kahven müthiş sırlar saklıyor!" gibi giriş yap.
- Bol emoji kullan: 😄🎉☕💃🚀💪🎯🌈🦋🎊
- Sembolleri eğlenceli benzetmelerle yorumla.
- loveMessage'ı heyecanlı ve umut dolu yaz.
- careerMessage'ı motivasyonel ve enerjik yaz.
- generalMessage'ı "Hayat sana gülümsüyor!" gibi pozitif bir tonla bitir.
- Önerilerde eğlenceli aktiviteler, arkadaş buluşmaları, maceralar olsun.
''';

      case 'Psychological':
        return '''
TARZ: DERİN & ANALİTİK FAL
- Sembol psikolojisi ve arketip analizi perspektifinden yaklaş.
- "Fincanındaki semboller bilinçaltının haritasını çiziyor..." gibi giriş yap.
- Jung'un kolektif bilinçdışı, arketip ve gölge benlik kavramlarını entegre et.
- Her sembolü psikolojik bir derinlikle ve farkındalık odaklı yorumla.
- loveMessage'ı bağlanma stilleri ve duygusal farkındalık çerçevesinde yaz.
- careerMessage'ı öz-gerçekleştirme ve potansiyel odaklı yaz.
- generalMessage'ı kişisel gelişim ve öz-keşif vurgusuyla bitir.
- Önerilerde iç gözlem, günlük tutma, farkındalık pratiği gibi öğeler olsun.
''';

      default:
        return _getStyleInstruction('Mystical');
    }
  }

  // ─── Repository Metotları ───────────────────────────────────────────────

  @override
  Future<FortuneReading> readFortune(
    String imageBase64, {
    required String style,
  }) async {
    // Sistem promptunu birleştir
    final systemPrompt = '$_baseSystemPrompt\n${_getStyleInstruction(style)}';

    // Kullanıcı promptu
    final userPrompt =
        '''
Bu kahve fincanı fotoğrafını "$style" tarzında yorumla.
Fincandaki ve tabaktaki tüm şekilleri dikkatlice incele ve fal yorumunu yap.
''';

    // Vision API çağrısı
    final responseText = await _apiClient.generateContentWithImage(
      prompt: userPrompt,
      systemInstruction: systemPrompt,
      imageBase64: imageBase64,
    );

    // JSON parse ve entity dönüşümü
    return _parseResponse(responseText);
  }

  @override
  Future<List<FortuneReading>> getFortuneHistory() async {
    // Geçmiş artık Hive (yerel depolama) üzerinden yönetiliyor.
    // Bu metot geriye dönük uyumluluk için boş liste döner.
    return const [];
  }

  // ─── Yardımcı Metotlar ─────────────────────────────────────────────────

  /// AI'dan gelen JSON yanıtı [FortuneReading] entity'sine dönüştürür.
  ///
  /// Parse hatasında [InvalidResponseException] fırlatır.
  FortuneReading _parseResponse(String responseText) {
    try {
      final Map<String, dynamic> json = jsonDecode(responseText);

      // Zorunlu alanların varlığını kontrol et
      _validateRequiredFields(json);

      return FortuneReading(
        id: 'fortune-${DateTime.now().millisecondsSinceEpoch}',
        readingDate: DateTime.now(),
        symbols: (json['symbols'] as List)
            .map((e) => CoffeeSymbol.fromMap(e as Map<String, dynamic>))
            .toList(),
        themes: List<String>.from(json['themes'] as List),
        timeframe: json['timeframe'] as String,
        loveMessage: json['loveMessage'] as String,
        careerMessage: json['careerMessage'] as String,
        generalMessage: json['generalMessage'] as String,
        luckyNumber: (json['luckyNumber'] as num).toInt(),
        luckyColor: json['luckyColor'] as String,
        suggestions: List<String>.from(json['suggestions'] as List),
      );
    } on AppException {
      rethrow;
    } catch (e) {
      throw InvalidResponseException(
        message:
            'Kahve falı yanıtı işlenemedi. '
            'Fincan sırlarını çözerken bir sorun oluştu… Lütfen tekrar deneyin. ☕',
        originalError: e,
      );
    }
  }

  /// JSON yanıtındaki zorunlu alanları doğrular.
  void _validateRequiredFields(Map<String, dynamic> json) {
    final requiredKeys = [
      'symbols',
      'themes',
      'timeframe',
      'loveMessage',
      'careerMessage',
      'generalMessage',
      'luckyNumber',
      'luckyColor',
      'suggestions',
    ];

    for (final key in requiredKeys) {
      if (!json.containsKey(key) || json[key] == null) {
        throw InvalidResponseException(
          message:
              'AI yanıtında "$key" alanı eksik. '
              'Lütfen tekrar deneyin. ☕',
        );
      }
    }
  }
}
