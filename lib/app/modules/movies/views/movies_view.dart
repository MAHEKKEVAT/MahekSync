import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/movie_model.dart';
import '../controllers/movies_controller.dart';

class MoviesView extends GetView<MoviesController> {
  const MoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: MahekLoader(message: 'Loading Movies...', size: 50, textSize: 16));
        }
        return _buildContent(context, isDark);
      }),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: MahekResponsive.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isDark),
          spaceH(height: 20),
          _buildStatsRow(context, isDark),
          spaceH(height: 24),
          if (controller.watchingMovies.isNotEmpty) ...[
            _buildWatchingSection(context, isDark),
            spaceH(height: 24),
          ],
          _buildLatestMoviesSection(context, isDark),
          spaceH(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppThemeData.primary50, AppThemeData.primary4],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: const Icon(Icons.movie_rounded, color: Colors.white, size: 24),
        ),
        spaceW(width: 14),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(title: 'Movies', fontSize: 22, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            TextCustom(title: '${controller.totalMovies} movies tracked', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(child: _buildStatCard(isDark, 'Total', controller.totalMovies.toString(), Icons.movie_rounded, AppThemeData.primary50)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'Watching', controller.watchingCount.toString(), Icons.play_circle_outline_rounded, AppThemeData.neonBlue)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'Completed', controller.completedCount.toString(), Icons.check_circle_outline_rounded, AppThemeData.success300)),
        spaceW(width: 12),
        Expanded(child: _buildStatCard(isDark, 'Not Started', controller.notStartedCount.toString(), Icons.pause_circle_outline_rounded, AppThemeData.pending300)),
      ],
    );
  }

  Widget _buildStatCard(bool isDark, String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18),
          ),
          spaceW(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: value, fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              TextCustom(title: title, fontSize: 10, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ],
          ),
        ],
      ),
    );
  }

  // ── WATCHING SECTION (1 card) ──

  Widget _buildWatchingSection(BuildContext context, bool isDark) {
    final movie = controller.watchingMovies.first;
    final progress = movie.progressPercent.clamp(0.0, 100.0);
    final remaining = (movie.totalDuration ?? 0) - (movie.watchedDuration ?? 0);
    final remainingH = remaining ~/ 60;
    final remainingM = remaining % 60;
    final remainingText = remainingH > 0 ? '$remainingH hrs $remainingM mins left' : '$remainingM mins left';
    final cardWidth = MahekResponsive.responsiveWidth(context, mobile: 320, tablet: 380, laptop: 420, desktop: 450);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'Watching', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        spaceH(height: 14),
        GestureDetector(
          onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
          child: Container(
            width: cardWidth,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppThemeData.neonBlue.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SizedBox(
                    width: 100, height: 148,
                    child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                        ? NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0)
                        : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                              ),
                            ),
                            child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 30),
                          ),
                  ),
                ),
                spaceW(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(color: AppThemeData.neonBlue.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                        child: TextCustom(title: 'WATCHING', fontSize: 9, fontFamily: FontFamily.bold, color: AppThemeData.neonBlue),
                      ),
                      spaceH(height: 8),
                      TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                      spaceH(height: 4),
                      TextCustom(title: remainingText, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      spaceH(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextCustom(title: '${progress.toInt()}% Complete', fontSize: 11, fontFamily: FontFamily.bold, color: AppThemeData.primary50),
                          TextCustom(title: movie.formattedTotalDuration, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                        ],
                      ),
                      spaceH(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(3),
                        child: LinearProgressIndicator(
                          value: progress / 100,
                          minHeight: 5,
                          backgroundColor: isDark ? AppThemeData.surfaceDark : AppThemeData.grey3,
                          valueColor:  AlwaysStoppedAnimation<Color>(AppThemeData.primary50),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── LATEST MOVIES (4 cards) ──

  Widget _buildLatestMoviesSection(BuildContext context, bool isDark) {
    final latest = controller.latestMovies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => Get.toNamed(Routes.ALL_MOVIES),
          child: Row(
            children: [
              TextCustom(title: 'All Movies', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              const Spacer(),
              TextCustom(title: 'View All', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
              spaceW(width: 6),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppThemeData.primary50),
            ],
          ),
        ),
        spaceH(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final maxWidth = constraints.maxWidth;
            final cardCount = latest.length;
            final spacing = 12.0;
            final totalSpacing = cardCount > 1 ? (cardCount - 1) * spacing : 0.0;
            final availablePerCard = (maxWidth - totalSpacing) / cardCount;
            final cardWidth = availablePerCard > 260 ? 260.0 : availablePerCard;

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: latest.map((movie) {
                return SizedBox(
                  width: cardWidth,
                  child: _buildCompactCard(movie, isDark),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCompactCard(MovieModel movie, bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(13)),
              child: SizedBox(
                width: double.infinity,
                height: 140,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0)
                    : Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                          ),
                        ),
                        child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 28),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: movie.movieName ?? 'Untitled',
                    fontSize: 13,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    maxLine: 1,
                    textOverflow: TextOverflow.ellipsis,
                  ),
                  spaceH(height: 4),
                  Row(
                    children: [
                      if (movie.year != null && movie.year!.isNotEmpty)
                        TextCustom(title: movie.year!, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      if (movie.year != null && movie.year!.isNotEmpty && movie.genreTags.isNotEmpty)
                        TextCustom(title: ' • ', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      if (movie.genreTags.isNotEmpty)
                        Expanded(
                          child: TextCustom(
                            title: movie.genreTags.first,
                            fontSize: 11,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                            maxLine: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  spaceH(height: 6),
                  _buildStatusBadge(movie.status),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'WATCHING':
        bgColor = AppThemeData.neonBlue.withValues(alpha: 0.12);
        textColor = AppThemeData.neonBlue;
        label = 'WATCHING';
        break;
      case 'COMPLETED':
        bgColor = AppThemeData.success300.withValues(alpha: 0.12);
        textColor = AppThemeData.success300;
        label = 'COMPLETED';
        break;
      case 'NOT_STARTED':
        bgColor = AppThemeData.pending300.withValues(alpha: 0.12);
        textColor = AppThemeData.pending300;
        label = 'NOT STARTED';
        break;
      default:
        bgColor = AppThemeData.pending300.withValues(alpha: 0.12);
        textColor = AppThemeData.pending300;
        label = 'NOT STARTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.bold, color: textColor),
    );
  }
}
