import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/dependency/shimmer.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../constant/show_toast.dart';
import '../controllers/smart_map_dashboard_controller.dart';

class SmartMapDashboardView extends GetView<SmartMapDashboardController> {
  const SmartMapDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MahekResponsive.compatIsMobile(context);
    controller.isDarkMode.value = isDark;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey1,
      body: Obx(() {
        if (!controller.permissionGranted.value && controller.isLoading.value) {
          return _loadingState(isDark);
        }
        if (!controller.permissionGranted.value) {
          return _permissionDeniedState(isDark);
        }
        return Stack(
          children: [
            _mapLayer(isDark),
            if (isMobile)
              _mobileBottomSheet(isDark)
            else ...[
              _desktopFloatingPanel(isDark),
              _panelToggleButton(isDark),
            ],
            _floatingControls(isDark, isMobile),
            _zoomControls(isDark, isMobile),
          ],
        );
      }),
    );
  }

  Widget _mapLayer(bool isDark) {
    return Obx(() {
      final dark = controller.isDarkMode.value;
      return GoogleMap(
        key: ValueKey('map_${dark}_${controller.mapKeyCounter.value}'),
        mapType: controller.currentMapType.value,
        initialCameraPosition: controller.initialCamera,
        onMapCreated: (mapCtrl) {
          controller.onMapCreated(mapCtrl, dark);
          controller.syncMapToCurrentLocation();
        },
        myLocationEnabled: controller.permissionGranted.value,
        myLocationButtonEnabled: false,
        zoomControlsEnabled: false,
        compassEnabled: true,
        mapToolbarEnabled: false,
        markers: controller.allMarkers,
        style: dark ? SmartMapDashboardController.darkMapStyle : null,
      );
    });
  }

  Widget _floatingControls(bool isDark, bool isMobile) {
    return Positioned(
      top: isMobile ? 16 : 24,
      left: isMobile ? 16 : 24,
      child: Column(
        children: [
          _glassButton(
            icon: SolarIconsBold.gps,
            onTap: controller.recenterMap,
            isDark: isDark,
            tooltip: 'Recenter',
          ),
          spaceH(height: 8),
          _glassButton(
            icon: SolarIconsOutline.refresh,
            onTap: controller.refreshLocation,
            isDark: isDark,
            tooltip: 'Refresh',
          ),
          spaceH(height: 8),
          _glassButton(
            icon: SolarIconsOutline.copy,
            onTap: controller.copyCoordinates,
            isDark: isDark,
            tooltip: 'Copy Coords',
          ),
          spaceH(height: 8),
          _glassButton(
            icon: SolarIconsOutline.share,
            onTap: controller.shareLocation,
            isDark: isDark,
            tooltip: 'Share',
          ),
          spaceH(height: 8),
          _glassButton(
            icon: SolarIconsOutline.map,
            onTap: controller.openInGoogleMaps,
            isDark: isDark,
            tooltip: 'Open Maps',
          ),
        ],
      ),
    );
  }

  Widget _zoomControls(bool isDark, bool isMobile) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      right: controller.panelExpanded.value ? 396 : 72,
      bottom: 24,
      child: Column(
        children: [
          _glassButton(
            icon: SolarIconsBold.addCircle,
            onTap: controller.zoomIn,
            isDark: isDark,
            tooltip: 'Zoom In',
            size: 40,
          ),
          spaceH(height: 4),
          _glassButton(
            icon: SolarIconsBold.minusCircle,
            onTap: controller.zoomOut,
            isDark: isDark,
            tooltip: 'Zoom Out',
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _glassButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
    String? tooltip,
    double size = 44,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onTap,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: size,
            height: size,
            decoration: BoxDecoration(
              gradient: isDark
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemeData.grey10.withValues(alpha: 0.9),
                        AppThemeData.grey9.withValues(alpha: 0.8),
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppThemeData.primaryWhite.withValues(alpha: 0.95),
                        AppThemeData.primaryWhite.withValues(alpha: 0.85),
                      ],
                    ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark
                    ? AppThemeData.primary50.withValues(alpha: 0.15)
                    : AppThemeData.primary50.withValues(alpha: 0.1),
                width: 0.8,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: AppThemeData.primary50.withValues(alpha: 0.06),
                  blurRadius: 12,
                  spreadRadius: -2,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Icon(
                  icon,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  size: size == 40 ? 18 : 20,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelToggleButton(bool isDark) {
    return Obx(() {
      if (controller.panelExpanded.value) return const SizedBox.shrink();
      return Positioned(
        right: 0,
        top: 24,
        bottom: 24,
        child: Center(
          child: GestureDetector(
            onTap: () => controller.panelExpanded.value = true,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                width: 48,
                decoration: BoxDecoration(
                  gradient: isDark
                      ? LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppThemeData.grey10.withValues(alpha: 0.95),
                            AppThemeData.grey10.withValues(alpha: 0.88),
                          ],
                        )
                      : LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppThemeData.primaryWhite.withValues(alpha: 0.98),
                            AppThemeData.primaryWhite.withValues(alpha: 0.92),
                          ],
                        ),
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                    right: Radius.circular(4),
                  ),
                  border: Border.all(
                    color: isDark
                        ? AppThemeData.primary50.withValues(alpha: 0.12)
                        : AppThemeData.primary50.withValues(alpha: 0.08),
                    width: 0.8,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppThemeData.primary50.withValues(alpha: 0.04),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 24,
                      offset: const Offset(-4, 0),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(20),
                    right: Radius.circular(4),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppThemeData.primary50,
                                const Color(0xFF6C63FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: AppThemeData.primary50.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            SolarIconsBold.mapPoint,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                        spaceH(height: 10),
                        Container(
                          width: 3,
                          height: 24,
                          decoration: BoxDecoration(
                            color: AppThemeData.primary50.withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        spaceH(height: 10),
                        Icon(
                          SolarIconsOutline.altArrowRight,
                          color: isDark
                              ? AppThemeData.grey5
                              : AppThemeData.grey6,
                          size: 18,
                        ),
                        spaceH(height: 10),
                        Obx(
                          () => Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: controller.permissionGranted.value
                                  ? AppThemeData.success400
                                  : AppThemeData.danger300,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      (controller.permissionGranted.value
                                              ? AppThemeData.success400
                                              : AppThemeData.danger300)
                                          .withValues(alpha: 0.5),
                                  blurRadius: 6,
                                ),
                              ],
                            ),
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
    });
  }

  Widget _desktopFloatingPanel(bool isDark) {
    return Obx(
      () => AnimatedPositioned(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
        top: 24,
        right: controller.panelExpanded.value ? 24 : -400,
        bottom: 24,
        width: 370,
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? AppThemeData.grey10.withValues(alpha: 0.92)
                : AppThemeData.primaryWhite.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark
                  ? AppThemeData.primary50.withValues(alpha: 0.12)
                  : AppThemeData.primary50.withValues(alpha: 0.08),
              width: 0.8,
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: isDark ? 0.05 : 0.03),
                blurRadius: 32,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 24,
                offset: const Offset(-4, 0),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
              child: Column(
                children: [
                  _panelHeader(isDark),
                  _panelTabs(isDark),
                  Expanded(
                    child: Obx(
                      () => IndexedStack(
                        index: controller.selectedTabIndex.value,
                        children: [
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _infoTab(isDark),
                          ),
                          SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: _searchTab(isDark),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 14, 14),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? AppThemeData.primary50.withValues(alpha: 0.08)
                : AppThemeData.primary50.withValues(alpha: 0.06),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeData.primary50,
                  const Color(0xFF6C63FF),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppThemeData.primary50.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(SolarIconsBold.mapPoint, color: Colors.white, size: 18),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Smart Map',
                  fontSize: 16,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
                Obx(
                  () => TextCustom(
                    title: controller.isAddressLoading.value
                        ? 'Resolving address...'
                        : (controller.currentAddress.value.isEmpty
                              ? 'No address yet'
                              : controller.locationModel.value?.shortAddress ??
                                    'Located'),
                    fontSize: 11,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                    maxLine: 1,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: controller.togglePanel,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark
                    ? AppThemeData.grey8.withValues(alpha: 0.3)
                    : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
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

  Widget _panelTabs(bool isDark) {
    return Obx(() {
      final selected = controller.selectedTabIndex.value;
      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
        child: Row(
          children: [
            _tabButton(
              'Info',
              SolarIconsOutline.infoCircle,
              0,
              selected,
              isDark,
            ),
            spaceW(width: 6),
            _tabButton(
              'Search',
              SolarIconsOutline.cardSearch,
              1,
              selected,
              isDark,
            ),
          ],
        ),
      );
    });
  }

  Widget _tabButton(
    String label,
    IconData icon,
    int index,
    int selected,
    bool isDark,
  ) {
    final isActive = selected == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isActive
                ? AppThemeData.primary50.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            border: isActive
                ? Border.all(
                    color: AppThemeData.primary50.withValues(alpha: 0.3),
                    width: 0.5,
                  )
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: isActive
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              ),
              spaceW(width: 4),
              TextCustom(
                title: label,
                fontSize: 11,
                fontFamily: isActive ? FontFamily.bold : FontFamily.medium,
                color: isActive
                    ? AppThemeData.primary50
                    : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _liveLocationCard(isDark),
        spaceH(height: 16),
        _coordinatesCard(isDark),
        spaceH(height: 16),
        _addressCard(isDark),
        spaceH(height: 16),
        _mapTypeSwitcher(isDark),
        spaceH(height: 16),
        _locationDetails(isDark),
        spaceH(height: 20),
        _actionButtons(isDark),
      ],
    );
  }

  Widget _searchTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _searchBar(isDark),
        spaceH(height: 12),
        GestureDetector(
          onTap: controller.recenterMap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeData.success400.withValues(alpha: 0.10),
                  AppThemeData.success400.withValues(alpha: 0.04),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppThemeData.success400.withValues(alpha: 0.20),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppThemeData.success400.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    SolarIconsBold.gps,
                    size: 16,
                    color: AppThemeData.success400,
                  ),
                ),
                spaceW(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: 'Go to current location',
                        fontSize: 12,
                        fontFamily: FontFamily.semiBold,
                        color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      ),
                      TextCustom(
                        title: controller.currentAddress.value.isEmpty
                            ? 'Center map on your position'
                            : controller.currentAddress.value,
                        fontSize: 10,
                        fontFamily: FontFamily.regular,
                        color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                        maxLine: 1,
                      ),
                    ],
                  ),
                ),
                Icon(
                  SolarIconsOutline.altArrowRight,
                  size: 16,
                  color: AppThemeData.success400,
                ),
              ],
            ),
          ),
        ),
        spaceH(height: 12),
        Obx(() {
          if (controller.isSearching.value) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: const MahekLoader(size: 20, showBranding: false),
              ),
            );
          }
          if (controller.searchQuery.value.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: TextCustom(
                  title: 'Search for a location',
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ),
            );
          }
          return Column(
            children: controller.searchResults
                .map((r) => _searchResultItem(r, isDark))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _searchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: isDark
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.primaryBlack.withValues(alpha: 0.4),
                  AppThemeData.primaryBlack.withValues(alpha: 0.2),
                ],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppThemeData.grey1.withValues(alpha: 0.6),
                  AppThemeData.grey1.withValues(alpha: 0.3),
                ],
              ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? AppThemeData.primary50.withValues(alpha: 0.1)
              : AppThemeData.primary50.withValues(alpha: 0.08),
          width: 0.5,
        ),
      ),
      child: TextField(
        controller: controller.searchController,
        onSubmitted: controller.searchPlace,
        onChanged: (value) {
          if (value.trim().length >= 2) {
            controller.searchPlace(value);
          } else {
            controller.searchResults.clear();
          }
        },
        style: TextStyle(
          color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          fontSize: 13,
        ),
        decoration: InputDecoration(
          hintText: 'Search a place...',
          hintStyle: TextStyle(
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            fontSize: 13,
          ),
          prefixIcon: Icon(
            SolarIconsOutline.cardSearch,
            size: 18,
            color: AppThemeData.primary50.withValues(alpha: 0.6),
          ),
          suffixIcon: Obx(
            () => controller.searchQuery.value.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      SolarIconsOutline.closeCircle,
                      size: 16,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                    onPressed: () {
                      controller.searchController.clear();
                      controller.searchResults.clear();
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

  Widget _searchResultItem(Map<String, dynamic> result, bool isDark) {
    return GestureDetector(
      onTap: () => controller.goToSearchResult(result),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.primaryBlack.withValues(alpha: 0.2)
              : AppThemeData.grey1.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.1)
                : AppThemeData.grey3.withValues(alpha: 0.2),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                SolarIconsBold.mapPoint,
                size: 16,
                color: AppThemeData.primary50,
              ),
            ),
            spaceW(width: 10),
            Expanded(
              child: TextCustom(
                title: result['address'] ?? '',
                fontSize: 12,
                fontFamily: FontFamily.medium,
                color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
                maxLine: 2,
              ),
            ),
            Icon(
              SolarIconsOutline.altArrowRight,
              size: 14,
              color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
          ],
        ),
      ),
    );
  }

  Widget _savedTab(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            TextCustom(
              title: 'Saved Locations',
              fontSize: 13,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => controller.saveCurrentLocation(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppThemeData.primary50.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppThemeData.primary50.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      SolarIconsOutline.bookmark,
                      size: 12,
                      color: AppThemeData.primary50,
                    ),
                    spaceW(width: 4),
                    TextCustom(
                      title: 'Save Current',
                      fontSize: 10,
                      fontFamily: FontFamily.bold,
                      color: AppThemeData.primary50,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        spaceH(height: 12),
        Obx(() {
          if (controller.savedLocations.isEmpty) {
            return Container(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    SolarIconsOutline.bookmark,
                    size: 40,
                    color: isDark ? AppThemeData.grey8 : AppThemeData.grey3,
                  ),
                  spaceH(height: 12),
                  TextCustom(
                    title: 'No saved locations yet',
                    fontSize: 13,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                  spaceH(height: 4),
                  TextCustom(
                    title: 'Save your current location to access it quickly',
                    fontSize: 11,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return Column(
            children: controller.savedLocations.asMap().entries.map((entry) {
              final index = entry.key;
              final loc = entry.value;
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: Dismissible(
                  key: Key('saved_$index'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (_) => controller.removeSavedLocation(index),
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppThemeData.danger300.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      SolarIconsOutline.trashBin2,
                      color: AppThemeData.danger300,
                      size: 18,
                    ),
                  ),
                  child: GestureDetector(
                    onTap: () => controller.goToSavedLocation(loc),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppThemeData.primaryBlack.withValues(alpha: 0.2)
                            : AppThemeData.grey1.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppThemeData.grey8.withValues(alpha: 0.1)
                              : AppThemeData.grey3.withValues(alpha: 0.2),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppThemeData.neonTeal,
                                  AppThemeData.neonMint,
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              SolarIconsBold.bookmark,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                          spaceW(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextCustom(
                                  title: loc.name,
                                  fontSize: 12,
                                  fontFamily: FontFamily.semiBold,
                                  color: isDark
                                      ? AppThemeData.grey1
                                      : AppThemeData.grey10,
                                ),
                                TextCustom(
                                  title: loc.address,
                                  fontSize: 10,
                                  fontFamily: FontFamily.regular,
                                  color: isDark
                                      ? AppThemeData.grey6
                                      : AppThemeData.grey5,
                                  maxLine: 1,
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            SolarIconsOutline.altArrowRight,
                            size: 14,
                            color: isDark
                                ? AppThemeData.grey6
                                : AppThemeData.grey5,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          );
        }),
      ],
    );
  }

  Widget _liveLocationCard(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppThemeData.success400.withValues(alpha: 0.08),
              AppThemeData.success400.withValues(alpha: 0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppThemeData.success400.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppThemeData.success400.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                SolarIconsBold.gps,
                color: AppThemeData.success400,
                size: 22,
              ),
            ),
            spaceW(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextCustom(
                    title: 'Live Location',
                    fontSize: 11,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 2),
                  TextCustom(
                    title: controller.permissionGranted.value
                        ? 'Active'
                        : 'Unavailable',
                    fontSize: 15,
                    fontFamily: FontFamily.bold,
                    color: controller.permissionGranted.value
                        ? AppThemeData.success400
                        : AppThemeData.danger300,
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: controller.permissionGranted.value
                    ? AppThemeData.success400
                    : AppThemeData.danger300,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color:
                        (controller.permissionGranted.value
                                ? AppThemeData.success400
                                : AppThemeData.danger300)
                            .withValues(alpha: 0.5),
                    blurRadius: 6,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _coordinatesCard(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.primaryBlack.withValues(alpha: 0.3)
              : AppThemeData.grey1.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.15)
                : AppThemeData.grey3.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Coordinates',
              fontSize: 11,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 10),
            Row(
              children: [
                Expanded(
                  child: _coordValue(
                    'Lat',
                    controller.latitude.value.toStringAsFixed(6),
                    isDark,
                  ),
                ),
                spaceW(width: 10),
                Expanded(
                  child: _coordValue(
                    'Lng',
                    controller.longitude.value.toStringAsFixed(6),
                    isDark,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _coordValue(String label, String value, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark
            ? AppThemeData.grey9.withValues(alpha: 0.5)
            : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppThemeData.grey8.withValues(alpha: 0.2)
              : AppThemeData.grey3.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: label,
            fontSize: 9,
            fontFamily: FontFamily.bold,
            color: AppThemeData.primary50,
          ),
          spaceH(height: 2),
          TextCustom(
            title: value,
            fontSize: 14,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
        ],
      ),
    );
  }

  Widget _addressCard(bool isDark) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.primaryBlack.withValues(alpha: 0.3)
              : AppThemeData.grey1.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.15)
                : AppThemeData.grey3.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  SolarIconsOutline.map,
                  size: 14,
                  color: AppThemeData.primary50,
                ),
                spaceW(width: 6),
                TextCustom(
                  title: 'Address',
                  fontSize: 11,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
                const Spacer(),
                if (controller.isAddressLoading.value)
                  MahekLoader(size: 12, showBranding: false)
                else
                  GestureDetector(
                    onTap: () {
                      if (controller.currentAddress.value.isNotEmpty) {
                        Clipboard.setData(
                          ClipboardData(text: controller.currentAddress.value),
                        );
                        ShowToastDialog.showSuccess('Address copied');
                      }
                    },
                    child: Icon(
                      SolarIconsOutline.copy,
                      size: 14,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                  ),
              ],
            ),
            spaceH(height: 8),
            TextCustom(
              title: controller.isAddressLoading.value
                  ? 'Fetching address...'
                  : controller.currentAddress.value.isEmpty
                  ? 'Address unavailable'
                  : controller.currentAddress.value,
              fontSize: 13,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
              maxLine: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _mapTypeSwitcher(bool isDark) {
    return Obx(
      () => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Map Style',
            fontSize: 11,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
          ),
          spaceH(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _mapTypeChip('Standard', MapType.normal, isDark),
              _mapTypeChip('Satellite', MapType.satellite, isDark),
              _mapTypeChip('Terrain', MapType.terrain, isDark),
              _mapTypeChip('Hybrid', MapType.hybrid, isDark),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mapTypeChip(String label, MapType type, bool isDark) {
    final isSelected = controller.currentMapType.value == type;
    return GestureDetector(
      onTap: () => controller.changeMapType(type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary50.withValues(alpha: 0.15)
              : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? AppThemeData.primary50
                : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            width: isSelected ? 1.2 : 0.5,
          ),
        ),
        child: TextCustom(
          title: label,
          fontSize: 11,
          fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
          color: isSelected
              ? AppThemeData.primary50
              : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
        ),
      ),
    );
  }

  Widget _locationDetails(bool isDark) {
    return Obx(() {
      final model = controller.locationModel.value;
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? AppThemeData.primaryBlack.withValues(alpha: 0.3)
              : AppThemeData.grey1.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark
                ? AppThemeData.grey8.withValues(alpha: 0.15)
                : AppThemeData.grey3.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(
              title: 'Details',
              fontSize: 11,
              fontFamily: FontFamily.bold,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceH(height: 8),
            if (model?.subLocality != null)
              _detailRow('Area', model!.subLocality!, isDark),
            if (model?.city != null) _detailRow('City', model!.city!, isDark),
            if (model?.state != null)
              _detailRow('State', model!.state!, isDark),
            if (model?.country != null)
              _detailRow('Country', model!.country!, isDark),
            if (model?.postalCode != null)
              _detailRow('Postal', model!.postalCode!, isDark),
            if (model?.updatedAt != null)
              _detailRow('Updated', _formatTime(model!.updatedAt!), isDark),
            if (model?.subLocality == null &&
                model?.city == null &&
                model?.state == null &&
                model?.country == null)
              _detailRow(
                'Status',
                controller.isAddressLoading.value ? 'Loading...' : 'No data',
                isDark,
              ),
          ],
        ),
      );
    });
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          TextCustom(
            title: label,
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          const Spacer(),
          TextCustom(
            title: value,
            fontSize: 11,
            fontFamily: FontFamily.semiBold,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }

  Widget _actionButtons(bool isDark) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: controller.recenterMap,
                icon: Icon(SolarIconsBold.gps, size: 16),
                label: const TextCustom(
                  title: 'Recenter',
                  fontSize: 13,
                  fontFamily: FontFamily.semiBold,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary50,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            spaceW(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: controller.shareLocation,
                icon: Icon(
                  SolarIconsOutline.share,
                  size: 16,
                  color: AppThemeData.primary50,
                ),
                label: TextCustom(
                  title: 'Share',
                  fontSize: 13,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primary50,
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppThemeData.primary50),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _mobileBottomSheet(bool isDark) {
    return Obx(() {
      final expanded = controller.panelExpanded.value;
      return Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOutCubic,
          height: expanded ? 480 : 80,
          decoration: BoxDecoration(
            color: isDark
                ? AppThemeData.grey10.withValues(alpha: 0.95)
                : AppThemeData.primaryWhite.withValues(alpha: 0.97),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? AppThemeData.primary50.withValues(alpha: 0.1)
                    : AppThemeData.primary50.withValues(alpha: 0.08),
                width: 0.8,
              ),
            ),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.primary50.withValues(alpha: isDark ? 0.03 : 0.02),
                blurRadius: 32,
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: controller.togglePanel,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppThemeData.grey7
                                  : AppThemeData.grey4,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          if (!expanded) ...[
                            spaceH(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Container(
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          AppThemeData.primary50,
                                          const Color(0xFF6C63FF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      SolarIconsBold.mapPoint,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                  ),
                                  spaceW(width: 10),
                                  Expanded(
                                    child: TextCustom(
                                      title: controller.currentAddress.value.isEmpty
                                          ? 'Tap to expand'
                                          : controller.locationModel.value
                                                ?.shortAddress ??
                                                'Unknown',
                                      fontSize: 13,
                                      fontFamily: FontFamily.medium,
                                      color: isDark
                                          ? AppThemeData.grey1
                                          : AppThemeData.grey10,
                                      maxLine: 1,
                                    ),
                                  ),
                                  Icon(
                                    SolarIconsBold.gps,
                                    color: AppThemeData.success400,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (expanded) ...[
                    _panelTabs(isDark),
                    Expanded(
                      child: Obx(
                        () => IndexedStack(
                          index: controller.selectedTabIndex.value,
                          children: [
                            SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: _infoTab(isDark),
                            ),
                            SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              child: _searchTab(isDark),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    });
  }

  Widget _loadingState(bool isDark) {
    final base = isDark ? AppThemeData.grey9 : AppThemeData.grey3;
    final highlight = isDark ? AppThemeData.grey8 : AppThemeData.grey2;
    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey1,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppThemeData.primary50.withValues(alpha: 0.12),
                    AppThemeData.primary50.withValues(alpha: 0.04),
                  ],
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: AppThemeData.primary50.withValues(alpha: 0.15),
                  width: 0.8,
                ),
              ),
              child: Icon(
                SolarIconsBold.mapPoint,
                size: 40,
                color: AppThemeData.primary50.withValues(alpha: 0.6),
              ),
            ),
            spaceH(height: 24),
            Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: 160,
                height: 12,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.primaryBlack
                      : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            spaceH(height: 10),
            Shimmer.fromColors(
              baseColor: base,
              highlightColor: highlight,
              child: Container(
                width: 120,
                height: 10,
                decoration: BoxDecoration(
                  color: isDark
                      ? AppThemeData.primaryBlack
                      : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
            ),
            spaceH(height: 16),
            TextCustom(
              title: 'Initializing map...',
              fontSize: 13,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
          ],
        ),
      ),
    );
  }

  Widget _permissionDeniedState(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey1,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppThemeData.danger300.withValues(alpha: 0.12),
                      AppThemeData.danger300.withValues(alpha: 0.04),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppThemeData.danger300.withValues(alpha: 0.15),
                    width: 0.8,
                  ),
                ),
                child: Icon(
                  SolarIconsOutline.map,
                  size: 40,
                  color: AppThemeData.danger300.withValues(alpha: 0.6),
                ),
              ),
              spaceH(height: 24),
              TextCustom(
                title: 'Location Permission Required',
                fontSize: 18,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              spaceH(height: 8),
              TextCustom(
                title:
                    'Please grant location access to use Smart Map Dashboard',
                fontSize: 14,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                textAlign: TextAlign.center,
              ),
              spaceH(height: 28),
              ElevatedButton.icon(
                onPressed: controller.requestPermission,
                icon: Icon(SolarIconsBold.gps, size: 18),
                label: const TextCustom(
                  title: 'Grant Permission',
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: Colors.white,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppThemeData.primary50,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                  shadowColor: AppThemeData.primary50.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
