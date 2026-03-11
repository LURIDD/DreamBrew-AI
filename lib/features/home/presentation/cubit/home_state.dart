/// DreamBrew AI — Home State
///
/// Ana sayfanın durumunu, seçilen burcu ve günlük kozmik rehberi barındırır.
library;

class HomeCubitState {
  final String? zodiacSign;
  final String dailyGuide;

  const HomeCubitState({
    this.zodiacSign,
    required this.dailyGuide,
  });

  HomeCubitState copyWith({
    String? zodiacSign,
    String? dailyGuide,
  }) {
    return HomeCubitState(
      zodiacSign: zodiacSign ?? this.zodiacSign,
      dailyGuide: dailyGuide ?? this.dailyGuide,
    );
  }
}
