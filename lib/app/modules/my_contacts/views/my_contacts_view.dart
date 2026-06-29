import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/dependency/shimmer.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/models/my_contacts_model.dart';
import '../controllers/my_contacts_controller.dart';

class MyContactsView extends GetView<MyContactsController> {
  const MyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MahekResponsive.compatIsMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
      body: Stack(
        children: [
          Row(
            children: [
              Expanded(child: _leftPanel(isDark, isMobile)),
              if (!isMobile)
                Obx(
                  () => AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                    width: controller.isDetailPanelOpen.value ? 380 : 0,
                    child: ClipRRect(child: _rightDetailPanel(isDark)),
                  ),
                ),
            ],
          ),
          Obx(
            () => controller.isDrawerOpen.value
                ? _addEditDrawer(isDark, isMobile)
                : const SizedBox.shrink(),
          ),
          Obx(
            () => controller.isImporting.value
                ? _importOverlay(isDark)
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _importOverlay(bool isDark) {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Container(
          width: 340,
          padding: const EdgeInsets.all(28),
          decoration: AppThemeData.neonGlowBox(
            glowColor: AppThemeData.neonMint,
            bgColor: isDark
                ? AppThemeData.surfaceDeep
                : AppThemeData.primaryWhite,
            radius: 24,
            glowOpacity: 0.2,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: AppThemeData.neonCyanMintGradient,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  SolarIconsBold.import,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              spaceH(height: 18),
              TextCustom(
                title: 'Importing VCF...',
                fontSize: 17,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 8),
              TextCustom(
                title:
                    '${controller.importAdded.value} added  ·  ${controller.importUpdated.value} updated  ·  ${controller.importSkipped.value} skipped',
                fontSize: 12,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 20),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: controller.importProgress.value,
                  minHeight: 6,
                  backgroundColor: isDark
                      ? AppThemeData.surfaceElevated
                      : AppThemeData.grey3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppThemeData.neonMint,
                  ),
                ),
              ),
              spaceH(height: 8),
              TextCustom(
                title:
                    '${(controller.importProgress.value * 100).toStringAsFixed(0)}%',
                fontSize: 12,
                fontFamily: FontFamily.bold,
                color: AppThemeData.neonMint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _leftPanel(bool isDark, bool isMobile) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _header(isDark),
          spaceH(height: 20),
          _searchBar(isDark),
          spaceH(height: 16),
          _quickStats(isDark),
          spaceH(height: 16),
          _actionButtons(isDark),
          spaceH(height: 16),
          Expanded(child: _contactsList(isDark)),
        ],
      ),
    );
  }

  Widget _header(bool isDark) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            gradient: AppThemeData.appleIntelligenceGradientCool,
            borderRadius: BorderRadius.circular(14),
            boxShadow: AppThemeData.neonGlow(
              AppThemeData.neonBlue,
              blur: 14,
              opacity: 0.35,
            ),
          ),
          child: Icon(
            SolarIconsBold.usersGroupRounded,
            color: Colors.white,
            size: 20,
          ),
        ),
        spaceW(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'My Contacts',
                fontSize: 22,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              TextCustom(
                title: 'Manage your contacts',
                fontSize: 12,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.textNeonBlue : AppThemeData.grey5,
              ),
            ],
          ),
        ),

        // Refresh Icon Button [Neon Glow Box style match]
        Container(
          margin: const EdgeInsets.only(right: 8),
          decoration: AppThemeData.neonGlowBox(
            glowColor: AppThemeData.neonBlue,
            bgColor: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
            radius: 12,
            glowOpacity: 0.1,
          ),
          child: IconButton(
            onPressed: () => controller.refreshContacts(),
            icon: Icon(
              SolarIconsOutline.refresh,
              size: 18,
              color: isDark ? AppThemeData.textNeonBlue : AppThemeData.primary50,
            ),
          ),
        ),

        Obx(
              () => Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: AppThemeData.neonPurpleBlueGradient,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 10,
                opacity: 0.2,
              ),
            ),
            child: TextCustom(
              title: '${controller.totalContacts}',
              fontSize: 22,
              fontFamily: FontFamily.bold,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _searchBar(bool isDark) {
    return Container(
      decoration: AppThemeData.neonGlowBox(
        glowColor: AppThemeData.neonBlue,
        bgColor: isDark
            ? AppThemeData.surfaceDeep
            : AppThemeData.grey1.withValues(alpha: 0.8),
        radius: 14,
        glowOpacity: 0.08,
      ),
      child: TextField(
        controller: controller.searchController,
        style: TextStyle(
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Search contacts...',
          hintStyle: TextStyle(
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            SolarIconsOutline.magnifier,
            size: 18,
            color: isDark ? AppThemeData.textNeonBlue : AppThemeData.primary50,
          ),
          suffixIcon: Obx(
            () => controller.searchText.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      SolarIconsOutline.closeCircle,
                      size: 16,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                    },
                  )
                : const SizedBox.shrink(),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _interactiveStatChip(
      String label,
      IconData icon,
      ContactFilter filterMode,
      Color glowColor,
      Color dimColor,
      bool isDark,
      ) {
    final isSelected = controller.currentFilter.value == filterMode;
    return GestureDetector(
      onTap: () => controller.changeFilter(filterMode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [glowColor, glowColor.withValues(alpha: 0.8)]
                : [
              dimColor.withValues(alpha: isDark ? 0.3 : 0.1),
              dimColor.withValues(alpha: isDark ? 0.1 : 0.03),
            ],
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? glowColor : glowColor.withValues(alpha: 0.2),
            width: isSelected ? 1.2 : 0.5,
          ),
          boxShadow: isSelected
              ? AppThemeData.neonGlow(glowColor, blur: 8, opacity: 0.2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: isSelected ? Colors.white : glowColor),
            spaceW(width: 6),
            TextCustom(
              title: label,
              fontSize: 11,
              fontFamily: FontFamily.bold,
              color: isSelected ? Colors.white : glowColor,
            ),
          ],
        ),
      ),
    );
  }

  PopupMenuItem<ContactSort> _buildSortMenuItem(
      String title,
      ContactSort value,
      IconData icon,
      bool isDark,
      ) {
    final isSelected = controller.currentSort.value == value;
    return PopupMenuItem<ContactSort>(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: isSelected
                ? AppThemeData.neonPurple
                : (isDark ? AppThemeData.grey5 : AppThemeData.grey7),
          ),
          spaceW(width: 10),
          TextCustom(
            title: title,
            fontSize: 12,
            fontFamily: isSelected ? FontFamily.bold : FontFamily.regular,
            color: isSelected
                ? AppThemeData.neonPurple
                : (isDark ? AppThemeData.grey2 : AppThemeData.grey9),
          ),
        ],
      ),
    );
  }


  Widget _actionButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              gradient: AppThemeData.appleIntelligenceGradientCool,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 12,
                opacity: 0.25,
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: controller.openAddDrawer,
              icon: Icon(SolarIconsOutline.addCircle, size: 18),
              label: TextCustom(
                title: 'Add Contact',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        spaceW(width: 8),
        Container(
          decoration: AppThemeData.neonGlowBox(
            glowColor: AppThemeData.neonMint,
            bgColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            radius: 12,
            glowOpacity: 0.1,
          ),
          child: OutlinedButton.icon(
            onPressed: controller.importVcfFile,
            icon: Icon(
              SolarIconsOutline.documentText,
              size: 18,
              color: AppThemeData.neonMint,
            ),
            label: TextCustom(
              title: 'VCF',
              fontSize: 13,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.neonMint,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: AppThemeData.neonMint.withValues(alpha: 0.4),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
        spaceW(width: 8),
        Container(
          decoration: AppThemeData.neonGlowBox(
            glowColor: AppThemeData.neonTeal,
            bgColor: isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            radius: 12,
            glowOpacity: 0.1,
          ),
          child: OutlinedButton.icon(
            onPressed: controller.importMobileContacts,
            icon: Icon(
              SolarIconsOutline.import,
              size: 18,
              color: AppThemeData.neonTeal,
            ),
            label: TextCustom(
              title: 'Import',
              fontSize: 13,
              fontFamily: FontFamily.semiBold,
              color: AppThemeData.neonTeal,
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(
                color: AppThemeData.neonTeal.withValues(alpha: 0.4),
              ),
              backgroundColor: Colors.transparent,
            ),
          ),
        ),
      ],
    );
  }

  Widget _contactsList(bool isDark) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _shimmerList(isDark);
      }
      if (controller.filteredContacts.isEmpty) {
        return _emptyState(isDark);
      }
      return ListView.builder(
        padding: EdgeInsets.zero,
        itemCount: controller.filteredContacts.length,
        itemBuilder: (context, index) {
          final contact = controller.filteredContacts[index];
          return _contactCard(contact, isDark, index);
        },
      );
    });
  }

  Widget _contactCard(MyContactsModel contact, bool isDark, int index) {
    final gradients = [
      AppThemeData.neonPurpleBlueGradient,
      AppThemeData.neonCyanMintGradient,
      AppThemeData.neonPinkOrangeGradient,
      AppThemeData.neonBlueTealGradient,
      AppThemeData.neonSunsetGradient,
    ];
    final glowColors = [
      AppThemeData.neonPurple,
      AppThemeData.neonMint,
      AppThemeData.neonPink,
      AppThemeData.neonBlue,
      AppThemeData.neonPurple,
    ];
    final gradient = gradients[index % gradients.length];
    final glow = glowColors[index % glowColors.length];

    return Obx(() {
      final isSelected =
          controller.selectedContact.value?.docId == contact.docId;
      return GestureDetector(
        onTap: () => controller.selectContact(contact),
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: isSelected
                ? BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        glow.withValues(alpha: 0.12),
                        glow.withValues(alpha: 0.04),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: glow.withValues(alpha: 0.5),
                      width: 1.5,
                    ),
                    boxShadow: AppThemeData.neonGlow(
                      glow,
                      blur: 16,
                      opacity: 0.15,
                    ),
                  )
                : AppThemeData.neonGlowBox(
                    glowColor: glow,
                    bgColor: isDark
                        ? AppThemeData.surfaceElevated.withValues(alpha: 0.7)
                        : AppThemeData.primaryWhite.withValues(alpha: 0.8),
                    radius: 22,
                    glowOpacity: 0.06,
                  ),
            child: Row(
              children: [
                _avatar(contact, isDark, size: 44, gradient: gradient),
                spaceW(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: contact.formattedName,
                        fontSize: 14,
                        fontFamily: FontFamily.semiBold,
                        color: isDark
                            ? AppThemeData.grey1
                            : AppThemeData.grey10,
                      ),
                      spaceH(height: 2),
                      Row(
                        children: [
                          Icon(
                            SolarIconsOutline.phone,
                            size: 12,
                            color: isDark
                                ? AppThemeData.textNeonTeal
                                : AppThemeData.grey5,
                          ),
                          spaceW(width: 4),
                          TextCustom(
                            title: contact.mobileNumber,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark
                                ? AppThemeData.grey5
                                : AppThemeData.grey6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      gradient: gradient,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: AppThemeData.neonGlow(
                        glow,
                        blur: 8,
                        opacity: 0.3,
                      ),
                    ),
                    child: Icon(
                      SolarIconsBold.checkCircle,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _avatar(
    MyContactsModel contact,
    bool isDark, {
    double size = 44,
    LinearGradient? gradient,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: contact.hasProfile
            ? null
            : (gradient ?? AppThemeData.neonPurpleBlueGradient),
        borderRadius: BorderRadius.circular(size * 0.32),
        image: contact.hasProfile
            ? DecorationImage(
                image: NetworkImage(contact.profileImage),
                fit: BoxFit.cover,
              )
            : null,
        boxShadow: contact.hasProfile
            ? null
            : AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 10,
                opacity: 0.15,
              ),
      ),
      child: contact.hasProfile
          ? null
          : Center(
              child: TextCustom(
                title: contact.initials,
                fontSize: size * 0.36,
                fontFamily: FontFamily.bold,
                color: Colors.white,
              ),
            ),
    );
  }

  Widget _rightDetailPanel(bool isDark) {
    return Obx(() {
      final contact = controller.selectedContact.value;
      if (contact == null) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                isDark ? AppThemeData.surfaceVoid : AppThemeData.grey1,
                isDark ? AppThemeData.surfaceDeep : AppThemeData.grey2,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    gradient: AppThemeData.neonPurpleBlueGradient.withColors(
                      opacity: 0.15,
                    ),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Icon(
                    SolarIconsOutline.usersGroupRounded,
                    size: 36,
                    color: AppThemeData.neonPurple.withValues(alpha: 0.4),
                  ),
                ),
                spaceH(height: 16),
                TextCustom(
                  title: 'Select a contact',
                  fontSize: 15,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                spaceH(height: 4),
                TextCustom(
                  title: 'View details here',
                  fontSize: 12,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                ),
              ],
            ),
          ),
        );
      }
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              isDark ? AppThemeData.surfaceObsidian : AppThemeData.primaryWhite,
              isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(
            left: BorderSide(
              color: AppThemeData.neonPurple.withValues(
                alpha: isDark ? 0.15 : 0.08,
              ),
              width: 0.5,
            ),
          ),
        ),
        child: Column(
          children: [
            _detailPanelHeader(contact, isDark),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: _detailContent(contact, isDark),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _detailPanelHeader(MyContactsModel contact, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppThemeData.neonPurple.withValues(
              alpha: isDark ? 0.15 : 0.08,
            ),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              gradient: AppThemeData.neonPurpleBlueGradient.withColors(
                opacity: 0.15,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextCustom(
              title: 'Details',
              fontSize: 11,
              fontFamily: FontFamily.bold,
              color: AppThemeData.neonPurple,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.isDetailPanelOpen.value = false,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                SolarIconsOutline.altArrowRight,
                size: 16,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailContent(MyContactsModel contact, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        spaceH(height: 8),
        _avatar(contact, isDark, size: 88),
        spaceH(height: 16),
        TextCustom(
          title: contact.formattedName,
          fontSize: 20,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        spaceH(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              SolarIconsOutline.phone,
              size: 14,
              color: AppThemeData.neonTeal,
            ),

            spaceW(width: 6),

            TextCustom(
              title: contact.mobileNumber,
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.textNeonTeal : AppThemeData.grey7,
            ),

            spaceW(width: 8),

            GestureDetector(
              onTap: () async {
                final copyText =
                    '''
Name : ${contact.formattedName}
Mobile Number : ${contact.mobileNumber}
''';

                await Clipboard.setData(ClipboardData(text: copyText));

                Get.generalDialog(
                  barrierDismissible: true,
                  barrierLabel: '',
                  barrierColor: Colors.black.withValues(alpha: 0.45),
                  transitionDuration: const Duration(milliseconds: 250),
                  pageBuilder: (_, __, ___) {
                    return Center(
                      child: Material(
                        color: Colors.transparent,
                        child: Container(
                          width: 340,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient:
                                AppThemeData.appleIntelligenceGradientCool,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: AppThemeData.neonGlow(
                              AppThemeData.neonPurple,
                              blur: 22,
                              opacity: 0.25,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 58,
                                height: 58,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: const Icon(
                                  SolarIconsBold.copy,
                                  color: Colors.white,
                                  size: 28,
                                ),
                              ),

                              spaceH(height: 18),

                              TextCustom(
                                title: 'Copied Successfully',
                                fontSize: 18,
                                fontFamily: FontFamily.bold,
                                color: Colors.white,
                              ),

                              spaceH(height: 16),

                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.08),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    TextCustom(
                                      title: 'Name : ${contact.formattedName}',
                                      fontSize: 13,
                                      fontFamily: FontFamily.semiBold,
                                      color: Colors.white,
                                    ),

                                    spaceH(height: 8),

                                    TextCustom(
                                      title:
                                          'Mobile Number : ${contact.mobileNumber}',
                                      fontSize: 13,
                                      fontFamily: FontFamily.medium,
                                      color: Colors.white.withValues(
                                        alpha: 0.9,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );

                Future.delayed(const Duration(seconds: 2), () {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                });
                Future.delayed(const Duration(seconds: 2), () {
                  if (Get.isDialogOpen ?? false) {
                    Get.back();
                  }
                });
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppThemeData.neonCyanMintGradient,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: AppThemeData.neonGlow(
                    AppThemeData.neonMint,
                    blur: 10,
                    opacity: 0.2,
                  ),
                ),
                child: const Icon(
                  SolarIconsOutline.copy,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        spaceH(height: 24),
        _detailInfoCard(contact, isDark),
        spaceH(height: 20),
        _detailActions(contact, isDark),
      ],
    );
  }

  Widget _detailInfoCard(MyContactsModel contact, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: AppThemeData.neonGlowBox(
        glowColor: AppThemeData.neonPurple,
        bgColor: isDark
            ? AppThemeData.surfaceDeep.withValues(alpha: 0.7)
            : AppThemeData.grey1.withValues(alpha: 0.6),
        radius: 16,
        glowOpacity: 0.08,
      ),
      child: Column(
        children: [
          _detailRow(
            'First Name',
            contact.firstName,
            AppThemeData.neonPurple,
            isDark,
          ),
          _detailRow(
            'Last Name',
            contact.lastName,
            AppThemeData.neonBlue,
            isDark,
          ),
          _detailRow(
            'Mobile',
            contact.mobileNumber,
            AppThemeData.neonTeal,
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, Color accent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          TextCustom(
            title: label,
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          const Spacer(),
          Flexible(
            child: TextCustom(
              title: value,
              fontSize: 12,
              fontFamily: FontFamily.semiBold,
              color: isDark
                  ? accent.withValues(alpha: 0.85)
                  : AppThemeData.grey7,
              maxLine: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _detailActions(MyContactsModel contact, bool isDark) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppThemeData.appleIntelligenceGradientCool,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 10,
                opacity: 0.2,
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => controller.openEditDrawer(contact),
              icon: Icon(SolarIconsOutline.pen, size: 16),
              label: TextCustom(
                title: 'Edit Contact',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
        spaceH(height: 10),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppThemeData.danger300.withValues(alpha: 0.4),
                width: 0.5,
              ),
            ),
            child: OutlinedButton.icon(
              onPressed: () => _confirmDelete(contact, isDark),
              icon: Icon(
                SolarIconsOutline.trashBinTrash,
                size: 16,
                color: AppThemeData.danger300,
              ),
              label: TextCustom(
                title: 'Delete Contact',
                fontSize: 13,
                fontFamily: FontFamily.semiBold,
                color: AppThemeData.danger300,
              ),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.transparent),
                backgroundColor: Colors.transparent,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(MyContactsModel contact, bool isDark) {
    Get.dialog(
      AlertDialog(
        backgroundColor: isDark
            ? AppThemeData.surfaceDeep
            : AppThemeData.primaryWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: TextCustom(
          title: 'Delete Contact',
          fontSize: 18,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
        ),
        content: TextCustom(
          title: 'Are you sure you want to delete ${contact.formattedName}?',
          fontSize: 14,
          fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: TextCustom(
              title: 'Cancel',
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              controller.deleteContact(contact.docId);
            },
            child: TextCustom(
              title: 'Delete',
              fontSize: 14,
              fontFamily: FontFamily.bold,
              color: AppThemeData.danger300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _addEditDrawer(bool isDark, bool isMobile) {
    return GestureDetector(
      onTap: controller.closeDrawer,
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Align(
          alignment: Alignment.centerRight,
          child: GestureDetector(
            onTap: () {},
            child: Container(
              width: isMobile ? Get.width : 440,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isDark
                        ? AppThemeData.surfaceObsidian
                        : AppThemeData.primaryWhite,
                    isDark ? AppThemeData.surfaceDeep : AppThemeData.grey1,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(28),
                ),
                border: Border.all(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.15),
                  width: 0.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(28),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Column(
                    children: [
                      _drawerHeader(isDark),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: _drawerForm(isDark),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _drawerHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 18, 16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppThemeData.neonPurple.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: AppThemeData.appleIntelligenceGradientCool,
              borderRadius: BorderRadius.circular(12),
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 8,
                opacity: 0.2,
              ),
            ),
            child: Icon(SolarIconsBold.user, color: Colors.white, size: 18),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: controller.isEditing.value
                      ? 'Edit Contact'
                      : 'Add Contact',
                  fontSize: 17,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                TextCustom(
                  title: controller.isEditing.value
                      ? 'Update contact details'
                      : 'Create a new contact',
                  fontSize: 11,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.closeDrawer,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.surfaceElevated
                    : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppThemeData.neonPurple.withValues(alpha: 0.1),
                  width: 0.5,
                ),
              ),
              child: Icon(
                SolarIconsOutline.closeCircle,
                size: 18,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerForm(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(child: _profileImageSection(isDark)),
        spaceH(height: 24),
        Row(
          children: [
            Expanded(
              child: _glassField(
                controller.firstNameController,
                'First Name',
                SolarIconsOutline.user,
                AppThemeData.neonPurple,
                isDark,
              ),
            ),
            spaceW(width: 12),
            Expanded(
              child: _glassField(
                controller.lastNameController,
                'Last Name',
                SolarIconsOutline.user,
                AppThemeData.neonBlue,
                isDark,
              ),
            ),
          ],
        ),
        spaceH(height: 16),
        _glassField(
          controller.mobileNumberController,
          'Mobile Number',
          SolarIconsOutline.phone,
          AppThemeData.neonTeal,
          isDark,
          keyboardType: TextInputType.phone,
        ),
        spaceH(height: 28),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppThemeData.appleIntelligenceGradientCool,
              borderRadius: BorderRadius.circular(14),
              boxShadow: AppThemeData.neonGlow(
                AppThemeData.neonPurple,
                blur: 12,
                opacity: 0.25,
              ),
            ),
            child: ElevatedButton.icon(
              onPressed: () => controller.saveContact(),
              icon: Icon(SolarIconsBold.checkCircle, size: 18),
              label: TextCustom(
                title: controller.isEditing.value
                    ? 'Update Contact'
                    : 'Save Contact',
                fontSize: 14,
                fontFamily: FontFamily.semiBold,
                color: Colors.white,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _profileImageSection(bool isDark) {
    return Column(
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            gradient: AppThemeData.neonPurpleBlueGradient.withColors(
              opacity: 0.2,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppThemeData.neonPurple.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: Icon(
            SolarIconsOutline.camera,
            size: 32,
            color: AppThemeData.neonPurple.withValues(alpha: 0.6),
          ),
        ),
        spaceH(height: 8),
        TextCustom(
          title: 'Tap to upload photo',
          fontSize: 11,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      ],
    );
  }

  Widget _glassField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    Color accent,
    bool isDark, {
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: AppThemeData.neonGlowBox(
        glowColor: accent,
        bgColor: isDark
            ? AppThemeData.surfaceDeep.withValues(alpha: 0.6)
            : AppThemeData.grey1.withValues(alpha: 0.6),
        radius: 14,
        glowOpacity: 0.06,
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: keyboardType,
        style: TextStyle(
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            icon,
            size: 18,
            color: accent.withValues(alpha: 0.7),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _emptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppThemeData.neonPurpleBlueGradient.withColors(
                opacity: 0.15,
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(
              SolarIconsOutline.usersGroupRounded,
              size: 40,
              color: AppThemeData.neonPurple.withValues(alpha: 0.4),
            ),
          ),
          spaceH(height: 20),
          TextCustom(
            title: 'No contacts yet',
            fontSize: 17,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 6),
          TextCustom(
            title: 'Add your first contact or import from VCF',
            fontSize: 13,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  Widget _quickStats(bool isDark) {
    return Obx(
          () => Row(
        children: [
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _interactiveStatChip(
                    'All (${controller.contacts.length})',
                    SolarIconsBold.usersGroupRounded,
                    ContactFilter.all,
                    AppThemeData.neonPurple,
                    AppThemeData.neonPurpleDim,
                    isDark,
                  ),
                  spaceW(width: 8),
                  _interactiveStatChip(
                    'Named (${controller.contacts.where((c) => c.firstName.isNotEmpty).length})',
                    SolarIconsBold.clockCircle,
                    ContactFilter.named,
                    AppThemeData.neonTeal,
                    AppThemeData.neonTealDim,
                    isDark,
                  ),
                  spaceW(width: 8),
                  _interactiveStatChip(
                    'Photos (${controller.contacts.where((c) => c.hasProfile).length})',
                    SolarIconsBold.camera,
                    ContactFilter.withPhoto,
                    AppThemeData.neonMint,
                    AppThemeData.neonMintDim,
                    isDark,
                  ),
                ],
              ),
            ),
          ),
          spaceW(width: 8),

          // Sort Dropdown Button Trigger
          PopupMenuButton<ContactSort>(
            onSelected: (ContactSort mode) => controller.changeSort(mode),
            icon: Icon(
              SolarIconsOutline.sortFromTopToBottom,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              size: 20,
            ),
            color: isDark ? AppThemeData.surfaceDeep : AppThemeData.primaryWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            itemBuilder: (context) => [
              _buildSortMenuItem('Name (A-Z)', ContactSort.nameAsc, SolarIconsOutline.sortFromTopToBottom, isDark),
              _buildSortMenuItem('Name (Z-A)', ContactSort.nameDesc, SolarIconsOutline.sortFromBottomToTop, isDark),
              _buildSortMenuItem('Reverse/Newest', ContactSort.newest, SolarIconsOutline.clockCircle, isDark),
            ],
          )
        ],
      ),
    );
  }

  Widget _shimmerList(bool isDark) {
    final base = isDark ? AppThemeData.surfaceElevated : AppThemeData.grey3;
    final highlight = isDark ? AppThemeData.surfaceLight : AppThemeData.grey2;
    return ListView.builder(
      itemCount: 6,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Shimmer.fromColors(
          baseColor: base,
          highlightColor: highlight,
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: isDark
                  ? AppThemeData.surfaceDeep
                  : AppThemeData.primaryWhite,
              borderRadius: BorderRadius.circular(22),
            ),
          ),
        ),
      ),
    );
  }
}

extension GradientOpacity on LinearGradient {
  LinearGradient withColors({double? opacity}) {
    return LinearGradient(
      colors: opacity != null
          ? this.colors.map((c) => c.withValues(alpha: opacity)).toList()
          : this.colors,
      begin: this.begin,
      end: this.end,
      stops: this.stops,
      tileMode: this.tileMode,
      transform: this.transform,
    );
  }
}
