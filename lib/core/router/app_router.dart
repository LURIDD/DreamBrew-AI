import 'package:go_router/go_router.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

/// DreamBrew AI uygulama yönlendirme yapılandırması.
/// go_router kullanılarak Onboarding → Home akışı tanımlanmıştır.
class AppRouter {
  AppRouter._();

  // Rota isimleri — navigasyonda string literal kullanmaktan kaçınmak için
  static const String onboarding = '/onboarding';
  static const String home = '/home';

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
    ],
  );
}
