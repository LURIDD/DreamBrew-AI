import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// EVENTS — Home ekranına gönderilen olaylar
// ============================================================

/// Temel Home event sınıfı
abstract class HomeEvent {
  const HomeEvent();
}

/// Home ekranı açıldığında fırlatılır; selamlama metnini hesaplar
class HomeLoadRequested extends HomeEvent {
  const HomeLoadRequested();
}

// ============================================================
// STATES — Home ekranının olası durumları
// ============================================================

/// Temel Home state sınıfı
abstract class HomeState {
  const HomeState();
}

/// Başlangıç / yükleniyor durumu
class HomeInitial extends HomeState {
  const HomeInitial();
}

/// Veri yüklendi durumu
class HomeLoaded extends HomeState {
  /// Günün saatine göre belirlenen selamlama metni
  final String greeting;

  const HomeLoaded({required this.greeting});
}

// ============================================================
// BLOC — Home iş mantığı
// ============================================================

/// Home Dashboard ekranının BLoC katmanı.
/// Günün saatine göre selamlama metnini üretir.
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<HomeLoadRequested>(_onLoadRequested);
  }

  /// Günün saatine göre selamlama metni üretir
  void _onLoadRequested(HomeLoadRequested event, Emitter<HomeState> emit) {
    final hour = DateTime.now().hour;

    // Sabah: 05:00 - 11:59 | Öğleden sonra: 12:00 - 17:59
    // Akşam: 18:00 - 23:59 | Gece: 00:00 - 04:59
    final greeting = switch (hour) {
      >= 5 && < 12 => 'Good Morning',
      >= 12 && < 18 => 'Good Afternoon',
      >= 18 && < 24 => 'Good Evening',
      _ => 'Good Night',
    };

    emit(HomeLoaded(greeting: greeting));
  }
}
