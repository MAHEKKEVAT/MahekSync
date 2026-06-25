import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
          scale: _isHovered ? 1.04 : 1.0,
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
                        offset: const Offset(0, 2)
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

  // ── HEADER ──

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Movies',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            spaceH(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: 'Track. ', style: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
                  TextSpan(text: 'Watch. ', style: TextStyle(fontSize: 13, fontFamily: FontFamily.bold, color: AppThemeData.primary50)),
                  TextSpan(text: 'Enjoy.', style: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
                ],
              ),
            ),
          ],
        ),
        const Spacer(),
        _buildSearchButton(isDark),
        spaceW(width: 10),
        _buildAddButton(isDark),
      ],
    );
  }

  Widget _buildSearchButton(bool isDark) {
    return GestureDetector(
      onTap: () => _showSearchSheet(Get.context!),
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4),
        ),
        child: Icon(Icons.search_rounded, color: isDark ? AppThemeData.grey5 : AppThemeData.grey7, size: 20),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.MOVIE_CRUD),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          gradient: AppThemeData.appleIntelligenceGradientCool,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            spaceW(width: 6),
            TextCustom(title: 'Add Movie', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
          ],
        ),
      ),
    );
  }

  void _showSearchSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchCtrl = TextEditingController(text: controller.searchQuery.value);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppThemeData.grey4, borderRadius: BorderRadius.circular(2))),
                  ),
                  spaceH(height: 16),
                  TextCustom(title: 'Search Movies', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                  spaceH(height: 12),
                  TextField(
                    controller: searchCtrl,
                    autofocus: true,
                    style: TextStyle(fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                    decoration: InputDecoration(
                      hintText: 'Search by name, year, or genre...',
                      hintStyle: TextStyle(fontSize: 13, fontFamily: FontFamily.regular, color: AppThemeData.grey4),
                      prefixIcon: Icon(Icons.search_rounded, color: AppThemeData.grey4, size: 20),
                      suffixIcon: searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, color: AppThemeData.grey4, size: 18),
                              onPressed: () {
                                searchCtrl.clear();
                                controller.updateSearch('');
                                setSheetState(() {});
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: isDark ? AppThemeData.surfaceDark : AppThemeData.grey2,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppThemeData.primary50),
                      ),
                    ),
                    onChanged: (val) {
                      controller.updateSearch(val);
                      setSheetState(() {});
                    },
                  ),
                  spaceH(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppThemeData.primary50,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const TextCustom(title: 'Done', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      searchCtrl.dispose();
    });
  }

  // ── STATS ROW ──

  double _progressFor(String type) {
    final total = controller.totalMovies;
    if (total == 0) return 0;
    switch (type) {
      case 'total':
        final allTotal = controller.movies.fold<int>(0, (sum, m) => sum + (m.totalDuration ?? 0));
        final allWatched = controller.movies.fold<int>(0, (sum, m) => sum + (m.watchedDuration ?? 0));
        if (allTotal == 0) return 0;
        return allWatched / allTotal;
      case 'watching':
        final watching = controller.watchingMovies;
        if (watching.isEmpty) return 0;
        final wTotal = watching.fold<int>(0, (sum, m) => sum + (m.totalDuration ?? 0));
        final wWatched = watching.fold<int>(0, (sum, m) => sum + (m.watchedDuration ?? 0));
        if (wTotal == 0) return 0;
        return wWatched / wTotal;
      case 'completed':
        return controller.completedCount / total;
      case 'notStarted':
        return controller.notStartedCount / total;
      default:
        return 0;
    }
  }

  Widget _buildStatsRow(BuildContext context, bool isDark) {
    return SizedBox(
      height: 290,
      child: Row(
        children: [
          Expanded(
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
          spaceW(width: 14),
          Expanded(
            child: _HoverableStatCard(
              accentColor: AppThemeData.neonBlue,
              child: _buildStatCard(
                isDark: isDark,
                label: 'Watching',
                subtitle: 'Currently in progress',
                value: controller.watchingCount.toString(),
                icon: Icons.play_circle_outline_rounded,
                accentColor: AppThemeData.neonBlue,
                progress: _progressFor('watching'),
                bgAsset: 'assets/icons/ic_popcorn.svg',
              ),
            ),
          ),
          spaceW(width: 14),
          Expanded(
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
          spaceW(width: 14),
          Expanded(
            child: _HoverableStatCard(
              accentColor: AppThemeData.neonOrange,
              child: _buildStatCard(
                isDark: isDark,
                label: 'Not Started',
                subtitle: 'Plan to watch',
                value: controller.notStartedCount.toString(),
                icon: Icons.pause_circle_outline_rounded,
                accentColor: AppThemeData.neonOrange,
                progress: _progressFor('notStarted'),
                bgAsset: 'assets/icons/ic_movie_ticket.svg',
              ),
            ),
          ),
        ],
      ),
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

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
      ),
      child: ClipRRect(

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
                    accentColor.withValues(alpha: isDark ? 0.12 : 0.08),
                    accentColor.withValues(alpha: isDark ? 0.04 : 0.02),
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
                  // Top row: Icon + Arrow
                  Row(
                    children: [
                      // Icon circle with glow ring
                      Container(
                        width: 68,
                        height: 68,
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
                      // Arrow icon
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isDark
                              ? AppThemeData.grey10.withValues(alpha: 0.18)
                              : AppThemeData.grey1.withValues(alpha: 0.14),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: isDark
                              ? AppThemeData.grey10.withValues(alpha: 0.85)
                              : AppThemeData.grey1.withValues(alpha: 0.70),
                          size: 18,
                        ),
                      ),
                    ],
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
      ),
    );
  }

  // ── CONTINUE WATCHING SECTION ──

  Widget _buildWatchingSection(BuildContext context, bool isDark) {
    final watching = controller.watchingMovies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(title: 'Continue Watching', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        spaceH(height: 14),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: watching.length,
            separatorBuilder: (a, b) => spaceW(width: 12),
            itemBuilder: (ctx, i) => SizedBox(
              width: 400,
              child: _buildContinueWatchingCard(watching[i], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueWatchingCard(MovieModel movie, bool isDark) {
    final progress = movie.progressPercent.clamp(0.0, 100.0);
    final remaining = (movie.totalDuration ?? 0) - (movie.watchedDuration ?? 0);
    final remainingH = remaining ~/ 60;
    final remainingM = remaining % 60;
    final remainingText = remainingH > 0 ? '$remainingH hrs $remainingM mins left' : '$remainingM mins left';

    return _HoverableCard(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100, height: 148,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? Stack(fit: StackFit.expand, children: [
                        NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppThemeData.primaryBlack.withValues(alpha: 0.5)]),
                            ),
                          ),
                        ),
                      ])
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
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? AppThemeData.neonMint.withValues(alpha: 0.20) : AppThemeData.success300.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: TextCustom(
                          title: 'WATCHING',
                          fontSize: 9,
                          fontFamily: FontFamily.bold,
                          color: isDark ? AppThemeData.neonMint : AppThemeData.success500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.more_vert_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6, size: 18),
                    ],
                  ),
                  spaceH(height: 8),
                  TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                  spaceH(height: 4),
                  TextCustom(title: remainingText, fontSize: 12, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey7),
                  spaceH(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextCustom(title: '${progress.toInt()}% Complete', fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.neonMint : AppThemeData.success400),
                      TextCustom(title: movie.formattedTotalDuration, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey7),
                    ],
                  ),
                  spaceH(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 5,
                      backgroundColor: isDark ? AppThemeData.surfaceLight : AppThemeData.grey3,
                      valueColor: AlwaysStoppedAnimation<Color>(isDark ? AppThemeData.neonMint : AppThemeData.success400),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ALL MOVIES SECTION ──

  Widget _buildLatestMoviesSection(BuildContext context, bool isDark) {
    final latest = controller.latestMovies;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextCustom(title: 'All Movies', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
            const Spacer(),
            GestureDetector(
              onTap: () => Get.toNamed(Routes.ALL_MOVIES),
              child: Row(
                children: [
                  TextCustom(title: 'View All', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                  spaceW(width: 6),
                  Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppThemeData.primary50),
                ],
              ),
            ),
          ],
        ),
        spaceH(height: 14),
        SizedBox(
          height: 175,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: latest.length,
            separatorBuilder: (a, b) => spaceW(width: 12),
            itemBuilder: (ctx, i) => SizedBox(
              width: 400,
              child: _buildAllMovieCard(latest[i], isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAllMovieCard(MovieModel movie, bool isDark) {
    return _HoverableCard(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.surfaceElevated : AppThemeData.grey1,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey4),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 100, height: 148,
                child: movie.posterUrl != null && movie.posterUrl!.isNotEmpty
                    ? Stack(fit: StackFit.expand, children: [
                        NetworkImageWidget(imageUrl: movie.posterUrl!, fit: BoxFit.cover, borderRadius: 0),
                        Positioned(
                          bottom: 0, left: 0, right: 0,
                          child: Container(
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, AppThemeData.primaryBlack.withValues(alpha: 0.5)]),
                            ),
                          ),
                        ),
                      ])
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
                  Row(
                    children: [
                      Icon(Icons.bookmark_border_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6, size: 18),
                      const Spacer(),
                      Icon(Icons.more_vert_rounded, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6, size: 18),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 15, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
                  spaceH(height: 4),
                  Row(
                    children: [
                      if (movie.year != null && movie.year!.isNotEmpty)
                        TextCustom(title: movie.year!, fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey7),
                      if (movie.year != null && movie.year!.isNotEmpty && movie.genreTags.isNotEmpty)
                        TextCustom(title: ' \u2022 ', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey7),
                      if (movie.genreTags.isNotEmpty)
                        Expanded(
                          child: TextCustom(
                            title: movie.genreTags.first,
                            fontSize: 11,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey7,
                            maxLine: 1,
                            textOverflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  spaceH(height: 8),
                  _buildStatusBadge(movie.status, isDark: isDark),
                  if (movie.rating != null && movie.rating! > 0) ...[
                    spaceH(height: 6),
                    _buildRatingStars(movie.rating!),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String? status, {bool isDark = true}) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'WATCHING':
        bgColor = isDark ? AppThemeData.neonMint.withValues(alpha: 0.20) : AppThemeData.success300.withValues(alpha: 0.12);
        textColor = isDark ? AppThemeData.neonMint : AppThemeData.success500;
        label = 'WATCHING';
        break;
      case 'COMPLETED':
        bgColor = isDark ? AppThemeData.success300.withValues(alpha: 0.20) : AppThemeData.success300.withValues(alpha: 0.12);
        textColor = isDark ? AppThemeData.success300 : AppThemeData.success500;
        label = 'COMPLETED';
        break;
      case 'NOT_STARTED':
        bgColor = isDark ? AppThemeData.pending300.withValues(alpha: 0.20) : AppThemeData.pending400.withValues(alpha: 0.12);
        textColor = isDark ? AppThemeData.pending300 : AppThemeData.pending500;
        label = 'NOT STARTED';
        break;
      default:
        bgColor = isDark ? AppThemeData.pending300.withValues(alpha: 0.20) : AppThemeData.pending400.withValues(alpha: 0.12);
        textColor = isDark ? AppThemeData.pending300 : AppThemeData.pending500;
        label = 'NOT STARTED';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(6)),
      child: TextCustom(title: label, fontSize: 9, fontFamily: FontFamily.bold, color: textColor),
    );
  }

  Widget _buildRatingStars(double rating) {
    final fullStars = rating.floor();
    final hasHalf = (rating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalf ? 1 : 0);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < fullStars; i++)
          Icon(Icons.star_rounded, color: AppThemeData.pending300, size: 14),
        if (hasHalf)
          Icon(Icons.star_half_rounded, color: AppThemeData.pending300, size: 14),
        for (var i = 0; i < emptyStars; i++)
          Icon(Icons.star_border_rounded, color: AppThemeData.grey4, size: 14),
      ],
    );
  }
}
