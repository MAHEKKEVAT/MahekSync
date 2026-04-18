// ignore_for_file: deprecated_member_use

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class DashboardHomeView extends StatefulWidget {
  const DashboardHomeView({super.key});

  @override
  State<DashboardHomeView> createState() => _DashboardHomeViewState();
}

class _DashboardHomeViewState extends State<DashboardHomeView> {
  Map<String, dynamic> stats = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }

  Future<void> _loadDashboard() async {
    setState(() {
      isLoading = true;
    });

    // Simulate loading delay - replace with actual data fetching
    await Future.delayed(const Duration(milliseconds: 800));

    // Set default/placeholder stats
    setState(() {
      stats = {
        'totalAds': 156,
        'activeAds': 142,
        'pendingAds': 8,
        'totalCustomers': 1243,
        'totalCategories': 12,
        'activeBanners': 4,
      };
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final isDesktop = ResponsiveWidget.isDesktop(context);

    if (isLoading) {
      return Center(
        child: MahekLoader(
          message: 'Loading Dashboard...'.tr,
          size: 50,
          textSize: 16,
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isDesktop ? 20 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome banner
            _buildWelcomeBanner(isDark, isDesktop),
            spaceH(height: 20),

            // Stat cards
            _buildStatCards(isDark, isDesktop),
            spaceH(height: 24),

            // Quick actions section
            _buildQuickActions(isDark, isDesktop),
            spaceH(height: 24),

            // Recent activity placeholder
            _buildRecentActivity(isDark),
          ],
        ),
      ),
    );
  }

  // ── WELCOME BANNER ─────────────────────────────────────────────────
  Widget _buildWelcomeBanner(bool isDark, bool isDesktop) {
    final name = MahekConstant.ownerModel?.fullName ?? 'Admin';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isDesktop ? 24 : 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppThemeData.primary50, const Color(0xff1E40AF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.06),
              ),
            ),
          ),
          Positioned(
            right: 40,
            bottom: -30,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(
                title: 'Welcome back, $name! 👋',
                fontSize: isDesktop ? 22 : 18,
                fontFamily: FontFamily.bold,
                color: Colors.white,
              ),
              spaceH(height: 6),
              TextCustom(
                title: 'Here\'s what\'s happening with your marketplace today.',
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── STAT CARDS ─────────────────────────────────────────────────────
  Widget _buildStatCards(bool isDark, bool isDesktop) {
    final cards = [
      _StatItem('Total Ads'.tr, '${stats['totalAds'] ?? 0}', 'assets/icons/ic_ads.svg', [
        const Color(0xff3068FF),
        const Color(0xff1E40AF)
      ]),
      _StatItem('Active Ads'.tr, '${stats['activeAds'] ?? 0}', 'assets/icons/ic_feature_sections.svg', [
        const Color(0xff00C750),
        const Color(0xff008E38)
      ]),
      _StatItem('Pending'.tr, '${stats['pendingAds'] ?? 0}', 'assets/icons/ic_ad_reports.svg', [
        const Color(0xffFDC700),
        const Color(0xffB28C00)
      ]),
      _StatItem('Customers'.tr, '${stats['totalCustomers'] ?? 0}', 'assets/icons/ic_customers.svg', [
        const Color(0xffA855F7),
        const Color(0xff7E22CE)
      ]),
      _StatItem('Categories'.tr, '${stats['totalCategories'] ?? 0}', 'assets/icons/ic_categories.svg', [
        const Color(0xffF86C16),
        const Color(0xffAD4C0F)
      ]),
      _StatItem('Banners'.tr, '${stats['activeBanners'] ?? 0}', 'assets/icons/ic_banners.svg', [
        const Color(0xff3068FF),
        const Color(0xff102766)
      ]),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        int cols = constraints.maxWidth > 1000
            ? 6
            : constraints.maxWidth > 600
            ? 3
            : 2;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: cols >= 6 ? 1.5 : 1.7,
          ),
          itemCount: cards.length,
          itemBuilder: (_, i) => _buildStatCard(cards[i], isDark),
        );
      },
    );
  }

  Widget _buildStatCard(_StatItem data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: data.gradient.first.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: SvgPicture.asset(
              data.svgIcon,
              width: 20,
              height: 20,
              colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                child: TextCustom(
                  title: data.value,
                  fontSize: 26,
                  fontFamily: FontFamily.bold,
                  color: Colors.white,
                ),
              ),
              TextCustom(
                title: data.title,
                fontSize: 12,
                color: Colors.white.withOpacity(0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTIONS ──────────────────────────────────────────────────
  Widget _buildQuickActions(bool isDark, bool isDesktop) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextCustom(
            title: 'Quick Actions',
            fontSize: 16,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          spaceH(height: 16),
          Row(
            children: [
              _buildActionButton(
                icon: Icons.add_circle_outline,
                label: 'Add Device',
                color: AppThemeData.primary50,
                onTap: () => Get.toNamed('/add-new-devices'),
              ),
              spaceW(width: 12),
              _buildActionButton(
                icon: Icons.category_outlined,
                label: 'Add Category',
                color: AppThemeData.success400,
                onTap: () {
                  // Navigate to add category
                },
              ),
              spaceW(width: 12),
              _buildActionButton(
                icon: Icons.people_outline,
                label: 'Add Customer',
                color: AppThemeData.pending400,
                onTap: () {
                  // Navigate to add customer
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                spaceH(height: 8),
                TextCustom(
                  title: label,
                  fontSize: 13,
                  fontFamily: FontFamily.medium,
                  color: color,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── RECENT ACTIVITY ────────────────────────────────────────────────
  Widget _buildRecentActivity(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextCustom(
                title: 'Recent Activity',
                fontSize: 16,
                fontFamily: FontFamily.bold,
                color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              ),
              TextCustom(
                title: 'View All',
                fontSize: 13,
                fontFamily: FontFamily.medium,
                color: AppThemeData.primary50,
              ),
            ],
          ),
          spaceH(height: 20),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 30),
              child: Column(
                children: [
                  Icon(
                    Icons.history_toggle_off_outlined,
                    size: 48,
                    color: isDark ? AppThemeData.grey7 : AppThemeData.grey4,
                  ),
                  spaceH(height: 12),
                  TextCustom(
                    title: 'No recent activity',
                    fontSize: 14,
                    fontFamily: FontFamily.medium,
                    color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                  ),
                  spaceH(height: 4),
                  TextCustom(
                    title: 'Your recent actions will appear here',
                    fontSize: 12,
                    fontFamily: FontFamily.regular,
                    color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final String title, value, svgIcon;
  final List<Color> gradient;

  _StatItem(this.title, this.value, this.svgIcon, this.gradient);
}
