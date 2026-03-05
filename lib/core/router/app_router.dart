import 'package:go_router/go_router.dart';
import '../../features/dream/domain/entities/dream_reading.dart';
import '../../features/dream/presentation/pages/dream_input_page.dart';
import '../../features/dream/presentation/pages/dream_result_page.dart';
import '../../features/dream/presentation/pages/dream_art_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// DreamBrew AI uygulama yönlendirme yapılandırması.
/// go_router kullanılarak tüm ekran akışları tanımlanmıştır.
class AppRouter {
  AppRouter._();

  // Rota isimleri — navigasyonda string literal kullanmaktan kaçınmak için
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String dreamInput = '/dream-input';
  static const String dreamResult = '/dream-result';
  static const String dreamArt = '/dream-art';

  /// Uygulamanın tek GoRouter örneği
  static final GoRouter router = GoRouter(
    /// İlk açılışta Onboarding ekranı gösterilir
    initialLocation: onboarding,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: home,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),

      // ─── Dream Feature Rotaları ────────────────────────────────
      GoRoute(
        path: dreamInput,
        name: 'dreamInput',
        builder: (context, state) => const DreamInputPage(),
      ),
      GoRoute(
        path: dreamResult,
        name: 'dreamResult',
        builder: (context, state) {
          // DreamReading objesini extra parametresi olarak al
          final reading = state.extra as DreamReading;
          return DreamResultPage(reading: reading);
        },
      ),
      GoRoute(
        path: dreamArt,
        name: 'dreamArt',
        builder: (context, state) {
          // DreamReading opsiyonel olarak gelebilir
          final reading = state.extra as DreamReading?;
          return DreamArtPage(reading: reading);
        },
      ),
    ],
  );
}
