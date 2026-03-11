/// DreamBrew AI — Home Cubit
///
/// Ana sayfa iş mantığı. Kullanıcının burcunu saklar ve ona göre
/// günlük örnek bir kozmik rehber oluşturur.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local_storage/preferences_service.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeCubitState> {
  final PreferencesService _prefs;

  HomeCubit(this._prefs) : super(const HomeCubitState(dailyGuide: 'Burcunuzu seçerek günlük kozmik mesajınızı alın. ✨')) {
    _init();
  }

  void _init() {
    final savedSign = _prefs.zodiacSign;
    if (savedSign != null) {
      _updateGuide(savedSign);
    }
  }

  /// Kullanıcı yeni bir burç seçtiğinde çağrılır.
  Future<void> setZodiacSign(String sign) async {
    await _prefs.setZodiacSign(sign);
    _updateGuide(sign);
  }

  /// Burca özel örnek bir mesaj üretir ve state'i günceller.
  void _updateGuide(String sign) {
    String guideMessage = '';

    // Basit bir mock yaklaşım (Gerçek uygulamada API'den gelebilir)
    switch (sign.toLowerCase()) {
      case 'koç':
      case 'aries':
        guideMessage = 'Bugün ateşli enerjiniz yüksek! Yeni başlangıçlar için harika bir gün. ♈';
        break;
      case 'boğa':
      case 'taurus':
        guideMessage = 'Maddi konularda şans kapınızı çalabilir. Sabırlı olun. ♉';
        break;
      case 'ikizler':
      case 'gemini':
        guideMessage = 'İletişim becerileriniz bugün parlıyor. Sosyalleşmek size iyi gelecek. ♊';
        break;
      case 'yengeç':
      case 'cancer':
        guideMessage = 'İçgüdülerinize güvenin. Ailevi bağlarınız bugün güçleniyor. ♋';
        break;
      case 'aslan':
      case 'leo':
        guideMessage = 'Sahne sizin! Yaratıcılığınızı özgür bırakın ve parlayın. ♌';
        break;
      case 'başak':
      case 'virgo':
        guideMessage = 'Detaylara olan hakimiyetiniz başarı getirecek. Sağlığınıza özen gösterin. ♍';
        break;
      case 'terazi':
      case 'libra':
        guideMessage = 'Denge ve uyum günü. İlişkilerinizde pozitif gelişmeler yaşanabilir. ♎';
        break;
      case 'akrep':
      case 'scorpio':
        guideMessage = 'Derin düşünceler ve dönüşüm zamanı. Mistik konular ilginizi çekebilir. ♏';
        break;
      case 'yay':
      case 'sagittarius':
        guideMessage = 'Maceraperest ruhunuz canlanıyor. Yeni kültürler veya kafa açıcı sohbetler ufukta. ♐';
        break;
      case 'oğlak':
      case 'capricorn':
        guideMessage = 'Disiplinli çalışmanızın meyvelerini toplama vakti yaklaşıyor. ♑';
        break;
      case 'kova':
      case 'aquarius':
        guideMessage = 'Orijinal fikirlerinizle çevrenizi şaşırtacağınız bir gün. Yeniliklere açık olun. ♒';
        break;
      case 'balık':
      case 'pisces':
        guideMessage = 'Sezgilerinizin çok kuvvetli olduğu bir gündesiniz. Rüyalarınız size mesaj veriyor olabilir. ♓';
        break;
      default:
        guideMessage = 'Evren bugün size sürprizler hazırlıyor. Farkındalığınızı yüksek tutun. ✨';
    }

    emit(state.copyWith(
      zodiacSign: sign,
      dailyGuide: guideMessage,
    ));
  }
}
