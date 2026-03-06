/// DreamBrew AI — Geçmiş Ekranı (History Page)
///
/// Kaydedilmiş rüya ve kahve falı okumalarını iki sekmeli (TabBar)
/// bir listede gösterir. interpretation_history.png tasarımına birebir
/// sadık kalınmıştır.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/local_storage/saved_reading.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/snackbar_helper.dart';
import '../../../../core/di/service_locator.dart';
import '../bloc/history_bloc.dart';

/// Geçmiş & Favoriler ana ekranı.
///
/// BlocProvider ile HistoryBloc sağlanır ve ekran açılır açılmaz
/// [LoadHistory] event'i tetiklenir.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<HistoryBloc>()..add(const LoadHistory()),
      child: const _HistoryView(),
    );
  }
}

/// History ekranının asıl görünümü.
/// DefaultTabController ile Dreams / Coffee Readings sekmeleri yönetilir.
class _HistoryView extends StatelessWidget {
  const _HistoryView();

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: Text(
            'History',
            style: GoogleFonts.cinzel(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 1.0,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(48),
            child: _buildTabBar(),
          ),
        ),
        body: BlocConsumer<HistoryBloc, HistoryState>(
          listener: (context, state) {
            if (state is HistoryError) {
              SnackbarHelper.showError(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is HistoryLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state is HistoryLoaded) {
              return TabBarView(
                children: [
                  // Dreams sekmesi
                  _ReadingList(
                    readings: state.dreamReadings,
                    emptyIcon: Icons.nightlight_round,
                    emptyTitle: 'No Dream Readings Yet',
                    emptySubtitle: 'Your interpreted dreams will\nappear here',
                  ),
                  // Coffee Readings sekmesi
                  _ReadingList(
                    readings: state.fortuneReadings,
                    emptyIcon: Icons.coffee,
                    emptyTitle: 'No Coffee Readings Yet',
                    emptySubtitle: 'Your coffee cup readings will\nappear here',
                  ),
                ],
              );
            }

            // Initial veya beklenmeyen state'lerde boş TabBarView
            return TabBarView(
              children: [
                _ReadingList(
                  readings: const [],
                  emptyIcon: Icons.nightlight_round,
                  emptyTitle: 'No Dream Readings Yet',
                  emptySubtitle: 'Your interpreted dreams will\nappear here',
                ),
                _ReadingList(
                  readings: const [],
                  emptyIcon: Icons.coffee,
                  emptyTitle: 'No Coffee Readings Yet',
                  emptySubtitle: 'Your coffee cup readings will\nappear here',
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Üstteki TabBar widget'ı — tasarımdaki mor çizgi + aktif sekme rengi
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: TabBar(
        indicatorColor: AppColors.primary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textHint,
        labelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: AppColors.primary.withValues(alpha: 0.15),
        tabs: const [
          Tab(text: 'Dreams'),
          Tab(text: 'Coffee Readings'),
        ],
      ),
    );
  }
}

// ============================================================
// Okuma Listesi
// ============================================================

/// Belirli bir türdeki okumaların listesi.
/// Boşsa [_EmptyState] gösterilir.
class _ReadingList extends StatelessWidget {
  final List<SavedReading> readings;
  final IconData emptyIcon;
  final String emptyTitle;
  final String emptySubtitle;

  const _ReadingList({
    required this.readings,
    required this.emptyIcon,
    required this.emptyTitle,
    required this.emptySubtitle,
  });

  @override
  Widget build(BuildContext context) {
    if (readings.isEmpty) {
      return _EmptyState(
        icon: emptyIcon,
        title: emptyTitle,
        subtitle: emptySubtitle,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      itemCount: readings.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _HistoryCard(reading: readings[index]),
        );
      },
    );
  }
}

// ============================================================
// Geçmiş Kartı
// ============================================================

/// Tek bir okumanın kart görünümü.
/// Tasarımdaki gibi: sol ikon, başlık + özet, sağ tarih + favori kalp.
class _HistoryCard extends StatelessWidget {
  final SavedReading reading;

  const _HistoryCard({required this.reading});

  @override
  Widget build(BuildContext context) {
    final isDream = reading.type == SavedReadingType.dream;

    return GestureDetector(
      onTap: () {
        context.push(AppRouter.readingDetail, extra: reading);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isDream
              ? AppColors.dreamCardGradient
              : AppColors.fortuneCardGradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: (isDream ? AppColors.primary : AppColors.secondary)
                .withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sol ikon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: (isDream ? AppColors.primary : AppColors.secondary)
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isDream ? Icons.nightlight_round : Icons.coffee,
                color: isDream ? AppColors.primaryLight : AppColors.secondary,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Başlık + Açıklama
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reading.title,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    reading.content,
                    style: AppTextStyles.cardDescription.copyWith(fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),

            // Sağ: tarih + favori kalp
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Tarih
                Text(
                  _formatShortDate(reading.date),
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(height: 10),

                // Favori kalp ikonu
                GestureDetector(
                  onTap: () {
                    context.read<HistoryBloc>().add(
                      ToggleFavoriteEvent(readingId: reading.id),
                    );
                  },
                  child: Icon(
                    reading.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: reading.isFavorite
                        ? AppColors.primary
                        : AppColors.textHint,
                    size: 22,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Kısa tarih formatı: "Oct 24" gibi
  String _formatShortDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]}\n${date.day.toString().padLeft(2, '0')}';
  }
}

// ============================================================
// Boş Durum (Empty State)
// ============================================================

/// Liste boşken gösterilen şık empty state tasarımı.
class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Dekoratif ikon container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.primaryLight.withValues(alpha: 0.5),
                size: 44,
              ),
            ),
            const SizedBox(height: 28),

            // Başlık
            Text(
              title,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Alt yazı
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: AppColors.textHint,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
