/// DreamBrew AI — Visualization State
///
/// Görsel üretimi sırasındaki UI durumlarını (Initial, Loading, Loaded, Error) temsil eder.
/// Loaded state artık Base64 formatında görsel verisi taşır.
library;

/// Tüm visualization durumlarının üst sınıfı.
abstract class VisualizationState {}

/// Başlangıç durumu. Henüz görsel üretilmedi.
class VisualizationInitial extends VisualizationState {}

/// Görsel üretim süreci başladı, sunucudan yanıt bekleniyor.
class VisualizationLoading extends VisualizationState {}

/// Görsel başarıyla üretildi — Base64 formatında veri taşır.
class VisualizationLoaded extends VisualizationState {
  /// Gemini API'den dönen Base64 kodlanmış görsel verisi.
  final String imageBase64;

  VisualizationLoaded({required this.imageBase64});
}

/// Görsel üretimi sırasında hata oluştu.
class VisualizationError extends VisualizationState {
  final String message;

  VisualizationError(this.message);
}
