/// DreamBrew AI — Sahte Rüya Repository Implementasyonu (Data Katmanı)
///
/// Gerçek LLM servisi entegre edilene kadar bu sınıf kullanılır.
/// [IDreamRepository] sözleşmesini implemente eder ve 2 saniyelik gecikmeyle
/// mistik, eğlenceli Türkçe sahte veriler döner.
///
/// UI ekibi bu sınıf aracılığıyla gerçek API varmış gibi geliştirme yapabilir.
library;

import '../../domain/entities/dream_reading.dart';
import '../../domain/repositories/i_dream_repository.dart';

/// [IDreamRepository]'nin mock (sahte) implementasyonu.
///
/// DI container'a kayıtlıdır; gerçek [RealDreamRepository] hazır olduğunda
/// yalnızca `service_locator.dart` içindeki kayıt değiştirilerek takas edilir.
final class MockDreamRepository implements IDreamRepository {
  /// --- Sabit Mock Veri Havuzu ---
  ///
  /// Gerçek AI'dan dönüyormuş gibi tasarlanmış iki farklı senaryo.

  static final _mockReadings = <DreamReading>[
    DreamReading(
      id: 'dream-mock-001',
      dreamDescription:
          'Mavi bir denizin üzerinde uçuyordum. Altımda dalgalar parıldıyordu ve '
          'uzaktan bir kuş sürüsü bana katıldı. Sonra aniden bulutların üstüne çıktım.',
      interpretedAt: DateTime(2026, 3, 1, 22, 15),
      themes: ['özgürlük', 'yükseliş', 'dönüşüm'],
      symbols: [
        DreamSymbol(
          symbol: 'mavi deniz',
          meaning:
              'Bilinçdışının derin katmanlarını simgeler. Duygusal olarak '
              'berraklaşma dönemine giriyorsun; içindeki fırtınalar dinmek üzere.',
        ),
        DreamSymbol(
          symbol: 'uçmak',
          meaning:
              'Kısıtlarından kurtulma arzunu yansıtır. Yakın zamanda seni '
              'zorlayan bir durumdan sıyrılma fırsatı doğacak. Kanatlarını aç!',
        ),
        DreamSymbol(
          symbol: 'kuş sürüsü',
          meaning:
              'Topluluk ve aitlik enerjisini taşır. Yeni bir grup ya da toplulukla '
              'bağ kuracaksın; bu ilişkiler seni beklenmedik yerlere taşıyacak.',
        ),
        DreamSymbol(
          symbol: 'bulutlar',
          meaning:
              'Henüz netleşmemiş planları ve belirsizlikleri temsil eder. '
              'Sabırlı ol; sis dağılınca manzara muhteşem olacak.',
        ),
      ],
      emotionalTone: 'özgür ve umut dolu',
      suggestions: [
        'Bu hafta içinde seni kısıtladığını hissettiğin bir alışkanlığı bırakmayı dene.',
        'Doğayla temas kuran bir aktivite planla; yürüyüş ya da açık hava meditasyonu sana iyi gelecek.',
        'Rüyandaki kuş sürüsünden ilham al: Güvendiğin insanlarla zaman geçir ve fikirlerini paylaş.',
        'Mavi rengi bu hafta üzerinde taşı; sezgini güçlendirecek.',
      ],
      overallMessage:
          '✨ Evren sana net bir mesaj gönderiyor: Artık eski kalıpların içinde kalma zamanın '
          'geçti. Bu rüya, ruhunun özgürlük ve ilerleme çığlığıdır. Önündeki kapılar açılmaya '
          'hazır — tek yapman gereken adım atmak. Cesur ol, yıldız tozu içinde yürümekten '
          'çekinme! 🌊',
    ),
    DreamReading(
      id: 'dream-mock-002',
      dreamDescription:
          'Eski bir kütüphanedeyim. Raflar tavana kadar uzanıyor ve her kitabın '
          'sırtında benim adım yazıyor. Bir mum ışığında okumaya çalışıyorum.',
      interpretedAt: DateTime(2026, 3, 3, 03, 42),
      themes: ['bilgelik arayışı', 'öz keşif', 'geçmiş'],
      symbols: [
        DreamSymbol(
          symbol: 'eski kütüphane',
          meaning:
              'Birikmiş deneyimlerini ve içsel bilgeliğini simgeler. Şu an geçmişinden '
              'ders çıkarma ve bu dersleri geleceğe taşıma sürecinin tam ortasındasın.',
        ),
        DreamSymbol(
          symbol: 'adının yazılı olduğu kitaplar',
          meaning:
              'Anlatılmayı bekleyen bir hikâyen var! İçinde tuttuğun düşünceler, '
              'fikirler ya da bir sanatsal proje — artık onları dünyayla buluşturma zamanı.',
        ),
        DreamSymbol(
          symbol: 'mum ışığı',
          meaning:
              'Karanlıkta bile yolunu bulan iç rehberini temsil eder. Sezgin şu '
              'sıralar her zamankinden daha güçlü; ona kulak ver.',
        ),
      ],
      emotionalTone: 'meraklı ve içe dönük',
      suggestions: [
        'Bir günlük tutmaya başla ya da var olan günlüğüne bugün yaz; içindeki sözcükler çıkmak istiyor.',
        'Okumayı ertelediğin bir kitabı bu hafta başlat.',
        'Sessiz bir ortamda en az 10 dakika düşüncelerinle baş başa kal.',
        'Geçmişte yarım bıraktığın bir projeyi gün yüzüne çıkar; vakti geldi.',
      ],
      overallMessage:
          '📚 Kütüphane rüyan, içindeki bilgeliğin kapılarını aralıyor. Her rafta '
          'seni bekleyen potansiyel var. Bu sessiz rüya aslında güçlü bir davet: '
          'Kendi hikâyeni yazmaktan artık kaçınma. Senin adın bu kitapların sırtında '
          'çünkü sen bu hikayeleri yaşamak için buradasın. ✨',
    ),
  ];

  @override
  Future<DreamReading> interpretDream(String dreamText) async {
    // Gerçek AI gecikmesini simüle et
    await Future<void>.delayed(const Duration(seconds: 2));

    // Tahmin amaçlı: girilen metne göre farklı mock döndür
    // (Production'da burası gerçek LLM çağrısı olacak)
    final index = dreamText.length % _mockReadings.length;

    return _mockReadings[index].copyWith(
      id: 'dream-${DateTime.now().millisecondsSinceEpoch}',
      dreamDescription: dreamText,
      interpretedAt: DateTime.now(),
    );
  }

  @override
  Future<List<DreamReading>> getDreamHistory() async {
    // Geçmiş veri yükleme gecikmesini simüle et
    await Future<void>.delayed(const Duration(seconds: 2));
    return List.unmodifiable(_mockReadings);
  }
}
