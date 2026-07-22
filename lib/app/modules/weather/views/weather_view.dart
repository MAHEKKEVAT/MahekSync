import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maheksync/app/models/weather_model.dart';
import 'package:maheksync/app/services/weather_api.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart' hide AnimatedBuilder;
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/weather_particles.dart';
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
        if (controller.isLoading.value && controller.currentWeather.value == null) {
          return _buildLoading();
        }
        return _buildBody(context);
      }),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  LOADING / ERROR
  // ════════════════════════════════════════════════════════════════

  Widget _buildLoading() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemeData.surfaceVoid, AppThemeData.surfaceDeep, AppThemeData.surfaceMid],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: const Center(
        child: MahekLoader(message: 'Loading weather...', size: 50, textSize: 16),
      ),
    );
  }

  Widget _buildError() {
    return Container(
      decoration: _backgroundGradient(),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppThemeData.primaryWhite.withValues(alpha: 0.3), size: 72),
            const SizedBox(height: 20),
            TextCustom(
              title: 'Unable to load weather',
              fontSize: 20,
              fontFamily: FontFamily.medium,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.8),
            ),
            const SizedBox(height: 8),
            TextCustom(
              title: 'Please check your connection and try again.',
              fontSize: 14,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.45),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () => controller.fetchAll(),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppThemeData.appleIntelligenceGradientCool,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: AppThemeData.neonGlow(AppThemeData.primary50, opacity: 0.3, blur: 24),
                ),
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

  // ════════════════════════════════════════════════════════════════
  //  MAIN BODY
  // ════════════════════════════════════════════════════════════════

  Widget _buildBody(BuildContext context) {
    if (controller.hasError.value && controller.currentWeather.value == null) {
      return _buildError();
    }
    final isMobile = MediaQuery.of(context).size.width < 900;
    return Stack(
      children: [
        Container(
          decoration: _backgroundGradient(),
          child: SafeArea(
            child: isMobile ? _buildMobileLayout(context) : _buildDesktopLayout(context),
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

  // ════════════════════════════════════════════════════════════════
  //  BACKGROUND GRADIENT
  // ════════════════════════════════════════════════════════════════

  BoxDecoration _backgroundGradient() {
    final isNightTime = controller.isNight;
    final hour = DateTime.now().hour;
    final isEvening = hour >= 17 && hour < 20;
    final isAfternoon = hour >= 12 && hour < 17;
    final condition = controller.weatherCondition;

    List<Color> colors;

    if (condition == 'rainy' || condition == 'stormy') {
      if (isNightTime) {
        colors = const [AppThemeData.surfaceVoid, Color(0xFF0E1525), AppThemeData.neonBlueDim];
      } else {
        colors = const [AppThemeData.surfaceDeep, Color(0xFF142230), AppThemeData.neonTealDim];
      }
    } else if (condition == 'snowy') {
      colors = const [Color(0xFF0F1B2A), Color(0xFF1A2D40), AppThemeData.neonTealDim];
    } else if (condition == 'foggy') {
      colors = const [AppThemeData.surfaceObsidian, AppThemeData.surfaceDark, AppThemeData.surfaceMid];
    } else if (condition == 'cloudy') {
      if (isNightTime) {
        colors = const [AppThemeData.surfaceVoid, AppThemeData.neonBlueDim, Color(0xFF0E1A30)];
      } else {
        colors = const [AppThemeData.surfaceDeep, Color(0xFF0E1E35), AppThemeData.neonBlueDim];
      }
    } else {
      if (isNightTime) {
        colors = const [AppThemeData.surfaceVoid, Color(0xFF0C0E28), AppThemeData.neonBlueDim];
      } else if (isEvening) {
        colors = const [AppThemeData.neonPinkDim, AppThemeData.neonPurpleDim, AppThemeData.neonBlueDim];
      } else if (isAfternoon) {
        colors = const [AppThemeData.neonBlueDim, Color(0xFF0E1E38), AppThemeData.neonTealDim];
      } else {
        colors = const [AppThemeData.surfaceDeep, AppThemeData.neonBlueDim, AppThemeData.neonTealDim];
      }
    }

    return BoxDecoration(
      gradient: LinearGradient(colors: colors, begin: Alignment.topCenter, end: Alignment.bottomCenter),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  DESKTOP LAYOUT — Two-column
  // ════════════════════════════════════════════════════════════════

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        _buildTopBar(context),
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 6, child: _buildLeftScrollable()),
              const SizedBox(width: 24),
              SizedBox(width: 400, child: _buildRightPanel(context)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLeftScrollable() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      child: Column(
        children: [
          _buildHeroSection(),
          const SizedBox(height: 48),
          _buildInlineStats(),
          const SizedBox(height: 40),
          _buildHourlyChartSection(),
          const SizedBox(height: 40),
          _buildForecastSection(),
          const SizedBox(height: 40),
          _buildDetailCardsSection(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  MOBILE LAYOUT — Single column
  // ════════════════════════════════════════════════════════════════

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          _buildTopBar(context),
          _buildHeroSection(),
          const SizedBox(height: 40),
          _buildInlineStats(),
          const SizedBox(height: 32),
          _buildHourlyChartSection(),
          const SizedBox(height: 32),
          _buildForecastSection(),
          const SizedBox(height: 32),
          _buildDetailCardsSection(),
          const SizedBox(height: 32),
          _buildMapSection(),
          _buildFooter(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  RIGHT PANEL (Desktop)
  // ════════════════════════════════════════════════════════════════

  Widget _buildRightPanel(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(0, 8, 28, 40),
      child: Column(
        children: [
          _buildMapSection(),
          const SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TOP BAR — Floating glass pill
  // ════════════════════════════════════════════════════════════════

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 12, 28, 8),
      child: Row(
        children: [
          _buildCityButton(context),
          const Spacer(),
          _buildUnitToggle(),
          const SizedBox(width: 8),
          _glassCircleButton(
            icon: Icons.refresh_rounded,
            onTap: () => controller.fetchAll(),
          ),
        ],
      ),
    );
  }

  Widget _buildCityButton(BuildContext context) {
    return Obx(() => GestureDetector(
      onTap: () => _showSearchOverlay(context),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppThemeData.surfaceDeep.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.08)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.location_on_rounded, color: AppThemeData.primary50, size: 16),
                const SizedBox(width: 6),
                TextCustom(
                  title: controller.cityName.value,
                  fontSize: 14,
                  fontFamily: FontFamily.semiBold,
                  color: AppThemeData.primaryWhite.withValues(alpha: 0.9),
                ),
                const SizedBox(width: 4),
                Icon(Icons.keyboard_arrow_down_rounded, color: AppThemeData.primaryWhite.withValues(alpha: 0.4), size: 16),
              ],
            ),
          ),
        ),
      ),
    ));
  }

  Widget _buildUnitToggle() {
    return Obx(() {
      return Container(
        height: 40,
        decoration: BoxDecoration(
          color: AppThemeData.surfaceElevated,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppThemeData.surfaceBorder),
        ),
        child: Row(
          children: [
            _unitButton('°C', controller.isCelsius.value),
            _unitButton('°F', !controller.isCelsius.value),
          ],
        ),
      );
    });
  }

  Widget _unitButton(String label, bool isActive) {
    return GestureDetector(
      onTap: () {
        if ((label == '°C') != controller.isCelsius.value) controller.toggleUnit();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: isActive ? AppThemeData.appleIntelligenceGradientCool : null,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Center(
          child: TextCustom(
            title: label,
            fontSize: 13,
            fontFamily: FontFamily.bold,
            color: isActive ? AppThemeData.primaryWhite : AppThemeData.primaryWhite.withValues(alpha: 0.4),
          ),
        ),
      ),
    );
  }

  Widget _glassCircleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppThemeData.surfaceElevated,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppThemeData.surfaceBorder),
            ),
            child: Icon(icon, color: AppThemeData.primaryWhite.withValues(alpha: 0.7), size: 18),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  CITY SEARCH OVERLAY
  // ════════════════════════════════════════════════════════════════

  void _showSearchOverlay(BuildContext context) {
    final searchController = TextEditingController();
    final results = <CitySearchResult>[].obs;
    final isSearching = false.obs;
    Timer? debounce;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Obx(() => ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: MediaQuery.of(ctx).size.height * 0.6,
            decoration: BoxDecoration(
              color: AppThemeData.surfaceDeep.withValues(alpha: 0.85),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.08)),
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12),
                  decoration: BoxDecoration(
                    color: AppThemeData.primaryWhite.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: TextField(
                    controller: searchController,
                    autofocus: true,
                    style: TextStyle(
                      color: AppThemeData.primaryWhite,
                      fontFamily: FontFamily.regular,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search city...',
                      hintStyle: TextStyle(color: AppThemeData.primaryWhite.withValues(alpha: 0.3)),
                      prefixIcon: Icon(Icons.search_rounded, color: AppThemeData.primaryWhite.withValues(alpha: 0.4)),
                      filled: true,
                      fillColor: AppThemeData.surfaceElevated,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: AppThemeData.primary50.withValues(alpha: 0.4)),
                      ),
                    ),
                    onChanged: (query) {
                      debounce?.cancel();
                      if (query.trim().length < 2) {
                        results.clear();
                        return;
                      }
                      isSearching.value = true;
                      debounce = Timer(const Duration(milliseconds: 500), () async {
                        try {
                          final r = await WeatherApi.searchCity(query);
                          results.value = r;
                        } catch (_) {}
                        isSearching.value = false;
                      });
                    },
                  ),
                ),
                if (isSearching.value)
                  const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (results.isEmpty && searchController.text.length >= 2)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: TextCustom(
                      title: 'No cities found',
                      fontSize: 14,
                      color: AppThemeData.primaryWhite.withValues(alpha: 0.4),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: results.length,
                      itemBuilder: (ctx, i) {
                        final city = results[i];
                        return GestureDetector(
                          onTap: () {
                            controller.latitude.value = city.latitude;
                            controller.longitude.value = city.longitude;
                            controller.cityName.value = city.displayName;
                            Navigator.pop(ctx);
                            controller.fetchAll();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: AppThemeData.surfaceElevated.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.location_on_outlined, color: AppThemeData.primary50, size: 18),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextCustom(
                                    title: city.displayName,
                                    fontSize: 14,
                                    fontFamily: FontFamily.regular,
                                    color: AppThemeData.primaryWhite.withValues(alpha: 0.85),
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
      )),
    ).then((_) {
      debounce?.cancel();
      searchController.dispose();
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  HERO SECTION — Cinematic, centered
  // ════════════════════════════════════════════════════════════════

  Widget _buildHeroSection() {
    return Obx(() {
      final cw = controller.currentWeather.value;
      if (cw == null) return const SizedBox.shrink();

      final glowColor = CurrentWeather.isRainCode(cw.weatherCode)
          ? AppThemeData.neonBlue
          : CurrentWeather.isSnowCode(cw.weatherCode)
              ? AppThemeData.neonLavender
              : controller.isNight
                  ? AppThemeData.neonPurple
                  : AppThemeData.neonTeal;

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: AppThemeData.neonGlow(glowColor, blur: 48, spread: -10, opacity: 0.18),
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  child: Icon(
                    _weatherIcon(cw.weatherCode),
                    key: ValueKey(cw.weatherCode),
                    color: AppThemeData.primaryWhite,
                    size: 100,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _AnimatedTemperature(
              temp: cw.temperature,
              formatTemp: controller.formatTemp,
            ),
            const SizedBox(height: 8),
            TextCustom(
              title: '°',
              fontSize: 40,
              fontFamily: FontFamily.light,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.35),
            ),
            const SizedBox(height: 8),
            TextCustom(
              title: cw.conditionText,
              fontSize: 22,
              fontFamily: FontFamily.medium,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.9),
            ),
            const SizedBox(height: 12),
            _buildHighLowRow(),
            const SizedBox(height: 8),
            TextCustom(
              title: controller.feelsLikeString,
              fontSize: 14,
              fontFamily: FontFamily.regular,
              color: AppThemeData.primaryWhite.withValues(alpha: 0.5),
            ),
          ],
        ),
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
          title: 'H: ${controller.tempString(today.maxTemp)}',
          fontSize: 15,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.primaryWhite.withValues(alpha: 0.8),
        ),
        const SizedBox(width: 20),
        TextCustom(
          title: 'L: ${controller.tempString(today.minTemp)}',
          fontSize: 15,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.primaryWhite.withValues(alpha: 0.45),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  INLINE STATS — No cards, just text+icon row
  // ════════════════════════════════════════════════════════════════

  Widget _buildInlineStats() {
    return Obx(() {
      final cw = controller.currentWeather.value;
      if (cw == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _inlineStat(Icons.air, 'Wind', '${cw.windSpeed.toStringAsFixed(0)} km/h'),
            _inlineStat(Icons.water_drop_outlined, 'Humidity', '${cw.humidity.toInt()}%'),
            _inlineStat(Icons.wb_sunny_outlined, 'UV', cw.uvIndex.toStringAsFixed(0)),
            _inlineStat(Icons.visibility_outlined, 'Vis', cw.visibilityText),
          ],
        ),
      );
    });
  }

  Widget _inlineStat(IconData icon, String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppThemeData.primaryWhite.withValues(alpha: 0.5), size: 18),
        const SizedBox(height: 6),
        TextCustom(
          title: value,
          fontSize: 14,
          fontFamily: FontFamily.semiBold,
          color: AppThemeData.primaryWhite,
        ),
        const SizedBox(height: 2),
        TextCustom(
          title: label,
          fontSize: 11,
          color: AppThemeData.primaryWhite.withValues(alpha: 0.4),
        ),
      ],
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  HOURLY CHART
  // ════════════════════════════════════════════════════════════════

  Widget _buildHourlyChartSection() {
    return Obx(() {
      if (controller.hourlyForecast.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: _GlassContainer(
          child: WeatherHourlyChart(
            hourly: controller.hourlyForecast,
            formatTemp: controller.formatTemp,
            isRainCode: CurrentWeather.isRainCode,
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  7-DAY FORECAST
  // ════════════════════════════════════════════════════════════════

  Widget _buildForecastSection() {
    return Obx(() {
      if (controller.forecast.isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: _GlassContainer(
          child: WeatherForecastRow(
            forecast: controller.forecast,
            tempString: controller.tempString,
            weatherIcon: _weatherIcon,
          ),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  DETAIL CARDS BENTO
  // ════════════════════════════════════════════════════════════════

  Widget _buildDetailCardsSection() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: WeatherDetailCards(
          current: controller.currentWeather.value,
          sunrise: controller.sunrise.value,
          sunset: controller.sunset.value,
          forecast: controller.forecast,
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  LIVE MAP
  // ════════════════════════════════════════════════════════════════

  Widget _buildMapSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppThemeData.surfaceDeep.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.07)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppThemeData.neonBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.map_rounded, color: AppThemeData.neonBlue, size: 14),
                      ),
                      const SizedBox(width: 8),
                      TextCustom(
                        title: 'Weather Map',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: AppThemeData.primaryWhite,
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: SizedBox(
                    height: 280,
                    child: Obx(() => GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: LatLng(controller.latitude.value, controller.longitude.value),
                        zoom: 8,
                      ),
                      mapType: MapType.terrain,
                      zoomControlsEnabled: false,
                      scrollGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      markers: {
                        Marker(
                          markerId: const MarkerId('current'),
                          position: LatLng(controller.latitude.value, controller.longitude.value),
                        ),
                      },
                    )),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  FOOTER
  // ════════════════════════════════════════════════════════════════

  Widget _buildFooter() {
    return Obx(() {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 20),
        child: TextCustom(
          title: 'Source: Open-Meteo.com · Updated: ${controller.lastUpdatedText}',
          fontSize: 12,
          color: AppThemeData.primaryWhite.withValues(alpha: 0.3),
        ),
      );
    });
  }

  // ════════════════════════════════════════════════════════════════
  //  SHARED
  // ════════════════════════════════════════════════════════════════

  IconData _weatherIcon(int code) {
    if (code == 0) return Icons.wb_sunny_rounded;
    if (code <= 3) return Icons.cloud_queue_rounded;
    if (code <= 48) return Icons.cloud;
    if (code <= 57) return Icons.grain;
    if (code <= 67) return Icons.umbrella;
    if (code <= 77) return Icons.ac_unit;
    if (code <= 82) return Icons.umbrella;
    if (code <= 86) return Icons.ac_unit;
    if (code <= 99) return Icons.flash_on;
    return Icons.cloud;
  }
}

// ════════════════════════════════════════════════════════════════
//  GLASS CONTAINER — Reusable frosted wrapper
// ════════════════════════════════════════════════════════════════

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppThemeData.surfaceDeep.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppThemeData.primaryWhite.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: AppThemeData.surfaceVoid.withValues(alpha: 0.5),
                blurRadius: 40,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: const BoxDecoration(gradient: AppThemeData.glassShimmerDark),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
//  ANIMATED TEMPERATURE — Counting animation
// ════════════════════════════════════════════════════════════════

class _AnimatedTemperature extends StatelessWidget {
  final double temp;
  final String Function(double) formatTemp;

  const _AnimatedTemperature({required this.temp, required this.formatTemp});

  @override
  Widget build(BuildContext context) {
    final target = temp.round();
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: 0, end: target),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return Text(
          '$value',
          style: TextStyle(
            fontSize: 120,
            fontFamily: FontFamily.bold,
            color: AppThemeData.primaryWhite,
            height: 0.85,
            letterSpacing: -5,
          ),
        );
      },
    );
  }
}
