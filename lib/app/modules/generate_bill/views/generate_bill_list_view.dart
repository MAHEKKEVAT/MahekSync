import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:maheksync/app/modules/generate_bill/controllers/generate_bill_controller.dart';
import 'package:maheksync/app/routes/app_pages.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';

class GenerateBillListView extends StatelessWidget {
  const GenerateBillListView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final controller = Get.find<GenerateBillController>();
    final isMobile = MediaQuery.of(context).size.width < 650;

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.primaryBlack : AppThemeData.grey1,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context, isDark, controller),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(child: MahekLoader());
                }
                if (controller.bills.isEmpty) {
                  return _buildEmptyState(isDark, context, controller);
                }
                return _buildContent(context, isDark, controller, isMobile);
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildGenerateButton(context, isDark, controller),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────
  Widget _buildHeader(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppThemeData.surfaceDark, AppThemeData.surfaceMid]
              : [AppThemeData.primary1, AppThemeData.primaryWhite],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeData.neonBlue.withValues(alpha: 0.2),
                  AppThemeData.neonBlue.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppThemeData.neonBlue.withValues(alpha: 0.3),
              ),
            ),
            child: SvgPicture.asset(
              'assets/icons/ic_bill.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                AppThemeData.neonBlue,
                BlendMode.srcIn,
              ),
            ),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: 'Generate Bills',
                  fontSize: 22,
                  fontFamily: FontFamily.bold,
                  color: isDark ? AppThemeData.primaryWhite : AppThemeData.grey10,
                ),
                spaceH(height: 2),
                TextCustom(
                  title: 'Manage and export your invoices',
                  fontSize: 13,
                  fontFamily: FontFamily.regular,
                  color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                ),
              ],
            ),
          ),
          _buildStatsChip(isDark, controller),
        ],
      ),
    );
  }

  Widget _buildStatsChip(bool isDark, GenerateBillController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppThemeData.neonBlue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppThemeData.neonBlue.withValues(alpha: 0.3),
        ),
      ),
      child: Obx(() {
        return Text(
          '${controller.bills.length} bills \u2022 \u20B9${controller.totalAmount.toStringAsFixed(0)}',
          style: TextStyle(
            color: AppThemeData.neonBlue,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        );
      }),
    );
  }

  // ── Stat Cards ──────────────────────────────────────────────────────
  Widget _buildStatCards(bool isDark, bool isMobile, GenerateBillController controller) {
    final stats = [
      _StatData(
        icon: Icons.receipt_long_rounded,
        label: 'Total Bills',
        value: '${controller.bills.length}',
        sub: 'All time',
        color: AppThemeData.neonBlue,
      ),
      _StatData(
        icon: Icons.currency_rupee_rounded,
        label: 'Total Amount',
        value: '\u20B9${controller.totalAmount.toStringAsFixed(0)}',
        sub: 'Revenue',
        color: AppThemeData.neonMint,
      ),
      _StatData(
        icon: Icons.analytics_rounded,
        label: 'Average Bill',
        value: '\u20B9${controller.avgBill.toStringAsFixed(0)}',
        sub: 'Per invoice',
        color: AppThemeData.neonPurple,
      ),
      _StatData(
        icon: Icons.calendar_month_rounded,
        label: 'This Month',
        value: '${controller.thisMonthCount}',
        sub: '\u20B9${controller.thisMonthAmount.toStringAsFixed(0)}',
        color: AppThemeData.neonOrange,
      ),
    ];

    return isMobile
        ? Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[0], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[1], isDark)),
                ],
              ),
              spaceH(height: 12),
              Row(
                children: [
                  Expanded(child: _buildStatCard(stats[2], isDark)),
                  spaceW(width: 12),
                  Expanded(child: _buildStatCard(stats[3], isDark)),
                ],
              ),
            ],
          )
        : Row(
            children: stats
                .map((s) => Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _buildStatCard(s, isDark),
                      ),
                    ))
                .toList(),
          );
  }

  Widget _buildStatCard(_StatData stat, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            stat.color.withValues(alpha: isDark ? 0.2 : 0.12),
            stat.color.withValues(alpha: isDark ? 0.08 : 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: stat.color.withValues(alpha: isDark ? 0.25 : 0.18),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  stat.color.withValues(alpha: 0.9),
                  stat.color,
                ],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: stat.color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(stat.icon, size: 20, color: Colors.white),
          ),
          spaceW(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  stat.label,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 11,
                    color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
                  ),
                ),
                spaceH(height: 3),
                Text(
                  stat.value,
                  style: TextStyle(
                    fontFamily: FontFamily.bold,
                    fontSize: 22,
                    color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                    letterSpacing: -0.5,
                  ),
                ),
                spaceH(height: 2),
                Text(
                  stat.sub,
                  style: TextStyle(
                    fontFamily: FontFamily.medium,
                    fontSize: 10,
                    color: stat.color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Content ─────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, bool isDark,
      GenerateBillController controller, bool isMobile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatCards(isDark, isMobile, controller),
          spaceH(height: 24),
          _buildSectionHeader(isDark, controller),
          spaceH(height: 12),
          _buildBillsList(context, isDark, controller),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(bool isDark, GenerateBillController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextCustom(
          title: 'Recent Bills',
          fontSize: 16,
          fontFamily: FontFamily.bold,
          color: isDark ? AppThemeData.grey2 : AppThemeData.grey10,
        ),
        Obx(() => TextCustom(
          title: '${controller.bills.length} total',
          fontSize: 13,
          fontFamily: FontFamily.medium,
          color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
        )),
      ],
    );
  }

  // ── Empty State ─────────────────────────────────────────────────────
  Widget _buildEmptyState(bool isDark, BuildContext context, GenerateBillController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppThemeData.neonBlue.withValues(alpha: 0.15),
                  AppThemeData.neonBlue.withValues(alpha: 0.05),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppThemeData.neonBlue.withValues(alpha: 0.2),
              ),
            ),
            child: Icon(
              Icons.receipt_long_rounded,
              size: 52,
              color: AppThemeData.neonBlue.withValues(alpha: 0.6),
            ),
          ),
          spaceH(height: 24),
          TextCustom(
            title: 'No bills yet',
            fontSize: 20,
            fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey8,
          ),
          spaceH(height: 8),
          TextCustom(
            title: 'Generate your first invoice to get started',
            fontSize: 14,
            fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
          ),
          spaceH(height: 28),
          GestureDetector(
            onTap: () async {
              controller.resetForm();
              final result = await Get.toNamed(Routes.GENERATE_BILL_CREATE);
              if (result == true) controller.loadBills();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: AppThemeData.neonPurpleBlueGradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: AppThemeData.neonGlow(AppThemeData.primary50, opacity: 0.3),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                  spaceW(width: 8),
                  const Text(
                    'Create First Bill',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: FontFamily.semiBold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Bills List ──────────────────────────────────────────────────────
  Widget _buildBillsList(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return Obx(() => Column(
      children: List.generate(controller.bills.length, (index) {
        final bill = controller.bills[index];
        return _buildBillCard(context, isDark, controller, bill, index);
      }),
    ));
  }

  // ── Bill Card ───────────────────────────────────────────────────────
  Widget _buildBillCard(BuildContext context, bool isDark,
      GenerateBillController controller, dynamic bill, int index) {
    final formattedDate = bill.billDate != null
        ? DateFormat('dd/MM/yyyy').format(bill.billDate!)
        : 'N/A';

    final accentColors = [
      AppThemeData.neonBlue,
      AppThemeData.neonPurple,
      AppThemeData.neonMint,
      AppThemeData.neonOrange,
      AppThemeData.neonTeal,
      AppThemeData.neonPink,
    ];
    final accent = accentColors[index % accentColors.length];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.surfaceElevated : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppThemeData.surfaceBorder : AppThemeData.grey3,
          width: 0.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: isDark ? 0.06 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.viewBillPreview(bill),
          child: Row(
            children: [
              // Left accent stripe
              Container(
                width: 5,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [accent, accent.withValues(alpha: 0.4)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    bottomLeft: Radius.circular(18),
                  ),
                ),
              ),

              // Index number
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: accent,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: FontFamily.bold,
                      ),
                    ),
                  ),
                ),
              ),

              // Bill info
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextCustom(
                        title: bill.toName ?? 'N/A',
                        fontSize: 15,
                        fontFamily: FontFamily.semiBold,
                        color: isDark
                            ? AppThemeData.primaryWhite
                            : AppThemeData.grey10,
                      ),
                      spaceH(height: 6),
                      Row(
                        children: [
                          Icon(Icons.receipt_outlined,
                              size: 12,
                              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                          spaceW(width: 4),
                          TextCustom(
                            title: bill.formattedInvoiceNumber,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                          ),
                          spaceW(width: 12),
                          Icon(Icons.calendar_today_outlined,
                              size: 12,
                              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                          spaceW(width: 4),
                          TextCustom(
                            title: formattedDate,
                            fontSize: 12,
                            fontFamily: FontFamily.regular,
                            color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Amount + actions
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextCustom(
                      title: '\u20B9${(bill.totalAmount ?? 0).toStringAsFixed(2)}',
                      fontSize: 17,
                      fontFamily: FontFamily.bold,
                      color: accent,
                    ),
                    spaceH(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildActionChip(
                          isDark,
                          Icons.edit_outlined,
                          () => controller.editBill(bill),
                          AppThemeData.neonBlue,
                        ),
                        spaceW(width: 8),
                        _buildActionChip(
                          isDark,
                          Icons.delete_outline,
                          () => controller.deleteBill(bill.id!),
                          AppThemeData.neonRed,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionChip(
      bool isDark, IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }

  // ── FAB ─────────────────────────────────────────────────────────────
  Widget _buildGenerateButton(
      BuildContext context, bool isDark, GenerateBillController controller) {
    return GestureDetector(
      onTap: () async {
        controller.resetForm();
        final result = await Get.toNamed(Routes.GENERATE_BILL_CREATE);
        if (result == true) {
          controller.loadBills();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          gradient: AppThemeData.neonPurpleBlueGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppThemeData.neonGlow(AppThemeData.primary50, opacity: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add_rounded, color: Colors.white, size: 22),
            spaceW(width: 8),
            const Text(
              'Generate Bill',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
                fontFamily: FontFamily.semiBold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Data Models ──────────────────────────────────────────────────────────
class _StatData {
  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatData({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });
}
