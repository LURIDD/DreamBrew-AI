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
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../local_storage/preferences_service.dart';
import '../../features/dream/data/repositories/dream_repository_impl.dart';
import '../../features/dream/domain/repositories/i_dream_repository.dart';
import '../../features/dream/presentation/bloc/dream_bloc.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../theme/theme_cubit.dart';
import '../../features/fortune/data/repositories/fortune_repository_impl.dart';
import '../../features/fortune/domain/repositories/i_fortune_repository.dart';
import '../../features/fortune/presentation/bloc/fortune_bloc.dart';
import '../local_storage/hive_service.dart';
import '../../features/history/data/repositories/hive_history_repository.dart';
import '../../features/history/domain/repositories/i_history_repository.dart';
import '../../features/history/presentation/bloc/history_bloc.dart';

import '../../features/visualization/data/repositories/image_generation_repository.dart';
import '../../features/visualization/domain/repositories/i_image_generation_repository.dart';
import '../../features/visualization/presentation/cubit/visualization_cubit.dart';
import 'package:dio/dio.dart';

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
///   Repository'ler ve servisler için ideal seçimdir.
///
/// - `registerFactory`: Her çağrıda yeni bir örnek oluşturulur.
///   BLoC'lar için ideal seçimdir (her ekran kendi BLoC'unu almalı).
Future<void> setupLocator() async {
  // ─── Core: Ağ Katmanı & Preferences ───────────────────────────────────
  //
  // SharedPreferences'i bekle ve servisi oluştur
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<PreferencesService>(() => PreferencesService(prefs));

  // Dio HTTP istemcisini genel istekler (örn: Görsel üretimi) için kaydet
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 150),
      receiveTimeout: const Duration(seconds: 150),
    ));
    // 1. ADIM: Dio Interceptor ile Loglama
    // İstek ve cevapları, header'ları ve body detaylarını konsolda görmek için:
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
    return dio;
  });

  // Gemini API ile iletişim kuran merkezi HTTP istemcisi.
  // Tüm repository'ler bu istemciyi paylaşır.
  sl.registerLazySingleton<ApiClient>(() => ApiClient());

  // Core Features
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl<PreferencesService>()));

  // Home Feature 
  sl.registerFactory<HomeCubit>(() => HomeCubit(sl<PreferencesService>()));

  // ─── Dream Feature ───────────────────────────────────────────────────────
  //
  // Rüya yorumu repository'si — Gemini LLM API kullanır.
  sl.registerLazySingleton<IDreamRepository>(
    () => DreamRepositoryImpl(sl<ApiClient>()),
  );

  // DreamBloc — her ekran için yeni bir BLoC örneği oluşturulmalıdır
  sl.registerFactory<DreamBloc>(() => DreamBloc(sl<IDreamRepository>()));

  // ─── Fortune Feature ─────────────────────────────────────────────────────
  //
  // Kahve falı repository'si — Gemini Vision API kullanır.
  sl.registerLazySingleton<IFortuneRepository>(
    () => FortuneRepositoryImpl(sl<ApiClient>()),
  );

  // FortuneBloc — her ekran için yeni bir BLoC örneği oluşturulmalıdır
  sl.registerFactory<FortuneBloc>(() => FortuneBloc(sl<IFortuneRepository>()));

  // ─── History Feature ────────────────────────────────────────────────────
  //
  // Hive servisini singleton olarak kaydet (box zaten main'de açıldı)
  final hiveService = HiveService();
  await hiveService.init();
  sl.registerLazySingleton<HiveService>(() => hiveService);

  // Geçmiş repository'si — Hive implementasyonu
  sl.registerLazySingleton<IHistoryRepository>(
    () => HiveHistoryRepository(sl<HiveService>()),
  );

  // HistoryBloc — uygulama genelinde tek bir örnek (Singleton)
  sl.registerLazySingleton<HistoryBloc>(() => HistoryBloc(sl<IHistoryRepository>()));

  // ==========================================================
  // Visualization Feature DI
  //
  // ÖNEMLİ (Kayıt Sıralaması):
  // Cubit oluşturulurken repository'ye ihtiyaç duyduğu için,
  // Repository'nin her zaman Cubit'ten ÖNCE kaydedilmesi zorunludur!
  // Aksi halde get_it bağımlılığı bulamaz ve hata fırlatır.
  // ==========================================================
  
  // 1. Önce Repository'i kaydet (ApiClient üzerinden Gemini API'ye erişir)
  sl.registerLazySingleton<IImageGenerationRepository>(
      () => ImageGenerationRepository(sl<ApiClient>()));
      
  // 2. Sonra Cubit'i kaydet (Repository'i sl üzerinden alır)
  sl.registerFactory<VisualizationCubit>(
      () => VisualizationCubit(sl<IImageGenerationRepository>()));
}
