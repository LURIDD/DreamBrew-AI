/// DreamBrew AI — Visualization View Widget
///
/// Görsel üretimi sürecini (Loading, Loaded, Error) gösteren 
/// tekrar kullanılabilir şık bir UI bileşeni.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../cubit/visualization_cubit.dart';
import '../cubit/visualization_state.dart';

class VisualizationView extends StatelessWidget {
  const VisualizationView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<VisualizationCubit, VisualizationState>(
      builder: (context, state) {
        if (state is VisualizationInitial) {
          return const SizedBox.shrink(); // Görsel istenene kadar boş.
        }

        if (state is VisualizationLoading) {
          return _buildLoadingState(context);
        }

        if (state is VisualizationLoaded) {
          return _buildLoadedState(context, state);
        }

        if (state is VisualizationError) {
          return _buildErrorState(context, state);
        }

        return const SizedBox.shrink();
      },
    );
  }

  /// Yükleniyor durumu animasyonu (mistik bir bekleme efekti)
  Widget _buildLoadingState(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 280,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E), Color(0xFF0F3460)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Evren görseli çiziyor...',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.primaryLight,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  /// Üretilen görseli gösteren şık kutu
  Widget _buildLoadedState(BuildContext context, VisualizationLoaded state) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.memory(
          state.imageBytes,
          fit: BoxFit.cover,
          width: double.infinity,
        ),
      ),
    );
  }

  /// Hata durumu
  Widget _buildErrorState(BuildContext context, VisualizationError state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 32),
          const SizedBox(height: 12),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppColors.errorLight,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
