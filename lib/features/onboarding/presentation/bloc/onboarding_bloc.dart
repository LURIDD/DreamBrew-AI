import 'package:flutter_bloc/flutter_bloc.dart';

// ============================================================
// EVENTS — Onboarding ekranına gönderilen olaylar
// ============================================================

/// Temel Onboarding event sınıfı
abstract class OnboardingEvent {
  const OnboardingEvent();
}

/// Kullanıcı "Başla" butonuna bastığında fırlatılır
class OnboardingStarted extends OnboardingEvent {
  const OnboardingStarted();
}

// ============================================================
// STATES — Onboarding ekranının olası durumları
// ============================================================

/// Temel Onboarding state sınıfı
abstract class OnboardingState {
  const OnboardingState();
}

/// Başlangıç durumu: Ekran yeni yüklenmiş
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Onboarding tamamlandı: Home Dashboard'a yönlendir
class OnboardingComplete extends OnboardingState {
  const OnboardingComplete();
}

// ============================================================
// BLOC — Onboarding iş mantığı
// ============================================================

/// Onboarding ekranının BLoC katmanı.
/// Tek sorumluluğu: "Başla" butonuna basıldığında
/// [OnboardingComplete] state'ine geçmektir.
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc() : super(const OnboardingInitial()) {
    on<OnboardingStarted>(_onStarted);
  }

  /// "Başla" butonuna basınca state'i [OnboardingComplete] yap
  void _onStarted(OnboardingStarted event, Emitter<OnboardingState> emit) {
    emit(const OnboardingComplete());
  }
}
