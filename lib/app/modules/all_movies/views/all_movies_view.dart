import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/movie_model.dart';
import '../controllers/all_movies_controller.dart';

// ── HOVERABLE STAT CARD WRAPPER ──

class _HoverableStatCard extends StatefulWidget {
  final Widget child;
  final Color accentColor;

  const _HoverableStatCard({required this.child, required this.accentColor});

  @override
  State<_HoverableStatCard> createState() => _HoverableStatCardState();
}

class _HoverableStatCardState extends State<_HoverableStatCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedScale(
        scale: _isHovered ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.35),
                      blurRadius: 24,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.18),
                      blurRadius: 40,
                      spreadRadius: -4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.25),
                      blurRadius: 20,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.12),
                      blurRadius: 36,
                      spreadRadius: -4,
                    ),
                  ],
          ),
          child: widget.child,
        ),
      ),
    );
  }
}

// ── HOVERABLE CARD WRAPPER ──

class _HoverableCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _HoverableCard({required this.child, this.onTap});

  @override
  State<_HoverableCard> createState() => _HoverableCardState();
}

class _HoverableCardState extends State<_HoverableCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _isHovered ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: AppThemeData.neonMint.withValues(alpha: 0.18),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppThemeData.neonMint.withValues(alpha: 0.10),
                        blurRadius: 40,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppThemeData.primaryBlack.withValues(alpha: isDark ? 0.25 : 0.06),
                        blurRadius: isDark ? 12 : 16,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: AppThemeData.primaryBlack.withValues(alpha: isDark ? 0.10 : 0.03),
                        blurRadius: isDark ? 24 : 32,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

