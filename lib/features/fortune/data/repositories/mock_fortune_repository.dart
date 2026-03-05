/// DreamBrew AI — Sahte Kahve Falı Repository Implementasyonu (Data Katmanı)
///
/// Gerçek Vision AI servisi entegre edilene kadar bu sınıf kullanılır.
/// [IFortuneRepository] sözleşmesini implemente eder ve 2 saniyelik gecikmeyle
/// mistik, eğlenceli Türkçe sahte veriler döner.
///
/// UI ekibi bu sınıf aracılığıyla gerçek API varmış gibi geliştirme yapabilir.
library;

import '../../domain/entities/fortune_reading.dart';
import '../../domain/repositories/i_fortune_repository.dart';

/// [IFortuneRepository]'nin mock (sahte) implementasyonu.
///
/// DI container'a kayıtlıdır; gerçek [RealFortuneRepository] hazır olduğunda
/// yalnızca `service_locator.dart` içindeki kayıt değiştirilerek takas edilir.
final class MockFortuneRepository implements IFortuneRepository {
  /// --- Sabit Mock Veri Havuzu ---
  ///
  /// Gerçek kahve falcısından dönüyormuş gibi tasarlanmış iki farklı senaryo.

  static final _mockReadings = <FortuneReading>[
    FortuneReading(
      id: 'fortune-mock-001',
      readingDate: DateTime(2026, 3, 2, 10, 30),
      symbols: [
        CoffeeSymbol(
          name: 'kuş',
          position: 'fincan',
          meaning:
              'Fincanının ağzına yakın konuşlanan bu kuş, çok yakın zamanda '
              'alacağın bir haberin müjdecisidir. Uzaktan gelen bu haber seni '
              'şaşırtacak ama yüzünü güldürecek. Mesajlarını kontrol etmeyi unutma! 🐦',
        ),
        CoffeeSymbol(
          name: 'yol',
          position: 'fincan',
          meaning:
              'Önünde iki yol ayrımı görünüyor. Kalbinin sesini dinle; aklın seni '
              'bir yöne, ruhun başka bir yöne çekiyor olabilir. Doğru yol, '
              'içinde hafiflik hissettiren yoldur.',
        ),
        CoffeeSymbol(
          name: 'yıldız',
          position: 'tabak',
          meaning:
              'Tabakta beliren yıldız, korunan ve şans getiren bir işarettir. '
              'Bu yıldız senin için parlıyor; dileklerini gökyüzüne bırakmaktan çekinme!',
        ),
        CoffeeSymbol(
          name: 'kalp',
          position: 'tabak',
          meaning:
              'Tabakta net şekilde oluşan kalp, duygusal düzlemde güzel gelişmelere '
              'işaret eder. Beklenmedik bir anda, beklenmedik bir kişiden sıcaklık göreceksin.',
        ),
      ],
      themes: ['haber', 'yolculuk', 'aşk', 'şans'],
      timeframe: 'yakın gelecek (1-3 hafta)',
      loveMessage:
          '💕 Fincanında beliren kalp sembolleri, duygusal hayatında güzel bir dönemin '
          'eşiğinde olduğunu gösteriyor. Eğer bekleyiş içindeysen, bu bekleme yakında '
          'sona erecek. Kalbin söylemek istediklerini sakın içinde tutma.',
      careerMessage:
          '💼 Kahvende gördüğüm yol sembolü, iş hayatında bir karar almak üzere '
          'olduğunun işareti. Bu kararı almaktan çekinme; yıldız sembolü şansın '
          'seninle olduğunu söylüyor. Fırsatı kaçırma!',
      generalMessage:
          '🌟 Fincanın genel enerjisi son derece pozitif ve hareketli. Kuş sembolü '
          'sana bir şeylerin değişeceğini müjdelerken, yıldız şansın kapına dayandığını '
          'fısıldıyor. Bu dönemi iyi değerlendir ve cesaretini asla kaybetme.',
      luckyNumber: 7,
      luckyColor: 'altın sarısı',
      suggestions: [
        'Bu hafta yeni tanışmalara açık ol; yanında beklenmedik kapılar açacak biri çıkabilir.',
        'Altın sarısı bir aksesuar ya da kıyafet parçası şansını artıracak.',
        'Ertelediğin bir iletişimi bugün başlat; doğru zaman şimdi.',
        "7 rakamını hayatına davet et: Bugün 7'de bir şeye niyet et ya da 7 kez derin nefes al.",
      ],
    ),
    FortuneReading(
      id: 'fortune-mock-002',
      readingDate: DateTime(2026, 3, 4, 15, 00),
      symbols: [
        CoffeeSymbol(
          name: 'ağaç',
          position: 'fincan',
          meaning:
              'Fincanının dibinde kök salmış bu ağaç, sağlam temellerin olduğunu '
              'söylüyor. Geçmişte attığın adımlar seni bugün ayakta tutuyor. '
              'Dalların ne kadar uzasa da kökler seni besliyor.',
        ),
        CoffeeSymbol(
          name: 'balık',
          position: 'fincan',
          meaning:
              'Balık sembolü, bolluğun ve bereketin habercisidir. Özellikle '
              'maddi konularda beklediğinden fazlası kapına gelecek. '
              'Şükranla karşıla, elde tutmaya çalışma — akan suya engel olma.',
        ),
        CoffeeSymbol(
          name: 'dağ',
          position: 'tabak',
          meaning:
              'Tabakta çıkan dağ, önünde bir engel ya da zorluk olduğuna işaret eder. '
              'Ama dağlar aşılmak için var; bu engel seni daha güçlü kılacak bir '
              'deneyim olacak. Zirveye çıktığında panorama muhteşem olacak.',
        ),
        CoffeeSymbol(
          name: 'yüzük',
          position: 'tabak',
          meaning:
              'Yüzük, bağlılık ve söz anlamına gelir. Yakın çevrendeki önemli '
              'bir ilişkide kalıcı bir bağ kurma ya da güçlendirme dönemi yaklaşıyor.',
        ),
      ],
      themes: ['büyüme', 'bolluk', 'aşılacak engeller', 'bağlılık'],
      timeframe: 'orta vadeli (1-3 ay)',
      loveMessage:
          '💍 Tabakta beliren yüzük sembolü, ilişkilerinde derin bir bağlılık '
          'dönemine girdiğine işaret ediyor. Mevcut bir ilişki derinleşebilir ya da '
          'yeni ve kalıcı bir bağ doğabilir. Kalbini açık tut.',
      careerMessage:
          '🌳 Fincanındaki ağaç, iş hayatında attığın köklerin artık meyvesini '
          'vermek üzere olduğunu gösteriyor. Sabırlı ol; balık sembolü maddi '
          'anlamda güzel haberlerin yolda olduğunu söylüyor.',
      generalMessage:
          '⛰️ Önünde bir dağ var ama korkma — güçlü köklerin seni tutacak ve '
          'bolluğun seni besleyecek. Bu dönem hem zorlukların hem de en güzel '
          'sürprizlerin bir arada yaşandığı bir dönem. Teslim ol ama pes etme.',
      luckyNumber: 3,
      luckyColor: 'zümrüt yeşili',
      suggestions: [
        'Bir bitki ya da ağaç fide al ve bakımına özen göster; bu niyet sana bereket getirecek.',
        'Değer verdiğin birine minnettarlığını bugün söyle.',
        'Önündeki en büyük zorluğu küçük adımlara bölerek planlamaya başla.',
        'Zümrüt yeşili renk bu hafta hem şansını hem enerjini yükseltecek.',
      ],
    ),
  ];

  @override
  Future<FortuneReading> readFortune(String imageBase64) async {
    // Gerçek Vision AI gecikmesini simüle et
    await Future<void>.delayed(const Duration(seconds: 2));

    // Tahmin amaçlı: görselin boyutuna göre farklı mock döndür
    // (Production'da burası gerçek Vision API çağrısı olacak)
    final index = imageBase64.length % _mockReadings.length;

    return _mockReadings[index].copyWith(
      id: 'fortune-${DateTime.now().millisecondsSinceEpoch}',
      readingDate: DateTime.now(),
    );
  }

  @override
  Future<List<FortuneReading>> getFortuneHistory() async {
    // Geçmiş veri yükleme gecikmesini simüle et
    await Future<void>.delayed(const Duration(seconds: 2));
    return List.unmodifiable(_mockReadings);
  }
}
