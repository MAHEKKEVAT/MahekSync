import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../controllers/movie_crud_controller.dart';

class MovieCrudView extends GetView<MovieCrudController> {
  const MovieCrudView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MahekResponsive.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      appBar: AppBar(
        backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            size: 20,
          ),
        ),
        title: TextCustom(
          title: controller.isEditMode.value ? 'Edit Movie' : 'Add Movie',
          fontSize: 22,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        centerTitle: false,
      ),
      body: isMobile ? _buildMobileLayout(context, isDark) : _buildDesktopLayout(context, isDark),
    );
  }

  Widget _buildMobileLayout(BuildContext context, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFormCard(context, isDark),
          spaceH(height: 16),
          _buildPosterCard(isDark),
          spaceH(height: 16),
          _buildActionButtons(isDark),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        Expanded(flex: 2, child: _buildFormCard(context, isDark)),
        _buildRightPanel(isDark),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppThemeData.primary50, AppThemeData.primary4],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  controller.isEditMode.value ? Icons.edit_rounded : Icons.add_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              spaceW(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: controller.isEditMode.value ? 'Update Movie' : 'Add New Movie',
                    fontSize: 20,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                  TextCustom(
                    title: 'Fill in the details below',
                    fontSize: 13,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                ],
              ),
            ],
          ),
          spaceH(height: 28),
          _buildSectionTitle('MOVIE DETAILS', Icons.movie_outlined, isDark),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'MOVIE NAME',
            hintText: 'e.g. Interstellar',
            controller: controller.movieNameController,
            prefix: Icon(Icons.movie_outlined, size: 20, color: AppThemeData.primary50),
          ),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  title: 'YEAR',
                  hintText: 'e.g. 2024',
                  controller: controller.yearController,
                  prefix: Icon(Icons.calendar_today_outlined, size: 20, color: AppThemeData.primary50),
                  textInputType: TextInputType.number,
                ),
              ),
              spaceW(width: 16),
              Expanded(
                child: _buildStatusDropdown(isDark),
              ),
            ],
          ),
          spaceH(height: 16),
          _buildGenreDropdown(isDark),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'DIRECTOR',
            hintText: 'e.g. Christopher Nolan',
            controller: controller.directorController,
            prefix: Icon(Icons.person_outline_rounded, size: 20, color: AppThemeData.primary50),
          ),
          spaceH(height: 16),
          _buildRatingWidget(isDark),
          spaceH(height: 16),
          TextFieldWidget(
            title: 'DESCRIPTION',
            hintText: 'Brief synopsis of the movie...',
            controller: controller.descriptionController,
            prefix: Icon(Icons.description_outlined, size: 20, color: AppThemeData.primary50),
            line: 3,
          ),
          spaceH(height: 28),
          _buildSectionTitle('TOTAL DURATION', Icons.access_time_rounded, isDark),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(child: Obx(() => _buildStepper('HOURS', controller.totalHours.value, 0, 23, controller.incTotalHours, controller.decTotalHours, isDark, stepLabel: 'h'))),
              spaceW(width: 12),
              Expanded(child: Obx(() => _buildStepper('MINUTES', controller.totalMinutes.value, 0, 55, controller.incTotalMinutes, controller.decTotalMinutes, isDark, stepLabel: 'min'))),
            ],
          ),
          spaceH(height: 20),
          _buildSectionTitle('WATCHED DURATION', Icons.timer_outlined, isDark),
          spaceH(height: 16),
          Row(
            children: [
              Expanded(child: Obx(() => _buildStepper('HOURS', controller.watchedHours.value, 0, 23, controller.incWatchedHours, controller.decWatchedHours, isDark, stepLabel: 'h'))),
              spaceW(width: 12),
              Expanded(child: Obx(() => _buildStepper('MINUTES', controller.watchedMinutes.value, 0, 55, controller.incWatchedMinutes, controller.decWatchedMinutes, isDark, stepLabel: 'min'))),
            ],
          ),
          spaceH(height: 32),
          if (!MahekResponsive.isMobile(context))
            Obx(() => RoundShapeButton(
              title: controller.isSaving.value
                  ? 'Saving...'
                  : (controller.isEditMode.value ? 'Update Movie' : 'Add Movie'),
              buttonColor: AppThemeData.primary50,
              buttonTextColor: Colors.white,
              onTap: controller.isSaving.value ? () {} : controller.saveMovie,
              width: double.infinity,
              height: 52,
            )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppThemeData.primary50),
        spaceW(width: 8),
        TextCustom(
          title: title,
          fontSize: 13,
          fontFamily: FontFamily.bold,
          color: AppThemeData.primary50,
        ),
      ],
    );
  }

  Widget _buildStatusDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'STATUS',
          fontSize: 12,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey8 : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            ),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedStatus.value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
              items: controller.statusOptions.map((String status) {
                String label;
                IconData icon;
                switch (status) {
                  case 'WATCHING':
                    label = 'Watching';
                    icon = Icons.play_circle_outline_rounded;
                    break;
                  case 'COMPLETED':
                    label = 'Completed';
                    icon = Icons.check_circle_outline_rounded;
                    break;
                  case 'NOT_STARTED':
                    label = 'Not Started';
                    icon = Icons.pause_circle_outline_rounded;
                    break;
                  case 'NOT_DOWNLOADED':
                    label = 'Not Downloaded';
                    icon = Icons.download_rounded;
                    break;
                  default:
                    label = 'Not Downloaded';
                    icon = Icons.download_rounded;
                }
                return DropdownMenuItem<String>(
                  value: status,
                  child: Row(
                    children: [
                      Icon(
                        icon,
                        size: 18,
                        color: status == 'WATCHING'
                            ? AppThemeData.neonMint
                            : status == 'COMPLETED'
                                ? AppThemeData.success300
                                : status == 'NOT_STARTED'
                                    ? AppThemeData.neonOrange
                                    : AppThemeData.neonLavender,
                      ),
                      spaceW(width: 10),
                      TextCustom(
                        title: label,
                        fontSize: 14,
                        fontFamily: FontFamily.regular,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.selectedStatus.value = newValue;
                }
              },
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildGenreDropdown(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'GENRE',
          fontSize: 12,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey8 : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            ),
          ),
          child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedGenre.value,
              isExpanded: true,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
              ),
              items: controller.genreOptions.map((String genre) {
                final label = genre == 'ALL' ? 'All Genres' : genre[0] + genre.substring(1).toLowerCase();
                return DropdownMenuItem<String>(
                  value: genre,
                  child: TextCustom(
                    title: label,
                    fontSize: 14,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.selectedGenre.value = newValue;
                }
              },
            ),
          )),
        ),
      ],
    );
  }

  Widget _buildRatingWidget(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: 'RATING',
          fontSize: 12,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey8 : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            ),
          ),
          child: Obx(() {
            final rating = controller.selectedRating.value;
            return Row(
              children: [
                ...List.generate(10, (index) {
                  final starIndex = index ~/ 2;
                  final isLeftHalf = index.isEven;
                  final filled = isLeftHalf
                      ? rating >= (starIndex * 2 + 1).toDouble()
                      : rating >= (starIndex * 2 + 2).toDouble();
                  final halfFilled = isLeftHalf
                      ? false
                      : rating >= (starIndex * 2 + 1).toDouble() && rating < (starIndex * 2 + 2).toDouble();

                  return GestureDetector(
                    onTap: () {
                      final newRating = isLeftHalf
                          ? (starIndex * 2 + 1).toDouble()
                          : (starIndex * 2 + 2).toDouble();
                      controller.selectedRating.value =
                          controller.selectedRating.value == newRating ? 0.0 : newRating;
                    },
                    child: SizedBox(
                      width: 24,
                      height: 28,
                      child: Icon(
                        filled
                            ? Icons.star_rounded
                            : halfFilled
                                ? Icons.star_half_rounded
                                : Icons.star_outline_rounded,
                        size: 24,
                        color: (filled || halfFilled)
                            ? AppThemeData.neonOrange
                            : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                      ),
                    ),
                  );
                }),
                const Spacer(),
                TextCustom(
                  title: '${rating.toInt()} / 10',
                  fontSize: 14,
                  fontFamily: FontFamily.bold,
                  color: rating > 0
                      ? AppThemeData.neonOrange
                      : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepper(String label, int value, int min, int max, VoidCallback onInc, VoidCallback onDec, bool isDark, {String stepLabel = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextCustom(
          title: label,
          fontSize: 12,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 8),
        Container(
          height: 50,
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey8 : AppThemeData.primaryWhite,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            ),
          ),
          child: Row(
            children: [
              _buildStepperButton(
                icon: Icons.remove_rounded,
                onTap: value > min ? onDec : null,
                isDark: isDark,
              ),
              Expanded(
                child: Center(
                  child: TextCustom(
                    title: '$value $stepLabel',
                    fontSize: 16,
                    fontFamily: FontFamily.bold,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  ),
                ),
              ),
              _buildStepperButton(
                icon: Icons.add_rounded,
                onTap: value < max ? onInc : null,
                isDark: isDark,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperButton({required IconData icon, required VoidCallback? onTap, required bool isDark}) {
    final isEnabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 50,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppThemeData.primary50.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: icon == Icons.remove_rounded ? const Radius.circular(13) : Radius.zero,
            right: icon == Icons.add_rounded ? const Radius.circular(13) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isEnabled
              ? AppThemeData.primary50
              : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
        ),
      ),
    );
  }

  Widget _buildPosterCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('POSTER IMAGE', Icons.image_outlined, isDark),
          spaceH(height: 16),
          _buildPosterUpload(isDark),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Container(
      width: 420,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        border: Border(
          left: BorderSide(
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('POSTER IMAGE', Icons.image_outlined, isDark),
          spaceH(height: 16),
          _buildPosterUpload(isDark),
          const Spacer(),
          Obx(() => RoundShapeButton(
            title: controller.isSaving.value ? 'Saving...' : 'Save Movie',
            buttonColor: AppThemeData.primary50,
            buttonTextColor: Colors.white,
            onTap: controller.isSaving.value ? () {} : controller.saveMovie,
            width: double.infinity,
            height: 52,
          )),
          spaceH(height: 12),
          RoundShapeButton(
            title: 'Discard',
            buttonColor: Colors.transparent,
            buttonTextColor: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            borderColor: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            onTap: () => Get.back(),
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }

  Widget _buildPosterUpload(bool isDark) {
    return Obx(() {
      final hasPoster = controller.posterUrl.value.isNotEmpty || controller.posterBytes.value != null;

      return GestureDetector(
        onTap: controller.pickPoster,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          height: 560,
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? AppThemeData.grey8 : AppThemeData.grey2,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
              style: hasPoster ? BorderStyle.none : BorderStyle.solid,
            ),
          ),
          child: hasPoster
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: controller.posterBytes.value != null
                      ? Image.memory(
                          controller.posterBytes.value!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholder(isDark),
                        )
                      : NetworkImageWidget(
                          imageUrl: controller.posterUrl.value,
                          fit: BoxFit.cover,
                          borderRadius: 0,
                        ),
                )
              : _buildPlaceholder(isDark),
        ),
      );
    });
  }

  Widget _buildPlaceholder(bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          size: 48,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
        spaceH(height: 12),
        TextCustom(
          title: 'Click to upload poster',
          fontSize: 14,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
        ),
        spaceH(height: 4),
        TextCustom(
          title: 'JPG, PNG (Max 5MB)',
          fontSize: 12,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Obx(() => RoundShapeButton(
            title: controller.isSaving.value ? 'Saving...' : (controller.isEditMode.value ? 'Update Movie' : 'Add Movie'),
            buttonColor: AppThemeData.primary50,
            buttonTextColor: Colors.white,
            onTap: controller.isSaving.value ? () {} : controller.saveMovie,
            width: double.infinity,
            height: 52,
          )),
          spaceH(height: 12),
          RoundShapeButton(
            title: 'Discard',
            buttonColor: Colors.transparent,
            buttonTextColor: isDark ? AppThemeData.grey4 : AppThemeData.grey7,
            borderColor: isDark ? AppThemeData.grey7 : AppThemeData.grey3,
            onTap: () => Get.back(),
            width: double.infinity,
            height: 52,
          ),
        ],
      ),
    );
  }
}
