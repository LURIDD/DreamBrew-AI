/// DreamBrew AI — Visualization Cubit
///
/// Görsel üretim işlemlerini UI'dan soyutlar ve state'i yönetir.
/// Gemini API'den Base64 formatında görsel alır ve Hive'a kaydeder.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/local_storage/hive_service.dart';
import '../../domain/repositories/i_image_generation_repository.dart';
import 'visualization_state.dart';

/// Görsel üretimi sürecini yöneten Cubit.
///
/// [readingId] — görseli hangi okumaya kaydedeceğimizi belirler.
/// Görsel başarıyla üretildiğinde otomatik olarak Hive'a kaydedilir.
class VisualizationCubit extends Cubit<VisualizationState> {
  final IImageGenerationRepository _repository;
  final HiveService _hiveService;
  
  /// Hangi okumaya ait görsel üretildiğini takip eder.
  String? _currentReadingId;

  VisualizationCubit(this._repository, this._hiveService) 
      : super(VisualizationInitial());

  /// Görsel üretimini başlatır.
  /// 
  /// [keywords] prompt için kullanılacak anahtar kelimeler listesidir.
  /// [readingId] opsiyoneldir — verilirse görsel Hive'a kaydedilir.
  Future<void> generateImage(List<String> keywords, {String? readingId}) async {
    _currentReadingId = readingId;
    emit(VisualizationLoading());
    try {
      final imageBase64 = await _repository.generateImage(keywords);
      
      // Görsel başarıyla üretildiyse ve readingId varsa → Hive'a kaydet
      if (_currentReadingId != null) {
        await _hiveService.updateImageBase64(_currentReadingId!, imageBase64);
      }
      
      emit(VisualizationLoaded(imageBase64: imageBase64));
    } catch (e) {
      emit(VisualizationError(
        e.toString().replaceAll('Exception: ', ''),
      ));
    }
  }
  
  /// State'i sıfırlar, yeni görsel üretimi için veya sayfadan çıkıldığında kullanılabilir.
  void reset() {
    emit(VisualizationInitial());
  }
}
