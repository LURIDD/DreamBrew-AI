import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

/// DreamBrew AI — Uygulama giriş noktası
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependency Injection: tüm repository ve servisleri kaydet
  await setupLocator();

  // Durum çubuğunu saydam ve açık ikonlu yap (karanlık tema uyumu)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Yalnızca dikey yönelimi destekle
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) => runApp(const DreamBrewApp()));
}

/// Uygulamanın köküdür. Tema ve router burada bağlanır.
class DreamBrewApp extends StatelessWidget {
  const DreamBrewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'DreamBrew AI',
      debugShowCheckedModeBanner: false,

      // Material 3 karanlık tema
      theme: AppTheme.darkTheme,

      // go_router yapılandırması
      routerConfig: AppRouter.router,
    );
  }
}
