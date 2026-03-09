/// DreamBrew AI — Rüya Yorumu BLoC Katmanı
///
/// Bu dosya, rüya yorumu modülünün iş mantığını yönetir.
/// [IDreamRepository] arayüzü üzerinden mock ya da gerçek servisle çalışır.
/// Event → BLoC → State akışını takip eder.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/network/app_exceptions.dart';
import '../../domain/entities/dream_reading.dart';
import '../../domain/repositories/i_dream_repository.dart';

// ============================================================
// EVENTS — Rüya modülüne gönderilen olaylar
// ============================================================

/// Temel Dream event sınıfı
abstract class DreamEvent {
  const DreamEvent();
}

/// Kullanıcı rüya metnini gönderdiğinde tetiklenir.
///
/// [dreamText] — Kullanıcının yazdığı rüya anlatımı.
/// [style] — Seçilen yorum tarzı (Mystical, Fun, Psychological).
class SubmitDreamEvent extends DreamEvent {
  final String dreamText;
  final String style;

  const SubmitDreamEvent({required this.dreamText, required this.style});
}

// ============================================================
// STATES — Rüya modülünün olası durumları
// ============================================================

/// Temel Dream state sınıfı
abstract class DreamState {
  const DreamState();
}

/// Başlangıç durumu — henüz bir işlem yapılmadı
class DreamInitial extends DreamState {
  const DreamInitial();
}

/// Rüya yorumlanıyor — yükleniyor göstergesi gösterilmeli
class DreamLoading extends DreamState {
  const DreamLoading();
}

/// Yorum başarıyla tamamlandı — sonuç ekranına geçilebilir
class DreamSuccess extends DreamState {
  /// Yapay zekadan dönen (şimdilik mock) rüya yorumu
  final DreamReading reading;

  const DreamSuccess({required this.reading});
}

/// Hata oluştu — kullanıcıya hata mesajı gösterilmeli
class DreamError extends DreamState {
  /// Kullanıcıya gösterilecek hata açıklaması
  final String message;

  const DreamError({required this.message});
}

// ============================================================
// BLOC — Rüya Yorumu İş Mantığı
// ============================================================

/// Rüya Yorumu modülünün BLoC katmanı.
///
/// [IDreamRepository] üzerinden `interpretDream` çağrısı yapar.
/// DI (get_it) aracılığıyla repository sağlanır; mock ↔ real
/// geçişi BLoC'u etkilemez.
class DreamBloc extends Bloc<DreamEvent, DreamState> {
  final IDreamRepository _repository;

  DreamBloc(this._repository) : super(const DreamInitial()) {
    on<SubmitDreamEvent>(_onSubmitDream);
  }

  /// Rüya metnini repository'e gönderir ve sonucu state olarak yayar.
  Future<void> _onSubmitDream(
    SubmitDreamEvent event,
    Emitter<DreamState> emit,
  ) async {
    emit(const DreamLoading());

    try {
      final reading = await _repository.interpretDream(
        event.dreamText,
        style: event.style,
      );
      emit(DreamSuccess(reading: reading));
    } on AppException catch (e) {
      // Custom exception'lar zaten kullanıcı dostu mesaj taşır
      emit(DreamError(message: e.message));
    } on Exception {
      // Beklenmeyen hatalar için genel mesaj — teknik detay UI'a sızmaz
      emit(
        const DreamError(
          message:
              'Rüyanız yorumlanırken kozmik bir engele takıldık… '
              'Lütfen tekrar deneyin. 🔮',
        ),
      );
    }
  }
}
