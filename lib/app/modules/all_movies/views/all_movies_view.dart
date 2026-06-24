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
import '../controllers/all_movies_controller.dart';

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
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          gradient: AppThemeData.appleIntelligenceGradientCool,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4)),
          ],
        ),
        child: IconButton(
          onPressed: () => Get.toNamed(Routes.MOVIE_CRUD),
          icon: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: MahekResponsive.responsivePadding(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndToggle(context, isDark),
          spaceH(height: 16),
          _buildStatsRow(context, isDark),
          spaceH(height: 20),
          _buildFilterRow(isDark),
          spaceH(height: 16),
          if (controller.filteredMovies.isEmpty)
            _buildEmptyState(isDark)
          else
            _buildMoviesGrid(context, isDark),
          spaceH(height: 80),
        ],
      ),
    );
  }

  Widget _buildSearchAndToggle(BuildContext context, bool isDark) {
    return Row(
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
    );
  }

  Widget _buildToggleBtn(IconData icon, bool isActive, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 44,
        decoration: BoxDecoration(
          color: isActive ? AppThemeData.primary50.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(11),
        ),
        child: Icon(icon, size: 18, color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
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

  Widget _buildFilterRow(bool isDark) {
    final filters = ['ALL', 'NOT STARTED', 'WATCHING', 'COMPLETED'];
    return Row(
      children: filters.map((f) {
        final isActive = controller.selectedStatus.value == f;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => controller.updateStatusFilter(f),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isActive ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3)),
              ),
              child: TextCustom(
                title: f,
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(Icons.movie_outlined, size: 64, color: isDark ? AppThemeData.grey6 : AppThemeData.grey4),
            spaceH(height: 16),
            TextCustom(title: 'No movies found', fontSize: 16, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
            spaceH(height: 6),
            TextCustom(title: 'Add your first movie to start tracking', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

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
      itemCount: controller.filteredMovies.length,
      itemBuilder: (context, index) {
        return _buildMovieCard(controller.filteredMovies[index], isDark);
      },
    );
  }

  Widget _buildMovieCard(MovieModel movie, bool isDark) {
    return GestureDetector(
      onTap: () => Get.toNamed(Routes.MOVIE_DETAILS, arguments: movie),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
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
                            child: Icon(Icons.movie_rounded, color: AppThemeData.primary50, size: 32),
                          ),
                  ),
                ),
                Positioned(
                  top: 8, right: 8,
                  child: Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.bookmark_border_rounded, color: Colors.white, size: 18),
                  ),
                ),
                if (movie.status == 'COMPLETED')
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: AppThemeData.success300.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(6)),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 12),
                    ),
                  ),
              ],
            ),
          ),
          spaceH(height: 8),
          TextCustom(title: movie.movieName ?? 'Untitled', fontSize: 13, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1, textOverflow: TextOverflow.ellipsis),
          spaceH(height: 4),
          Row(
            children: [
              TextCustom(title: movie.year ?? 'N/A', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              if (movie.genreTags.isNotEmpty)
                TextCustom(title: ' • ${movie.genreTags.first}', fontSize: 11, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
            ],
          ),
          if (movie.rating != null) ...[
            spaceH(height: 3),
            Row(
              children: [
                Icon(Icons.star_rounded, size: 12, color: AppThemeData.pending300),
                spaceW(width: 3),
                TextCustom(title: movie.rating!.toStringAsFixed(1), fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
