import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/local_storage/saved_reading.dart';
import 'core/local_storage/saved_reading_adapter.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/history/presentation/bloc/history_bloc.dart';

/// DreamBrew AI — Uygulama giriş noktası
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ortam değişkenlerini yükle (.env dosyasından API anahtarları)
  await dotenv.load(fileName: '.env');

  // Hive yerel veritabanını başlat
  await Hive.initFlutter();
  Hive.registerAdapter(SavedReadingAdapter());
  await Hive.openBox<SavedReading>('saved_readings');

  // Dependency Injection: tüm repository ve servisleri kaydet
  await setupLocator();


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
    return MultiBlocProvider(
      providers: [
        BlocProvider<HistoryBloc>(
          create: (_) => sl<HistoryBloc>()..add(const LoadHistory()),
        ),
        BlocProvider<ThemeCubit>(
          create: (_) => sl<ThemeCubit>(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp.router(
            title: 'DreamBrew AI',
            debugShowCheckedModeBanner: false,

            // Tema ayarları (Dinamik)
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,

            // go_router yapılandırması
            routerConfig: AppRouter.router,
          );
        },
      ),
    );
  }
}
