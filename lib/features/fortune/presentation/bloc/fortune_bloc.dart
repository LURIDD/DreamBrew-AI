/// DreamBrew AI — Kahve Falı BLoC Katmanı
///
/// Bu dosya, kahve falı modülünün iş mantığını yönetir.
/// [IFortuneRepository] arayüzü üzerinden mock ya da gerçek servisle çalışır.
/// Görsel seçimi (kamera/galeri) ve analiz sürecini Event → BLoC → State
/// akışıyla yönetir.
library;

import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/services/image_compressor.dart';
import '../../domain/entities/fortune_reading.dart';
import '../../domain/repositories/i_fortune_repository.dart';

// ============================================================
// EVENTS — Kahve falı modülüne gönderilen olaylar
// ============================================================

/// Temel Fortune event sınıfı
abstract class FortuneEvent {
  const FortuneEvent();
}

/// Kullanıcı kameradan veya galeriden görsel seçtiğinde tetiklenir.
///
/// [source] — Görsel kaynağı: [ImageSource.camera] veya [ImageSource.gallery]
class PickImageEvent extends FortuneEvent {
  final ImageSource source;

  const PickImageEvent({required this.source});
}

/// Kullanıcı "Analyze Fortune" butonuna bastığında tetiklenir.
///
/// [style] — Seçilen yorum tarzı: Mystical, Fun, Deep
class AnalyzeFortuneEvent extends FortuneEvent {
  final String style;

  const AnalyzeFortuneEvent({required this.style});
}

/// Kullanıcı seçili görseli temizlemek istediğinde tetiklenir.
class ClearImageEvent extends FortuneEvent {
  const ClearImageEvent();
}

// ============================================================
// STATES — Kahve falı modülünün olası durumları
// ============================================================

/// Temel Fortune state sınıfı
abstract class FortuneState {
  const FortuneState();
}

/// Başlangıç durumu — henüz bir işlem yapılmadı
class FortuneInitial extends FortuneState {
  const FortuneInitial();
}

/// Görsel başarıyla seçildi — önizleme gösterilmeli
class FortuneImagePicked extends FortuneState {
  /// Seçilen görselin dosya yolu
  final String imagePath;

  const FortuneImagePicked({required this.imagePath});
}

/// Fal analiz ediliyor — yükleniyor göstergesi gösterilmeli
class FortuneAnalyzing extends FortuneState {
  /// Analiz sırasında görselin yolunu da taşı (UI'da önizleme kalsın)
  final String imagePath;

  const FortuneAnalyzing({required this.imagePath});
}

/// Fal yorumu başarıyla tamamlandı — sonuç ekranına geçilebilir
class FortuneSuccess extends FortuneState {
  /// Yapay zekadan dönen (şimdilik mock) kahve falı yorumu
  final FortuneReading reading;

  const FortuneSuccess({required this.reading});
}

/// Hata oluştu — kullanıcıya hata mesajı gösterilmeli
class FortuneError extends FortuneState {
  /// Kullanıcıya gösterilecek hata açıklaması
  final String message;

  /// Hata sonrası tekrar deneme için seçili görsel yolu (varsa)
  final String? imagePath;

  const FortuneError({required this.message, this.imagePath});
}

// ============================================================
// BLOC — Kahve Falı İş Mantığı
// ============================================================

/// Kahve Falı modülünün BLoC katmanı.
///
/// [IFortuneRepository] üzerinden `readFortune` çağrısı yapar.
/// DI (get_it) aracılığıyla repository sağlanır; mock ↔ real
/// geçişi BLoC'u etkilemez.
///
/// Akış:
/// 1. [PickImageEvent] → kamera/galeriden görsel seç → [FortuneImagePicked]
/// 2. [AnalyzeFortuneEvent] → sıkıştır + repo'ya gönder → [FortuneSuccess]
class FortuneBloc extends Bloc<FortuneEvent, FortuneState> {
  final IFortuneRepository _repository;
  final ImagePicker _imagePicker;

  /// Seçilen görselin dosya yolu — analiz sırasında kullanılır
  String? _currentImagePath;

  FortuneBloc(this._repository, {ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker(),
      super(const FortuneInitial()) {
    on<PickImageEvent>(_onPickImage);
    on<AnalyzeFortuneEvent>(_onAnalyzeFortune);
    on<ClearImageEvent>(_onClearImage);
  }

  /// Kamera veya galeriden görsel seçme işlemi.
  ///
  /// [ImagePicker] kullanarak görseli alır, yolunu saklar ve
  /// [FortuneImagePicked] state'i yayar.
  Future<void> _onPickImage(
    PickImageEvent event,
    Emitter<FortuneState> emit,
  ) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: event.source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        _currentImagePath = pickedFile.path;
        emit(FortuneImagePicked(imagePath: pickedFile.path));
      }
      // Kullanıcı iptal ettiyse mevcut state'te kal
    } on Exception catch (e) {
      emit(
        FortuneError(
          message: 'Görsel seçilirken bir hata oluştu: $e',
          imagePath: _currentImagePath,
        ),
      );
    }
  }

  /// Seçilen görseli sıkıştırıp repository'e gönderme işlemi.
  ///
  /// 1. Görseli mock sıkıştırma ile base64'e dönüştür
  /// 2. Repository'nin `readFortune` metodunu çağır
  /// 3. Sonucu [FortuneSuccess] olarak yay
  Future<void> _onAnalyzeFortune(
    AnalyzeFortuneEvent event,
    Emitter<FortuneState> emit,
  ) async {
    if (_currentImagePath == null) {
      emit(
        const FortuneError(message: 'Lütfen önce bir fincan fotoğrafı seçin ☕'),
      );
      return;
    }

    emit(FortuneAnalyzing(imagePath: _currentImagePath!));

    try {
      // 1. Görseli sıkıştır (mock simülasyon)
      final compressedBase64 = await ImageCompressor.compress(
        File(_currentImagePath!),
      );

      // 2. Repository'e gönder ve fal yorumunu al
      final reading = await _repository.readFortune(compressedBase64);

      // 3. Başarılı sonucu yay
      emit(FortuneSuccess(reading: reading));
    } on Exception catch (e) {
      emit(
        FortuneError(
          message: 'Fal yorumlanırken bir hata oluştu: $e',
          imagePath: _currentImagePath,
        ),
      );
    }
  }

  /// Seçili görseli temizle ve başlangıç durumuna dön.
  void _onClearImage(ClearImageEvent event, Emitter<FortuneState> emit) {
    _currentImagePath = null;
    emit(const FortuneInitial());
  }
}
