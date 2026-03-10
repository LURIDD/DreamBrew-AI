/// DreamBrew AI — Visualization State
///
/// Görsel üretimi sırasındaki UI durumlarını (Initial, Loading, Loaded, Error) temsil eder.
library;

import 'dart:typed_data';

abstract class VisualizationState {}

/// Başlangıç durumu. Henüz görsel üretilmedi.
class VisualizationInitial extends VisualizationState {}

/// Görsel üretim süreci başladı, sunucudan yanıt bekleniyor.
class VisualizationLoading extends VisualizationState {}

/// Görsel başarıyla üretildi ve indirildi.
class VisualizationLoaded extends VisualizationState {
  final Uint8List imageBytes;

  VisualizationLoaded({required this.imageBytes});
}

/// Görsel üretimi sırasında hata oluştu.
class VisualizationError extends VisualizationState {
  final String message;

  VisualizationError(this.message);
}
