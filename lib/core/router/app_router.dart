/// DreamBrew AI — Uygulama Yönlendirme Yapılandırması
///
/// go_router + ShellRoute ile sekme tabanlı navigasyon.
/// Ana sekmeler (Home, Settings) → MainLayout içinde kalır.
/// Dream/Fortune/Detail/History ekranları → ShellRoute dışında, navbar olmadan açılır.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/dream/domain/entities/dream_reading.dart';
import '../../features/dream/presentation/pages/dream_input_page.dart';
import '../../features/dream/presentation/pages/dream_result_page.dart';
import '../../features/dream/presentation/pages/dream_art_page.dart';
import '../../features/fortune/domain/entities/fortune_reading.dart';
import '../../features/fortune/presentation/pages/fortune_upload_page.dart';
import '../../features/fortune/presentation/pages/fortune_result_page.dart';
import '../../core/local_storage/saved_reading.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/history/presentation/pages/reading_detail_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../widgets/main_layout.dart';

/// DreamBrew AI uygulama yönlendirme yapılandırması.
/// go_router + StatefulShellRoute kullanılarak sekme tabanlı navigasyon.
class AppRouter {
  AppRouter._();

  // Rota isimleri — navigasyonda string literal kullanmaktan kaçınmak için
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dreamInput = '/dream-input';
  static const String dreamResult = '/dream-result';
  static const String dreamArt = '/dream-art';
  static const String fortuneUpload = '/fortune-upload';
  static const String fortuneResult = '/fortune-result';
  static const String history = '/history';
  static const String readingDetail = '/reading-detail';
  static const String settings = '/settings';

  // ─── Navigasyon anahtarı ──────────────────────────────────
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();

  /// Uygulamanın tek GoRouter örneği
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,

    /// İlk açılışta Onboarding ekranı gösterilir
    initialLocation: onboarding,
    debugLogDiagnostics: false,
    routes: [
      // ─── Onboarding (shell dışı) ────────────────────────────
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // ─── Ana Sekme Yapısı (ShellRoute) ──────────────────────
      //
      // Home ve Settings sekmeleri MainLayout içinde gösterilir.
      // Notched Bottom App Bar bu sekmeler arasında kalıcıdır.
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainLayout(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: home,
                name: 'home',
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),

          // Branch 1: Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: settings,
                name: 'settings',
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),

      // ─── History (ShellRoute DIŞI) ──────────────────────────
      //
      // History artık alt bardan kaldırıldı.
      // Home ekranındaki History butonuyla push ile açılır.
      GoRoute(
        path: history,
        name: 'history',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HistoryPage(),
      ),

      // ─── Dream Feature Rotaları (ShellRoute DIŞI) ───────────
      //
      // Bu ekranlar tam ekran açılır, navbar görünmez.
      GoRoute(
        path: dreamInput,
        name: 'dreamInput',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const DreamInputPage(),
      ),
      GoRoute(
        path: dreamResult,
        name: 'dreamResult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reading = state.extra as DreamReading;
          return DreamResultPage(reading: reading);
        },
      ),
      GoRoute(
        path: dreamArt,
        name: 'dreamArt',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reading = state.extra as DreamReading?;
          return DreamArtPage(reading: reading);
        },
      ),

      // ─── Fortune Feature Rotaları (ShellRoute DIŞI) ─────────
      GoRoute(
        path: fortuneUpload,
        name: 'fortuneUpload',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FortuneUploadPage(),
      ),
      GoRoute(
        path: fortuneResult,
        name: 'fortuneResult',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reading = state.extra as FortuneReading;
          return FortuneResultPage(reading: reading);
        },
      ),

      // ─── History Detail (ShellRoute DIŞI) ───────────────────
      GoRoute(
        path: readingDetail,
        name: 'readingDetail',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final reading = state.extra as SavedReading;
          return ReadingDetailPage(reading: reading);
        },
      ),
    ],
  );
}
