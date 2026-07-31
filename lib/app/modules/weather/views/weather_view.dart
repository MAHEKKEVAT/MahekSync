import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/services/weather_api.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart' hide AnimatedBuilder;
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/weather_particles.dart';
import 'package:maheksync/app/theme/weather_theme.dart';
import 'weather_painter.dart';
import 'weather_hourly_chart.dart';
import 'weather_forecast_row.dart';
import 'weather_detail_cards.dart';
import '../controllers/weather_controller.dart';

class WeatherView extends GetView<WeatherController> {
  const WeatherView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentWeather.value == null) {
          return _buildLoading();
        }
        return _buildBody(context);
      }),
    );
  }

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppThemeData.surfaceDeep,
            AppThemeData.surfaceDark,
            AppThemeData.surfaceMid,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: MahekLoader(
          message: 'Loading weather...',
          size: 50,
          textSize: 16,
        ),
      ),
    );
  }

  Widget _buildError() {
    return _WeatherBackgroundWrapper(
      condition: controller.weatherCondition,
      isNight: controller.isNight,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded,
                color: AppThemeData.grey7, size: 64),
            spaceH(height: 20),
            TextCustom(
              title: 'Unable to load weather',
              fontSize: 20,
              fontFamily: FontFamily.medium,
              color: AppThemeData.grey4,
            ),
            spaceH(height: 8),
            TextCustom(
              title: 'Please check your connection and try again.',
              fontSize: 14,
              color: AppThemeData.grey5,
            ),
            spaceH(height: 28),
            GestureDetector(
              onTap: () => controller.fetchAll(),
                child: PremiumGlassCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  child: TextCustom(
                  title: 'Retry',
                  fontSize: 15,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primaryWhite,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.hasError.value && controller.currentWeather.value == null) {
      return _buildError();
    }

    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    return Stack(
      children: [
        _WeatherBackgroundWrapper(
          condition: controller.weatherCondition,
          isNight: controller.isNight,
        ),
        SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1700),
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  isDesktop ? 32 : 16,
                  isDesktop ? 24 : 12,
                  isDesktop ? 32 : 16,
                  isDesktop ? 40 : 32,
                ),
                child: Column(
                  children: [
                    if (isDesktop) ...[
                      _buildTopBar(context),
                      spaceH(height: 8),
                    ],
                    _buildHeroSection(context),
                    spaceH(height: 28),
                    _buildHourlySection(),
                    spaceH(height: 20),
                    _buildForecastSection(),
                    spaceH(height: 20),
                    _buildDetailCardsSection(),
                    spaceH(height: 24),
                    _buildFooter(context),
                  ],
                ),
              ),
            ),
          ),
        ),
        IgnorePointer(
          child: Obx(() => WeatherParticles(
                isRainy: controller.isRainy,
                isSnowy: controller.isSnowy,
                isNight: controller.isNight,
                isClear: controller.weatherCondition == 'clear',
              )),
        ),
      ],
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      children: [
        _buildCityPickerButton(context),
        const Spacer(),
        _buildFooterPills(),
      ],
    );
  }

  Widget _buildCityPickerButton(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return Obx(() {
      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => _showCityPicker(context),
          child: PremiumGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_outlined,
                    color: wt?.textSecondary ?? AppThemeData.grey5, size: 16),
                spaceW(width: 6),
                TextCustom(
                  title: controller.cityName.value,
                  fontSize: 14,
                  fontFamily: FontFamily.medium,
                  color: wt?.textPrimary ?? AppThemeData.primaryWhite,
                ),
                spaceW(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: wt?.textMuted ?? AppThemeData.grey5, size: 16),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFooterPills() {
    return Obx(() {
      return Row(
        children: [
          _buildMiniPill(
            icon: Icons.wifi_tethering_rounded,
            label: controller.lastUpdatedText,
          ),
          spaceW(width: 8),
          _buildMiniPill(
            icon: Icons.my_location_rounded,
            label:
                '${(controller.latitude.value ?? 0).toStringAsFixed(2)}°, ${(controller.longitude.value ?? 0).toStringAsFixed(2)}°',
          ),
        ],
      );
    });
  }

  Widget _buildMiniPill({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppThemeData.surfaceBorder,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppThemeData.surfaceBorder),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppThemeData.grey6, size: 12),
          spaceW(width: 4),
          TextCustom(
            title: label,
            fontSize: 11,
            fontFamily: FontFamily.medium,
            color: AppThemeData.grey5,
          ),
        ],
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;
    final tempSize = isDesktop ? 120.0 : 96.0;
    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return Obx(() {
      final cw = controller.currentWeather.value;
      if (cw == null) return const SizedBox.shrink();

      final conditionGlow = WeatherBackground.getConditionGlow(
        controller.weatherCondition,
        controller.isNight,
      );

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isDesktop) ...[
            _buildCityPickerButton(context),
            spaceH(height: 12),
          ],
          WeatherIcon(
            code: cw.weatherCode,
            size: isDesktop ? 80 : 60,
            animate: true,
            color: conditionGlow,
          ),
          spaceH(height: 8),
          _AnimatedTemperature(
            temp: cw.temperature,
            formatTemp: controller.formatTemp,
            fontSize: tempSize,
          ),
          spaceH(height: 4),
          TextCustom(
            title: cw.conditionText,
            fontSize: isDesktop ? 20 : 17,
            fontFamily: FontFamily.medium,
            color: wt?.textPrimary ?? AppThemeData.primaryWhite,
          ),
          spaceH(height: 4),
          TextCustom(
            title: controller.feelsLikeString,
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: wt?.textMuted ?? AppThemeData.grey5,
          ),
          spaceH(height: 8),
          _buildHighLowRow(),
          spaceH(height: 16),
          _buildQuickBadges(context),
        ],
      );
    });
  }

  Widget _buildHighLowRow() {
    if (controller.forecast.isEmpty) return const SizedBox.shrink();
    final today = controller.forecast.first;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextCustom(
          title: 'H:${controller.tempString(today.maxTemp)}',
          fontSize: 15,
          fontFamily: FontFamily.medium,
          color: AppThemeData.grey4,
        ),
        spaceW(width: 12),
        Container(
          width: 1,
          height: 12,
          color: AppThemeData.grey7,
        ),
        spaceW(width: 12),
        TextCustom(
          title: 'L:${controller.tempString(today.minTemp)}',
          fontSize: 15,
          fontFamily: FontFamily.medium,
          color: AppThemeData.grey5,
        ),
      ],
    );
  }

  Widget _buildQuickBadges(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    return Obx(() {
      final cw = controller.currentWeather.value;
      if (cw == null) return const SizedBox.shrink();

      final badges = <_QuickBadgeData>[
        _QuickBadgeData(
          icon: Icons.air_rounded,
          value: cw.windSpeed.toStringAsFixed(1),
          unit: 'km/h',
          label: cw.windDirectionText,
          color: AppThemeData.neonTeal,
        ),
        _QuickBadgeData(
          icon: Icons.water_drop_outlined,
          value: '${cw.humidity.toInt()}',
          unit: '%',
          label: cw.humidity > 70 ? 'High' : 'Normal',
          color: AppThemeData.neonBlue,
        ),
        _QuickBadgeData(
          icon: Icons.wb_sunny_outlined,
          value: cw.uvIndex.toStringAsFixed(0),
          unit: '',
          label: cw.uvLabel,
          color: _uvBadgeColor(cw.uvIndex),
        ),
        _QuickBadgeData(
          icon: Icons.thermostat_outlined,
          value: cw.pressure.toStringAsFixed(0),
          unit: 'hPa',
          label: 'Pressure',
          color: AppThemeData.success300,
        ),
      ];

      if (isDesktop) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: badges
              .map((b) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: _buildQuickBadge(b),
                  ))
              .toList(),
        );
      }

      return Wrap(
        spacing: 8,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: badges.map((b) => _buildQuickBadge(b)).toList(),
      );
    });
  }

  Widget _buildQuickBadge(_QuickBadgeData badge) {
    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      borderRadius: 12,
      glowColor: badge.color.withValues(alpha: 0.3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badge.icon, color: badge.color.withValues(alpha: 0.8), size: 14),
          spaceW(width: 6),
          Text.rich(
            TextSpan(children: [
              TextSpan(
                text: badge.value,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primaryWhite,
                ),
              ),
              if (badge.unit.isNotEmpty)
                TextSpan(
                  text: badge.unit,
                  style: TextStyle(
                    fontSize: 11,
                    fontFamily: FontFamily.regular,
                    color: AppThemeData.grey5,
                  ),
                ),
            ]),
          ),
          spaceW(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              color: badge.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: TextCustom(
              title: badge.label,
              fontSize: 9,
              fontFamily: FontFamily.semiBold,
              color: badge.color.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Color _uvBadgeColor(double uv) {
    if (uv <= 2) return AppThemeData.success300;
    if (uv <= 5) return AppThemeData.pending300;
    if (uv <= 7) return AppThemeData.secondary3;
    if (uv <= 10) return AppThemeData.danger300;
    return AppThemeData.neonLavender;
  }

  Widget _buildHourlySection() {
    return Obx(() {
      if (controller.hourlyForecast.isEmpty) return const SizedBox.shrink();
      return WeatherHourlyChart(
        hourly: controller.hourlyForecast,
        formatTemp: controller.formatTemp,
        isRainCode: CurrentWeather.isRainCode,
        isNight: controller.isNight,
      );
    });
  }

  Widget _buildForecastSection() {
    return Obx(() {
      if (controller.forecast.isEmpty) return const SizedBox.shrink();
      return WeatherForecastRow(
        forecast: controller.forecast,
        tempString: controller.tempString,
        weatherIcon: weatherCodeToIcon,
      );
    });
  }

  Widget _buildDetailCardsSection() {
    return Obx(() {
      return WeatherDetailCards(
        current: controller.currentWeather.value,
        sunrise: controller.sunrise.value,
        sunset: controller.sunset.value,
        forecast: controller.forecast,
      );
    });
  }

  Widget _buildFooter(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;
    final wt = Theme.of(context).extension<WeatherThemeExtension>();

    return Obx(() {
      return PremiumGlassCard(
        padding: EdgeInsets.symmetric(
          horizontal: isDesktop ? 20 : 14,
          vertical: 12,
        ),
        borderRadius: 14,
        child: isDesktop
            ? Row(
                children: [
                  Icon(Icons.public_rounded,
                      color: wt?.textMuted ?? AppThemeData.grey6, size: 14),
                  spaceW(width: 6),
                  TextCustom(
                    title: 'Open-Meteo',
                    fontSize: 12,
                    fontFamily: FontFamily.medium,
                    color: wt?.textMuted ?? AppThemeData.grey6,
                  ),
                  const Spacer(),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: controller.hasError.value
                          ? (wt?.statusError ?? AppThemeData.neonRed)
                          : (wt?.statusOk ?? AppThemeData.success300),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: (controller.hasError.value
                                  ? (wt?.statusError ?? AppThemeData.neonRed)
                                  : (wt?.statusOk ?? AppThemeData.success300))
                              .withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  spaceW(width: 8),
                  TextCustom(
                    title: 'Updated ${controller.lastUpdatedText}',
                    fontSize: 12,
                    fontFamily: FontFamily.medium,
                    color: wt?.textMuted ?? AppThemeData.grey6,
                  ),
                  spaceW(width: 12),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () => controller.fetchAll(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: wt?.glassBorder ?? AppThemeData.surfaceBorder,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.refresh_rounded,
                            color: wt?.textMuted ?? AppThemeData.grey5,
                            size: 14),
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: controller.hasError.value
                              ? (wt?.statusError ?? AppThemeData.neonRed)
                              : (wt?.statusOk ?? AppThemeData.success300),
                          shape: BoxShape.circle,
                        ),
                      ),
                      spaceW(width: 6),
                      TextCustom(
                        title: 'Updated ${controller.lastUpdatedText}',
                        fontSize: 11,
                        color: wt?.textMuted ?? AppThemeData.grey6,
                      ),
                    ],
                  ),
                  spaceH(height: 4),
                  TextCustom(
                    title: 'Source: Open-Meteo.com',
                    fontSize: 10,
                    color: wt?.textMuted ?? AppThemeData.grey7,
                  ),
                ],
              ),
      );
    });
  }

  void _showCityPicker(BuildContext context) {
    final searchController = TextEditingController();
    final results = <CitySearchResult>[].obs;
    final isSearching = false.obs;
    Timer? debounce;

    final screenW = MediaQuery.of(context).size.width;
    final isDesktop = screenW >= 900;

    if (isDesktop) {
      showDialog(
        context: context,
        builder: (ctx) => _CityPickerDialog(
          searchController: searchController,
          results: results,
          isSearching: isSearching,
          onSelected: (city) {
            controller.latitude.value = city.latitude;
            controller.longitude.value = city.longitude;
            controller.cityName.value = city.displayName;
            Navigator.pop(ctx);
            controller.fetchAll();
          },
          onSearch: (query) {
            debounce?.cancel();
            if (query.trim().length < 2) {
              results.clear();
              return;
            }
            isSearching.value = true;
            debounce = Timer(const Duration(milliseconds: 400), () async {
              try {
                final r = await WeatherApi.searchCity(query);
                results.value = r;
              } catch (_) {}
              isSearching.value = false;
            });
          },
        ),
      ).then((_) {
        debounce?.cancel();
        searchController.dispose();
      });
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => _CityPickerBottomSheet(
          searchController: searchController,
          results: results,
          isSearching: isSearching,
          onSelected: (city) {
            controller.latitude.value = city.latitude;
            controller.longitude.value = city.longitude;
            controller.cityName.value = city.displayName;
            Navigator.pop(ctx);
            controller.fetchAll();
          },
          onSearch: (query) {
            debounce?.cancel();
            if (query.trim().length < 2) {
              results.clear();
              return;
            }
            isSearching.value = true;
            debounce = Timer(const Duration(milliseconds: 400), () async {
              try {
                final r = await WeatherApi.searchCity(query);
                results.value = r;
              } catch (_) {}
              isSearching.value = false;
            });
          },
        ),
      ).then((_) {
        debounce?.cancel();
        searchController.dispose();
      });
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
//  ANIMATED BACKGROUND WRAPPER
// ══════════════════════════════════════════════════════════════════════

class _WeatherBackgroundWrapper extends StatelessWidget {
  final String condition;
  final bool isNight;
  final Widget? child;

  const _WeatherBackgroundWrapper({
    required this.condition,
    required this.isNight,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final condWt = wt?.withCondition(condition: condition, isNight: isNight);
    final hour = DateTime.now().hour;
    final minute = DateTime.now().minute;
    final timeOfDay = hour + minute / 60.0;

    final colors = condWt?.backgroundGradient ?? WeatherBackground.getGradient(
      condition: condition,
      isNight: isNight,
      timeOfDay: timeOfDay,
    );

    final glowColor = condWt?.conditionGlow ?? WeatherBackground.getConditionGlow(condition, isNight);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        children: [
          // ignore: use_null_aware_elements
          if (child != null) child!,
          Positioned(
            top: -100,
            right: -60,
            child: Container(
              width: 350,
              height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    glowColor,
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Image.asset(
                'assets/images/noise_texture.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.02),
                repeat: ImageRepeat.repeat,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  ANIMATED TEMPERATURE
// ══════════════════════════════════════════════════════════════════════

class _AnimatedTemperature extends StatelessWidget {
  final double temp;
  final String Function(double) formatTemp;
  final double fontSize;

  const _AnimatedTemperature({
    required this.temp,
    required this.formatTemp,
    this.fontSize = 120,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    final target = temp.round();
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '$value°',
          style: TextStyle(
            fontSize: fontSize,
            fontFamily: FontFamily.light,
            color: wt?.textPrimary ?? AppThemeData.primaryWhite,
            height: 1.0,
            letterSpacing: fontSize > 100 ? -5 : -3,
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  QUICK BADGE DATA
// ══════════════════════════════════════════════════════════════════════

class _QuickBadgeData {
  final IconData icon;
  final String value;
  final String unit;
  final String label;
  final Color color;

  const _QuickBadgeData({
    required this.icon,
    required this.value,
    required this.unit,
    required this.label,
    required this.color,
  });
}

// ══════════════════════════════════════════════════════════════════════
//  CITY PICKER — Desktop Dialog
// ══════════════════════════════════════════════════════════════════════

class _CityPickerDialog extends StatelessWidget {
  final TextEditingController searchController;
  final RxList<CitySearchResult> results;
  final RxBool isSearching;
  final Function(CitySearchResult) onSelected;
  final Function(String) onSearch;

  const _CityPickerDialog({
    required this.searchController,
    required this.results,
    required this.isSearching,
    required this.onSelected,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
          child: Container(
            width: 480,
            height: 500,
            decoration: BoxDecoration(
              color: (wt?.scaffoldBg ?? AppThemeData.surfaceMid).withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: wt?.inputBorder ?? AppThemeData.surfaceBorder,
              ),
            ),
            child: _buildContent(context),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Row(
            children: [
              Icon(Icons.search_rounded,
                  color: wt?.textMuted ?? AppThemeData.grey5, size: 20),
              spaceW(width: 8),
              Expanded(
                child: TextField(
                  controller: searchController,
                  autofocus: true,
                  style: TextStyle(
                    color: wt?.textPrimary ?? AppThemeData.primaryWhite,
                    fontFamily: FontFamily.regular,
                    fontSize: 16,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search city...',
                    hintStyle: TextStyle(
                        color: wt?.inputHint ?? AppThemeData.grey6),
                    border: InputBorder.none,
                  ),
                  onChanged: onSearch,
                ),
              ),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close_rounded,
                      color: wt?.textMuted ?? AppThemeData.grey6, size: 18),
                ),
              ),
            ],
          ),
        ),
        Divider(
            color: wt?.divider ?? AppThemeData.surfaceBorder, height: 1),
        Expanded(
          child: Obx(() {
            if (isSearching.value) {
              return Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: wt?.textMuted ?? AppThemeData.grey6,
                ),
              );
            }
            if (results.isEmpty && searchController.text.length >= 2) {
              return Center(
                child: TextCustom(
                  title: 'No cities found',
                  fontSize: 14,
                  color: wt?.textMuted ?? AppThemeData.grey6,
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: results.length,
              itemBuilder: (ctx, i) {
                final city = results[i];
                return MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => onSelected(city),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      child: Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              color: wt?.textMuted ?? AppThemeData.grey6,
                              size: 16),
                          spaceW(width: 10),
                          Expanded(
                            child: TextCustom(
                              title: city.displayName,
                              fontSize: 14,
                              fontFamily: FontFamily.regular,
                              color: wt?.textSecondary ?? AppThemeData.grey4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          }),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
//  CITY PICKER — Mobile Bottom Sheet
// ══════════════════════════════════════════════════════════════════════

class _CityPickerBottomSheet extends StatelessWidget {
  final TextEditingController searchController;
  final RxList<CitySearchResult> results;
  final RxBool isSearching;
  final Function(CitySearchResult) onSelected;
  final Function(String) onSearch;

  const _CityPickerBottomSheet({
    required this.searchController,
    required this.results,
    required this.isSearching,
    required this.onSelected,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final wt = Theme.of(context).extension<WeatherThemeExtension>();
    return Obx(() => ClipRRect(
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(24)),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 30, sigmaY: 30),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6,
              decoration: BoxDecoration(
                color: (wt?.scaffoldBg ?? AppThemeData.surfaceMid).withValues(alpha: 0.92),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: wt?.textMuted ?? AppThemeData.grey7,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: searchController,
                      autofocus: true,
                      style: TextStyle(
                        color: wt?.textPrimary ?? AppThemeData.primaryWhite,
                        fontFamily: FontFamily.regular,
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search city...',
                        hintStyle: TextStyle(
                            color: wt?.inputHint ?? AppThemeData.grey6),
                        prefixIcon: Icon(Icons.search_rounded,
                            color: wt?.textMuted ?? AppThemeData.grey5),
                        filled: true,
                        fillColor:
                            wt?.inputBackground ?? AppThemeData.surfaceBorder,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide(
                              color: wt?.inputBorder ?? AppThemeData.surfaceHighlight),
                        ),
                      ),
                      onChanged: onSearch,
                    ),
                  ),
                  if (isSearching.value)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: wt?.textMuted ?? AppThemeData.grey6,
                      ),
                    )
                  else if (results.isEmpty &&
                      searchController.text.length >= 2)
                    Padding(
                      padding: const EdgeInsets.all(40),
                      child: TextCustom(
                        title: 'No cities found',
                        fontSize: 14,
                        color: wt?.textMuted ?? AppThemeData.grey6,
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: results.length,
                        itemBuilder: (ctx, i) {
                          final city = results[i];
                          return GestureDetector(
                            onTap: () => onSelected(city),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 13),
                              margin: const EdgeInsets.only(bottom: 6),
                              decoration: BoxDecoration(
                                color: wt?.glassBackground ??
                                    AppThemeData.surfaceElevated,
                                borderRadius:
                                    BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                      Icons.location_on_outlined,
                                      color: wt?.textMuted ??
                                          AppThemeData.grey5,
                                      size: 18),
                                  spaceW(width: 10),
                                  Expanded(
                                    child: TextCustom(
                                      title: city.displayName,
                                      fontSize: 14,
                                      fontFamily:
                                          FontFamily.regular,
                                      color: wt?.textSecondary ??
                                          AppThemeData.grey4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ));
  }
}
