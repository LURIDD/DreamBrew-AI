/// DreamBrew AI — Theme Cubit
///
/// Uygulamanın temasını yönetir (Light/Dark mode).
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../local_storage/preferences_service.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  final PreferencesService _prefs;

  // Başlangıçta SharedPreferences'den okunan indexe göre ThemeMode oluştururuz.
  // getThemeMode(_prefs.themeModeIndex)
  ThemeCubit(this._prefs) : super(_getThemeMode(_prefs.themeModeIndex));

  /// Temayı ThemeMode.light veya ThemeMode.dark olarak değiştirir.
  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setThemeModeIndex(mode.index);
    emit(mode);
  }

  /// Mevcut temayı tam tersine çevirir (dark -> light, light -> dark).
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }

  static ThemeMode _getThemeMode(int index) {
    // ThemeMode.system = 0, light = 1, dark = 2
    switch (index) {
      case 1:
        return ThemeMode.light;
      case 2:
        return ThemeMode.dark;
      default:
        // Varsayılan olarak projede Dark Mode kullanılıyor.
        return ThemeMode.dark; 
    }
  }
}
