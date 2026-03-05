/// DreamBrew AI — Dependency Injection Kurulumu
///
/// Bu dosya, uygulamanın tüm servis ve repository bağımlılıklarını
/// [get_it] paketi aracılığıyla yönetir.
///
/// Kullanım:
/// ```dart
/// // Kayıt:
/// setupLocator();
///
/// // Erişim (BLoC, ViewModel veya Widget içinden):
/// final dreamRepo = sl<IDreamRepository>();
/// final fortuneRepo = sl<IFortuneRepository>();
/// ```
library;

import 'package:get_it/get_it.dart';

import '../../features/dream/data/repositories/mock_dream_repository.dart';
import '../../features/dream/domain/repositories/i_dream_repository.dart';
import '../../features/dream/presentation/bloc/dream_bloc.dart';
import '../../features/fortune/data/repositories/mock_fortune_repository.dart';
import '../../features/fortune/domain/repositories/i_fortune_repository.dart';

/// Global service locator örneği.
///
/// Uygulamanın her yerinden `sl<T>()` şeklinde erişilir.
final GetIt sl = GetIt.instance;

/// Tüm bağımlılıkları [sl] üzerine kaydeder.
///
/// Bu fonksiyon [main()] içinde, [runApp] çağrısından önce çağrılmalıdır.
///
/// ---
/// ### Kayıt Stratejisi
///
/// - `registerLazySingleton`: İlk kez `sl<T>()` çağrıldığında örnek oluşturulur
///   ve uygulama boyunca o örnek yeniden kullanılır.
///   Repository'ler için ideal seçimdir.
///
/// ### Mock → Real Geçişi
///
/// AI servisleri hazır olduğunda yalnızca bu dosyadaki ilgili satırı değiştir:
/// ```dart
/// // Eski (Mock):
/// sl.registerLazySingleton<IDreamRepository>(() => MockDreamRepository());
///
/// // Yeni (Real):
/// sl.registerLazySingleton<IDreamRepository>(() => RealDreamRepository(sl<DioClient>()));
/// ```
Future<void> setupLocator() async {
  // ─── Dream Feature ───────────────────────────────────────────────────────
  //
  // Rüya yorumu repository'si.
  // Gerçek LLM entegrasyonuna kadar mock kullanılır.
  sl.registerLazySingleton<IDreamRepository>(() => MockDreamRepository());

  // DreamBloc — her ekran için yeni bir BLoC örneği oluşturulmalıdır
  sl.registerFactory<DreamBloc>(() => DreamBloc(sl<IDreamRepository>()));

  // ─── Fortune Feature ─────────────────────────────────────────────────────
  //
  // Kahve falı repository'si.
  // Gerçek Vision AI entegrasyonuna kadar mock kullanılır.
  sl.registerLazySingleton<IFortuneRepository>(() => MockFortuneRepository());
}
