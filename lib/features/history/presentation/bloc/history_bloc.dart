/// DreamBrew AI — Geçmiş & Favoriler BLoC Katmanı
///
/// Kaydedilmiş okumaların yüklenmesi, favori toggle, silme gibi
/// tüm iş mantığını yönetir.
/// Event → BLoC → State akışını takip eder.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local_storage/saved_reading.dart';
import '../../domain/repositories/i_history_repository.dart';

// ============================================================
// EVENTS — Geçmiş modülüne gönderilen olaylar
// ============================================================

/// Temel History event sınıfı
abstract class HistoryEvent {
  const HistoryEvent();
}

/// Tüm okumaları yükle
class LoadHistory extends HistoryEvent {
  const LoadHistory();
}

/// Yeni bir okumayı kaydet
class SaveReadingEvent extends HistoryEvent {
  final SavedReading reading;
  const SaveReadingEvent({required this.reading});
}

/// Bir okumanın favori durumunu değiştir
class ToggleFavoriteEvent extends HistoryEvent {
  final String readingId;
  const ToggleFavoriteEvent({required this.readingId});
}

/// Bir okumayı sil
class DeleteReadingEvent extends HistoryEvent {
  final String readingId;
  const DeleteReadingEvent({required this.readingId});
}

/// Tüm okumaları sil (Ayarlar → Verileri Temizle)
class ClearAllReadingsEvent extends HistoryEvent {
  const ClearAllReadingsEvent();
}

// ============================================================
// STATES — Geçmiş modülünün durumları
// ============================================================

/// Temel History state sınıfı
abstract class HistoryState {
  const HistoryState();
}

/// Başlangıç durumu — henüz veri yüklenmedi
class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

/// Veriler yükleniyor
class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

/// Veriler başarıyla yüklendi
///
/// [dreamReadings] ve [fortuneReadings] ayrı listeler halinde tutulur
/// böylece TabBar içinde kolayca gösterilebilir.
class HistoryLoaded extends HistoryState {
  final List<SavedReading> dreamReadings;
  final List<SavedReading> fortuneReadings;

  const HistoryLoaded({
    required this.dreamReadings,
    required this.fortuneReadings,
  });

  /// Toplam okuma sayısı sıfır mı?
  bool get isEmpty => dreamReadings.isEmpty && fortuneReadings.isEmpty;
}

/// Hata oluştu
class HistoryError extends HistoryState {
  final String message;
  const HistoryError({required this.message});
}

// ============================================================
// BLOC — Geçmiş & Favoriler İş Mantığı
// ============================================================

/// Geçmiş modülü BLoC katmanı.
///
/// [IHistoryRepository] üzerinden veri işlemleri yapar.
/// Her event sonrası listeyi yeniden yükleyerek güncel state yayar.
class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final IHistoryRepository _repository;

  HistoryBloc(this._repository) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<SaveReadingEvent>(_onSaveReading);
    on<ToggleFavoriteEvent>(_onToggleFavorite);
    on<DeleteReadingEvent>(_onDeleteReading);
    on<ClearAllReadingsEvent>(_onClearAll);
  }

  /// Tüm okumaları yükler ve türlerine göre ayırır.
  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    emit(const HistoryLoading());

    try {
      final all = await _repository.getAll();
      final dreams = all
          .where((r) => r.type == SavedReadingType.dream)
          .toList();
      final fortunes = all
          .where((r) => r.type == SavedReadingType.fortune)
          .toList();

      emit(HistoryLoaded(dreamReadings: dreams, fortuneReadings: fortunes));
    } on Exception catch (e) {
      emit(HistoryError(message: 'Geçmiş yüklenirken hata oluştu: $e'));
    }
  }

  /// Yeni bir okumayı kaydeder ve listeyi yeniler.
  Future<void> _onSaveReading(
    SaveReadingEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.save(event.reading);
      add(const LoadHistory()); // Listeyi yenile
    } on Exception catch (e) {
      emit(HistoryError(message: 'Okuma kaydedilirken hata oluştu: $e'));
    }
  }

  /// Favori durumunu değiştirir ve listeyi yeniler.
  Future<void> _onToggleFavorite(
    ToggleFavoriteEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.toggleFavorite(event.readingId);
      add(const LoadHistory()); // Listeyi yenile
    } on Exception catch (e) {
      emit(HistoryError(message: 'Favori güncellenirken hata oluştu: $e'));
    }
  }

  /// Okumayı siler ve listeyi yeniler.
  Future<void> _onDeleteReading(
    DeleteReadingEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.delete(event.readingId);
      add(const LoadHistory()); // Listeyi yenile
    } on Exception catch (e) {
      emit(HistoryError(message: 'Okuma silinirken hata oluştu: $e'));
    }
  }

  /// Tüm okumaları siler ve listeyi yeniler.
  Future<void> _onClearAll(
    ClearAllReadingsEvent event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await _repository.clearAll();
      add(const LoadHistory()); // Listeyi yenile
    } on Exception catch (e) {
      emit(HistoryError(message: 'Veriler temizlenirken hata oluştu: $e'));
    }
  }
}
