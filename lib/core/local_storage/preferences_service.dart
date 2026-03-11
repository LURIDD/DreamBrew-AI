/// DreamBrew AI — Preferences Service
///
/// Uygulama ayarlarını, ilk giriş durumunu, tema tercihini ve 
/// kullanıcı burcunu [SharedPreferences] kullanarak yerel cihazda saklar.
library;

import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  final SharedPreferences _prefs;

  PreferencesService(this._prefs);

  // --- Anahtarlar (Keys) ---
  static const String _keyIsFirstOpen = 'is_first_open';
  static const String _keyZodiacSign = 'user_zodiac_sign';
  static const String _keyThemeMode = 'app_theme_mode';

  // --- İlk Giriş (Onboarding) Kontrolü ---
  
  /// Kullanıcı uygulamayı ilk kez mi açıyor? 
  /// Değer atanmamışsa true döner.
  bool get isFirstOpen {
    return _prefs.getBool(_keyIsFirstOpen) ?? true;
  }

  /// İlk giriş tamamlandı olarak işaretler.
  Future<void> setFirstOpen(bool value) async {
    await _prefs.setBool(_keyIsFirstOpen, value);
  }

  // --- Burç Kaydetme ---

  /// Kullanıcının daha önce seçtiği burcu döndürür. Yoksa null döner.
  String? get zodiacSign {
    return _prefs.getString(_keyZodiacSign);
  }

  /// Kullanıcının burcunu kaydeder.
  Future<void> setZodiacSign(String sign) async {
    await _prefs.setString(_keyZodiacSign, sign);
  }

  // --- Tema Kaydetme ---

  /// Seçilen temanın (light/dark) index'ini tutar.
  /// Örneğin ThemeMode index (0: system, 1: light, 2: dark)
  /// Varsayılan sistem: 0 veya dark: 2 olabilir (Proje bazında Dark istendiğinden varsayılan 2 diyebiliriz).
  int get themeModeIndex {
    return _prefs.getInt(_keyThemeMode) ?? 2; // Varsayılan: Dark Tema
  }

  /// Seçilen temayı kaydeder.
  Future<void> setThemeModeIndex(int index) async {
    await _prefs.setInt(_keyThemeMode, index);
  }
}