class AllMoviesView extends GetView<AllMoviesController> {
  const AllMoviesView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.surfaceObsidian : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7, size: 20),
        ),
        title: TextCustom(
          title: 'All Movies',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        centerTitle: false,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: MahekLoader(message: 'Loading Movies...', size: 50, textSize: 16));
        }
        return _buildContent(context, isDark);
      }),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    final padding = MahekResponsive.responsivePadding(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── FIXED HEADER (search + stats + filters) ──
        Padding(
          padding: padding.copyWith(bottom: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSearchAndToggle(context, isDark),
              spaceH(height: 16),
              _buildStatsRow(context, isDark),
              spaceH(height: 20),
              _buildAllFilters(isDark),
            ],
          ),
        ),
        spaceH(height: 16),
        // ── SCROLLABLE MOVIES SECTION ──
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollEndNotification && notification.metrics.extentAfter < 200) {
                controller.loadMore();
              }
              return false;
            },
            child: ListView(
              padding: padding.copyWith(top: 0),
              children: [
                if (controller.filteredMovies.isEmpty)
                  _buildEmptyState(isDark)
                else if (controller.isGridView.value)
                  _buildMoviesGrid(context, isDark)
                else
                  _buildMoviesList(context, isDark),
                Obx(() {
                  if (controller.isLoadingMore.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: MahekLoader(size: 28, showBranding: false)),
                    );
                  }
                  if (controller.hasMore) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: TextCustom(
                        title: 'All ${controller.filteredMovies.length} movies loaded',
                        fontSize: 12,
                        fontFamily: FontFamily.regular,
                        color: AppThemeData.grey5,
                      ),
                    ),
                  );
                }),
                spaceH(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndToggle(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
                ),
                child: TextField(
                  onChanged: controller.updateSearch,
                  style: TextStyle(color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Search movies...',
                    hintStyle: TextStyle(color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, fontSize: 13),
                    prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, size: 18),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
            ),
            spaceW(width: 12),
            Container(
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
              ),
              child: Row(
                children: [
                  _buildToggleBtn(Icons.grid_view_rounded, controller.isGridView.value, () => controller.isGridView.value = true, isDark),
                  Container(width: 1, height: 22, color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
                  _buildToggleBtn(Icons.view_list_rounded, !controller.isGridView.value, () => controller.isGridView.value = false, isDark),
                ],
              ),
            ),
          ],
        ),
        spaceH(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Obx(() {
              final showing = controller.displayedMovies.length;
              final total = controller.filteredMovies.length;
              return TextCustom(
                title: 'Showing $showing of $total movies',
                fontSize: 11,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              );
            }),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleBtn(IconData icon, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppThemeData.primary50.withValues(alpha: 0.15) : AppThemeData.primaryBlack.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 18, color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  // ── STATS ROW ──

  double _progressFor(String type) {
    final total = controller.totalMovies;
    if (total == 0) return 0;
    switch (type) {
      case 'total':
        return controller.completedCount / total;
      case 'watching':
        final watching = controller.movies.where((m) => m.status == 'WATCHING').toList();
        if (watching.isEmpty) return 0;
        final wTotal = watching.fold<int>(0, (sum, m) => sum + (m.totalDuration ?? 0));
        final wWatched = watching.fold<int>(0, (sum, m) => sum + (m.watchedDuration ?? 0));
        if (wTotal == 0) return 0;
        return wWatched / wTotal;
      case 'completed':
        return 1.0;
      case 'not_started':
        return 0.0;
      default:
        return 0;
    }
  }

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth > 1100
            ? min((constraints.maxWidth - 42) / 4, 500.0)
            : min((constraints.maxWidth - 14) / 2, 500.0);
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            SizedBox(
              width: cardWidth,
              height: 260,
              child: _HoverableStatCard(
                accentColor: AppThemeData.primary50,
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Total',
                  subtitle: 'Movies tracked',
                  value: controller.totalMovies.toString(),
                  icon: Icons.movie_rounded,
                  accentColor: AppThemeData.primary50,
                  progress: _progressFor('total'),
                  bgAsset: 'assets/icons/ic_clapperboard.svg',
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 260,
              child: _HoverableStatCard(
                accentColor: AppThemeData.neonTeal,
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Watching',
                  subtitle: 'Currently in progress',
                  value: controller.watchingCount.toString(),
                  icon: Icons.play_circle_outline_rounded,
                  accentColor: AppThemeData.neonTeal,
                  progress: _progressFor('watching'),
                  bgAsset: 'assets/icons/ic_popcorn.svg',
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 260,
              child: _HoverableStatCard(
                accentColor: AppThemeData.neonCyan,
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Completed',
                  subtitle: 'Movies finished',
                  value: controller.completedCount.toString(),
                  icon: Icons.check_circle_outline_rounded,
                  accentColor: AppThemeData.neonCyan,
                  progress: _progressFor('completed'),
                  bgAsset: 'assets/icons/ic_theater_seats.svg',
                ),
              ),
            ),
            SizedBox(
              width: cardWidth,
              height: 260,
              child: _HoverableStatCard(
                accentColor: AppThemeData.neonOrange,
                child: _buildStatCard(
                  isDark: isDark,
                  label: 'Not Started',
                  subtitle: 'Movies pending',
                  value: controller.notStartedCount.toString(),
                  icon: Icons.pause_circle_outline_rounded,
                  accentColor: AppThemeData.neonOrange,
                  progress: _progressFor('not_started'),
                  bgAsset: 'assets/icons/ic_movie_ticket.svg',
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard({
    required bool isDark,
    required String label,
    required String subtitle,
    required String value,
    required IconData icon,
    required Color accentColor,
    required double progress,
    required String bgAsset,
  }) {
    final percent = (progress * 100).toInt();

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        children: [
          // Base bg
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey1,
            ),
          ),
          // Colored gradient tint
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  accentColor.withValues(alpha: isDark ? 0.18 : 0.10),
                  accentColor.withValues(alpha: isDark ? 0.06 : 0.03),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Background illustration watermark
          Positioned(
            right: 8,
            bottom: 16,
            child: Opacity(
              opacity: isDark ? 0.22 : 0.14,
              child: SvgPicture.asset(
                bgAsset,
                width: 190,
                height: 190,
                colorFilter: ColorFilter.mode(accentColor, BlendMode.srcIn),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon circle with glow ring
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.35),
                      width: 2.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.40),
                        blurRadius: 16,
                        spreadRadius: -1,
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: accentColor.withValues(alpha: 0.22),
                    ),
                    child: Icon(icon, color: accentColor, size: 28),
                  ),
                ),
                const Spacer(),
                // Large number
                TextCustom(
                  title: value,
                  fontSize: 44,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                // Colored label
                TextCustom(
                  title: label,
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: accentColor,
                ),
                spaceH(height: 2),
                // Grey subtitle
                TextCustom(
                  title: subtitle,
                  fontSize: 11,
                  fontFamily: FontFamily.regular,
                  color: AppThemeData.grey6,
                ),
                const Spacer(),
                // Gradient progress bar + percentage
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: ShaderMask(
                          shaderCallback: (Rect bounds) {
                            return LinearGradient(
                              colors: [
                                accentColor.withValues(alpha: 0.4),
                                accentColor,
                              ],
                            ).createShader(bounds);
                          },
                          blendMode: BlendMode.src,
                          child: LinearProgressIndicator(
                            value: progress.clamp(0.0, 1.0),
                            minHeight: 10,
                            backgroundColor: isDark
                                ? AppThemeData.surfaceDark
                                : AppThemeData.grey3,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),
                    spaceW(width: 8),
                    TextCustom(
                      title: '$percent%',
                      fontSize: 12,
                      fontFamily: FontFamily.bold,
                      color: accentColor,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FILTERS ──

  Widget _buildAllFilters(bool isDark) {
    final genres = controller.availableGenres;
    final showGenreFilter = genres.length > 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 16, color: isDark ? AppThemeData.grey3 : AppThemeData.grey8),
              spaceW(width: 8),
              TextCustom(
                title: 'Filter Movies',
                fontSize: 13,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
              ),
              const Spacer(),
              Obx(() => controller.hasActiveFilters
                  ? GestureDetector(
                      onTap: () => controller.clearFilters(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppThemeData.primary50.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.close_rounded, size: 13, color: AppThemeData.primary50),
                            spaceW(width: 4),
                            TextCustom(
                              title: 'Clear All',
                              fontSize: 11,
                              fontFamily: FontFamily.medium,
                              color: AppThemeData.primary50,
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink()),
            ],
          ),
          spaceH(height: 12),
          // Split row: Status left | Divider | Genre right
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── STATUS (left) ──
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterLabel('Status', isDark),
                    spaceH(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: _buildStatusChips(isDark),
                    ),
                  ],
                ),
              ),
              // ── VERTICAL DIVIDER ──
              if (showGenreFilter) ...[
                Container(
                  width: 1,
                  height: 52,
                  margin: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4,
                  ),
                ),
                // ── GENRE (right) ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildFilterLabel('Genre', isDark),
                      spaceH(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          ..._buildGenreChips(isDark).take(4),
                          if (genres.length > 6)
                            _buildMoreGenresChip(isDark, genres.skip(5).toList()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterLabel(String text, bool isDark) {
    return TextCustom(
      title: text,
      fontSize: 11,
      fontFamily: FontFamily.semiBold,
      color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
    );
  }

  Widget _buildMoreGenresChip(bool isDark, List<String> moreGenres) {
    return GestureDetector(
      onTap: () => _showMoreGenresPopup(isDark, moreGenres),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppThemeData.primaryBlack.withValues(alpha: 0),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(
              title: 'More',
              fontSize: 11,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            ),
            spaceW(width: 3),
            Icon(Icons.keyboard_arrow_down_rounded, size: 13, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  void _showMoreGenresPopup(bool isDark, List<String> genres) {
    showDialog(
      context: Get.context!,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: TextCustom(
            title: 'More Genres',
            fontSize: 16,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: genres.map((g) {
              final isActive = controller.selectedGenre.value == g;
              final genreIcon = _genreIcon(g);
              final color = AppThemeData.neonBlue;
              return GestureDetector(
                onTap: () {
                  controller.updateGenreFilter(g);
                  Navigator.pop(ctx);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: isActive ? color.withValues(alpha: 0.15) : AppThemeData.primaryBlack.withValues(alpha: 0),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(genreIcon, size: 16, color: isActive ? color : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
                      spaceW(width: 10),
                      TextCustom(
                        title: g[0] + g.substring(1).toLowerCase(),
                        fontSize: 14,
                        fontFamily: FontFamily.medium,
                        color: isActive ? color : (isDark ? AppThemeData.grey3 : AppThemeData.grey8),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  List<Widget> _buildStatusChips(bool isDark) {
    final filters = [
      ('ALL', Icons.all_inclusive_rounded, AppThemeData.primary50),
      ('NOT STARTED', Icons.pause_circle_outline_rounded, AppThemeData.neonOrange),
      ('WATCHING', Icons.play_circle_outline_rounded, AppThemeData.neonBlue),
      ('COMPLETED', Icons.check_circle_outline_rounded, AppThemeData.neonCyan),
    ];
    return filters.map((f) {
      final (label, icon, color) = f;
      final isActive = controller.selectedStatus.value == label;
      return GestureDetector(
        onTap: () => controller.updateStatusFilter(label),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.15) : AppThemeData.primaryBlack.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? color : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 13, color: isActive ? color : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
              const SizedBox(width: 5),
              TextCustom(
                title: label,
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isActive ? color : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildGenreChips(bool isDark) {
    final genres = controller.availableGenres;
    if (genres.length <= 1) return [];
    return genres.map((g) {
      final isActive = controller.selectedGenre.value == g;
      final genreIcon = _genreIcon(g);
      final color = AppThemeData.neonBlue;
      return GestureDetector(
        onTap: () => controller.updateGenreFilter(g),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isActive ? color.withValues(alpha: 0.15) : AppThemeData.primaryBlack.withValues(alpha: 0),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isActive ? color : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(genreIcon, size: 13, color: isActive ? color : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
              const SizedBox(width: 5),
              TextCustom(
                title: g[0] + g.substring(1).toLowerCase(),
                fontSize: 11,
                fontFamily: FontFamily.medium,
                color: isActive ? color : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  IconData _genreIcon(String genre) {
    switch (genre) {
      case 'ALL':
        return Icons.all_inclusive_rounded;
      case 'ACTION':
        return Icons.local_fire_department_rounded;
      case 'COMEDY':
        return Icons.sentiment_very_satisfied_rounded;
      case 'DRAMA':
        return Icons.theater_comedy_rounded;
      case 'THRILLER':
        return Icons.psychology_rounded;
      case 'ROMANCE':
        return Icons.favorite_rounded;
      default:
        return Icons.movie_rounded;
    }
  }

  // ── EMPTY STATE ──

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppThemeData.primary50.withValues(alpha: isDark ? 0.10 : 0.08),
              ),
              child: Icon(Icons.movie_outlined, size: 56, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No movies found', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
            spaceH(height: 6),
            TextCustom(title: 'Add your first movie to start tracking', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  // ── GRID ──

  Widget _buildMoviesGrid(BuildContext context, bool isDark) {
    final availableWidth = MediaQuery.of(context).size.width - 48;
    final columns = availableWidth > 1400 ? 6 : availableWidth > 1100 ? 5 : availableWidth > 800 ? 4 : availableWidth > 550 ? 3 : 2;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 0.58,
      ),
      itemCount: controller.displayedMovies.length,
      itemBuilder: (context, index) {
        final movie = controller.displayedMovies[index];
        return _HoverableCard(
          onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
          child: _buildMovieCardContent(movie, isDark),
        );
      },
    );
  }

  Widget _buildMovieCardContent(MovieModel movie, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Stack(
            children: [
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                      ? CachedNetworkImage(
                          imageUrl: movie.posterUrl!,
                          fit: BoxFit.cover,
                          placeholder: (ctx, url) => Container(
                            color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey3,
                            child: Center(
                              child: MahekLoader(size: 24, showBranding: false),
                            ),
                          ),
                          errorWidget: (ctx, url, error) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                              ),
                            ),
                            child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 32),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [AppThemeData.primary50.withValues(alpha: 0.2), AppThemeData.primary4.withValues(alpha: 0.1)],
                            ),
                          ),
                          child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 32),
                        ),
                ),
              ),
              if (movie.status == 'COMPLETED')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppThemeData.success300.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.check_rounded, color: AppThemeData.primaryWhite, size: 12),
                  ),
                ),
              if (movie.status == 'WATCHING')
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppThemeData.neonBlue.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(Icons.play_arrow_rounded, color: AppThemeData.primaryWhite, size: 12),
                  ),
                ),
            ],
          ),
        ),
        spaceH(height: 8),
        TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
        spaceH(height: 4),
        Row(
          children: [
            TextCustom(title: movie.year ?? 'N/A', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            if (movie.genreTags.isNotEmpty)
              TextCustom(title: ' \u2022 ${movie.genreTags.first}', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
        if (movie.rating != null) ...[
          spaceH(height: 3),
          Row(
            children: [
              Icon(Icons.star_rounded, size: 13, color: AppThemeData.neonOrange),
              spaceW(width: 3),
              TextCustom(title: movie.rating!.toStringAsFixed(1), fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
            ],
          ),
        ],
      ],
    );
  }

  // ── LIST ──

  Widget _buildMoviesList(BuildContext context, bool isDark) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: controller.displayedMovies.length,
      separatorBuilder: (a, b) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        return _buildMovieListCard(controller.displayedMovies[index], isDark);
      },
    );
  }

  Widget _buildMovieListCard(MovieModel movie, bool isDark) {
    return _HoverableCard(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 70,
                height: 90,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: movie.posterUrl!,
                        fit: BoxFit.cover,
                        placeholder: (ctx, url) => Container(
                          color: isDark ? AppThemeData.surfaceDark : AppThemeData.grey3,
                          child: Center(
                            child: MahekLoader(size: 20, showBranding: false),
                          ),
                        ),
                        errorWidget: (ctx, url, error) => Container(
                          color: isDark ? AppThemeData.surfaceDark : AppThemeData.grey3,
                          child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 24),
                        ),
                      )
                    : Container(
                        color: isDark ? AppThemeData.surfaceDark : AppThemeData.grey3,
                        child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 24),
                      ),
              ),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                  spaceH(height: 4),
                  Row(
                    children: [
                      if (movie.year != null)
                        TextCustom(title: movie.year!, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      if (movie.genreTags.isNotEmpty) ...[
                        TextCustom(title: ' \u2022 ${movie.genreTags.first}', fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                      ],
                    ],
                  ),
                  spaceH(height: 4),
                  Row(
                    children: [
                      _buildStatusBadge(movie.status, isDark),
                      if (movie.rating != null) ...[
                        spaceW(width: 8),
                        Icon(Icons.star_rounded, size: 13, color: AppThemeData.neonOrange),
                        spaceW(width: 2),
                        TextCustom(title: movie.rating!.toStringAsFixed(1), fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status, bool isDark) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'WATCHING':
        bgColor = AppThemeData.neonBlue.withValues(alpha: 0.15);
        textColor = AppThemeData.neonBlue;
        label = 'WATCHING';
        break;
      case 'COMPLETED':
        bgColor = AppThemeData.neonCyan.withValues(alpha: 0.15);
        textColor = AppThemeData.neonCyan;
        label = 'COMPLETED';
        break;
      case 'NOT_STARTED':
        bgColor = AppThemeData.neonOrange.withValues(alpha: 0.15);
        textColor = AppThemeData.neonOrange;
        label = 'NOT STARTED';
        break;
      default:
        bgColor = AppThemeData.grey5.withValues(alpha: 0.15);
        textColor = AppThemeData.grey5;
        label = 'UNKNOWN';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.bold, color: textColor),
    );
  }
}
