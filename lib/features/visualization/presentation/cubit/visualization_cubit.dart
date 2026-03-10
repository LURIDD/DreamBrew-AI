/// DreamBrew AI — Visualization Cubit
///
/// Görsel üretim işlemlerini UI'dan soyutlar ve state'i yönetir.
library;

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/i_image_generation_repository.dart';
import 'visualization_state.dart';

/// Görsel üretimi sürecini yöneten Cubit
class VisualizationCubit extends Cubit<VisualizationState> {
  final IImageGenerationRepository _repository;

  VisualizationCubit(this._repository) : super(VisualizationInitial());

  /// Görsel üretimini başlatır.
  /// 
  /// [keywords] prompt için kullanılacak anahtar kelimeler listesidir.
  Future<void> generateImage(List<String> keywords) async {
    emit(VisualizationLoading());
    try {
      final imageBytes = await _repository.generateImage(keywords);
      emit(VisualizationLoaded(imageBytes: imageBytes));
    } catch (e) {
      // Hatayı kullanıcıya göstermek için sadeleştir
      emit(VisualizationError(e.toString().replaceAll('Exception: ', '')));
    }
  }
  
  /// State'i sıfırlar, yeni görsel üretimi için veya sayfadan çıkıldığında kullanılabilir.
  void reset() {
    emit(VisualizationInitial());
  }
}
