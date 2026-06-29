import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/mahek_responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/network_image_widget.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:maheksync/app/widgets/text_field_widget.dart';
import 'package:maheksync/app/models/vault_model.dart';
import 'package:maheksync/app/constant/round_shape_button.dart';
import '../controllers/aegis_controller.dart';

class AegisView extends GetView<AegisController> {
  const AegisView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = MahekResponsive.compatIsMobile(context);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0A0E1A) : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value && !controller.isPasswordSet.value) {
          return Center(child: MahekLoader(showBackgroundOverlay: true, message: 'Initializing Aegis...'));
        }
        if (controller.isPasswordSet.value && !controller.isVerified.value) {
          return _buildLockGate(isDark);
        }
        return isMobile ? _buildMobileLayout(isDark) : _buildDesktopLayout(isDark);
      }      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  LOCK GATE
  // ═══════════════════════════════════════════════

  Widget _buildLockGate(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [AppThemeData.primary50, const Color(0xFF6C63FF)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: const Icon(SolarIconsBold.shieldKeyhole, color: Colors.white, size: 48),
              ),
              spaceH(height: 28),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [AppThemeData.primary50, const Color(0xFF6C63FF)],
                ).createShader(bounds),
                child: const Text(
                  'AEGIS',
                  style: TextStyle(fontSize: 36, fontFamily: FontFamily.bold, color: Colors.white, letterSpacing: 8),
                ),
              ),
              spaceH(height: 8),
              TextCustom(
                title: 'Enter master password to unlock',
                fontSize: 14, fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
              ),
              spaceH(height: 40),
              if (controller.isLocked.value) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppThemeData.danger300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppThemeData.danger300.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(SolarIconsBold.lockKeyhole, color: AppThemeData.danger300, size: 20),
                      spaceW(width: 12),
                      Expanded(
                        child: TextCustom(
                          title: 'Access locked. Too many failed attempts.',
                          fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger300,
                        ),
                      ),
                    ],
                  ),
                ),
                spaceH(height: 20),
              ],
              Container(
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.05), blurRadius: 20, offset: const Offset(0, 4)),
                  ],
                ),
                child: TextFieldWidget(
                  hintText: 'Master password',
                  controller: controller.currentPasswordController,
                  onPress: () {},
                  obscureText: true,
                  prefix: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(SolarIconsOutline.lockKeyhole, color: AppThemeData.primary50, size: 18),
                  ),
                ),
              ),
              spaceH(height: 20),
              RoundShapeButton(
                width: double.infinity,
                height: 54,
                title: 'Unlock',
                buttonColor: AppThemeData.primary50,
                buttonTextColor: Colors.white,
                borderColor: Colors.transparent,
                borderRadius: 16,
                onTap: controller.isLocked.value ? () {} : () => controller.verifyMasterPassword(),
                titleWidget: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(SolarIconsBold.lockKeyhole, color: Colors.white, size: 20),
                    SizedBox(width: 10),
                    TextCustom(title: 'Unlock', fontSize: 16, fontFamily: FontFamily.semiBold, color: Colors.white),
                  ],
                ),
              ),
              spaceH(height: 16),
              TextButton(
                onPressed: controller.resetMasterPassword,
                child: TextCustom(title: 'Forgot password?', fontSize: 13, fontFamily: FontFamily.medium, color: AppThemeData.danger300),
              ),
              if (controller.failedAttempts.value > 0 && !controller.isLocked.value) ...[
                spaceH(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppThemeData.danger300.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextCustom(
                    title: '${controller.failedAttempts.value}/5 attempts',
                    fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.danger300,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  DESKTOP LAYOUT — side by side
  // ═══════════════════════════════════════════════

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildListPanel(isDark)),
        Container(width: 1, color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.5)),
        Expanded(flex: 4, child: _buildDetailPanel(isDark)),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  MOBILE LAYOUT — stack navigation
  // ═══════════════════════════════════════════════

  Widget _buildMobileLayout(bool isDark) {
    return Obx(() {
      if (controller.selectedItemId.value != null) {
        return _buildDetailPanelMobile(isDark);
      }
      return _buildListPanel(isDark);
    });
  }

  // ═══════════════════════════════════════════════
  //  LIST PANEL
  // ═══════════════════════════════════════════════

  Widget _buildListPanel(bool isDark) {
    return Column(
      children: [
        _buildSearchBar(isDark),
        _buildCategoryFilters(isDark),
        Expanded(child: _buildVaultList(isDark)),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  SEARCH BAR
  // ═══════════════════════════════════════════════

  Widget _buildSearchBar(bool isDark) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 10, offset: const Offset(0, 2))],
                border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
              ),
              child: TextField(
                onChanged: controller.updateSearchQuery,
                style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                decoration: InputDecoration(
                  hintText: 'Search your vault...',
                  hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppThemeData.primary50.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(SolarIconsOutline.minimalisticMagnifier, color: AppThemeData.primary50, size: 20),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
          ),
          spaceW(width: 12),
          RoundShapeButton(
            title: 'Add Item',
            buttonColor: AppThemeData.primary50,
            buttonTextColor: Colors.white,
            borderColor: Colors.transparent,
            borderRadius: 14,
            height: 50,
            onTap: controller.goToAdd,
            titleWidget: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: Colors.white, size: 20),
                SizedBox(width: 6),
                TextCustom(title: 'Add Item', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  CATEGORY FILTERS
  // ═══════════════════════════════════════════════

  Widget _buildCategoryFilters(bool isDark) {
    return Container(
      height: 48,
      margin: const EdgeInsets.only(top: 12),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: controller.categories.map((cat) {
          final isSelected = controller.selectedCategory.value == cat;
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: GestureDetector(
              onTap: () => controller.filterByCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: isSelected ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
                    width: isSelected ? 1.5 : 0.5,
                  ),
                ),
                child: TextCustom(
                  title: cat == 'ALL' ? 'All' : cat.replaceAll('_', ' '),
                  fontSize: 11,
                  fontFamily: isSelected ? FontFamily.bold : FontFamily.medium,
                  color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ═══════════════════════════════════════════════
  //  VAULT LIST
  // ═══════════════════════════════════════════════

  Widget _buildVaultList(bool isDark) {
    return Column(
      children: [
        _buildListHeader(isDark),
        Expanded(
          child: Obx(() {
            if (controller.filteredItems.isEmpty) return _buildEmptyState(isDark);
            if (controller.isGridView.value) {
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.6,
                ),
                itemCount: controller.filteredItems.length,
                itemBuilder: (context, index) {
                  final item = controller.filteredItems[index];
                  return _buildGridItem(item, isDark);
                },
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
              itemCount: controller.filteredItems.length,
              separatorBuilder: (_, _) => Container(
                height: 0.5,
                margin: const EdgeInsets.only(left: 56),
                color: isDark ? AppThemeData.grey8.withValues(alpha: 0.3) : AppThemeData.grey3.withValues(alpha: 0.5),
              ),
              itemBuilder: (context, index) {
                final item = controller.filteredItems[index];
                return _buildListItem(item, isDark);
              },
            );
          }),
        ),
        _buildListFooter(isDark),
      ],
    );
  }

  Widget _buildListHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextCustom(
            title: 'All Items',
            fontSize: 18, fontFamily: FontFamily.bold,
            color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
          ),
          Row(
            children: [
              _buildSortDropdown(isDark),
              spaceW(width: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Obx(() => Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggle(Icons.view_list_rounded, true, isDark, controller.isGridView.value == false),
                    _buildViewToggle(Icons.grid_view_rounded, false, isDark, controller.isGridView.value == true),
                  ],
                )),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown(bool isDark) {
    return GestureDetector(
      onTap: () => _showSortMenu(isDark),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextCustom(
              title: 'Sort by: ${controller.sortBy.value == 'recently_used' ? 'Recently Used' : controller.sortBy.value}',
              fontSize: 11, fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey5 : AppThemeData.grey6,
            ),
            spaceW(width: 4),
            Icon(SolarIconsOutline.altArrowDown, size: 12, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
          ],
        ),
      ),
    );
  }

  void _showSortMenu(bool isDark) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextCustom(title: 'Sort by', fontSize: 16, fontFamily: FontFamily.bold, color: isDark ? Colors.white : AppThemeData.grey10),
            spaceH(height: 12),
            ...controller.sortOptions.map((opt) {
              final isActive = (opt == 'Recently Used' && controller.sortBy.value == 'recently_used') ||
                  (opt == controller.sortBy.value);
              return ListTile(
                onTap: () {
                  final sortKey = opt == 'Recently Used' ? 'recently_used' : opt;
                  controller.setSortBy(sortKey);
                  Get.back();
                },
                title: TextCustom(
                  title: opt, fontSize: 14,
                  fontFamily: isActive ? FontFamily.bold : FontFamily.regular,
                  color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.grey3 : AppThemeData.grey7),
                ),
                trailing: isActive ? Icon(SolarIconsBold.checkCircle, color: AppThemeData.primary50, size: 18) : null,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildViewToggle(IconData icon, bool isList, bool isDark, bool isActive) {
    return GestureDetector(
      onTap: () => controller.isGridView.value = !isList,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: isActive ? AppThemeData.primary50 : (isDark ? AppThemeData.grey5 : AppThemeData.grey6)),
      ),
    );
  }

  Widget _buildListItem(VaultModel item, bool isDark) {
    final isSelected = controller.selectedItemId.value == item.id;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => controller.selectItem(item.id),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          color: isSelected
              ? AppThemeData.primary50.withValues(alpha: isDark ? 0.08 : 0.06)
              : Colors.transparent,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => controller.toggleFavorite(item),
                child: Icon(
                  item.isFavorite == true ? SolarIconsBold.heart : SolarIconsOutline.heart,
                  size: 16,
                  color: item.isFavorite == true
                      ? const Color(0xFFFFB14E)
                      : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                ),
              ),
              spaceW(width: 12),
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: item.categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: item.iconUrl != null && item.iconUrl!.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(10), child: NetworkImageWidget(imageUrl: item.iconUrl!, fit: BoxFit.cover))
                    : Icon(item.categoryIcon, color: item.categoryColor, size: 18),
              ),
              spaceW(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: item.title ?? '',
                      fontSize: 14, fontFamily: FontFamily.semiBold,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      maxLine: 1,
                    ),
                    spaceH(height: 3),
                    _buildCategoryBadge(item.categoryLabel, item.categoryColor),
                  ],
                ),
              ),
              TextCustom(
                title: controller.timeAgo(item.updatedAt ?? item.createdAt),
                fontSize: 11, fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              spaceW(width: 8),
              GestureDetector(
                onTap: () => _showItemMenu(item, isDark),
                child: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridItem(VaultModel item, bool isDark) {
    final isSelected = controller.selectedItemId.value == item.id;
    return GestureDetector(
      onTap: () => controller.selectItem(item.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppThemeData.primary50.withValues(alpha: isDark ? 0.1 : 0.06)
              : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3),
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppThemeData.primary50.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: item.categoryColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: item.iconUrl != null && item.iconUrl!.isNotEmpty
                      ? ClipRRect(borderRadius: BorderRadius.circular(12), child: NetworkImageWidget(imageUrl: item.iconUrl!, fit: BoxFit.cover))
                      : Icon(item.categoryIcon, color: item.categoryColor, size: 22),
                ),
                GestureDetector(
                  onTap: () => controller.toggleFavorite(item),
                  child: Icon(
                    item.isFavorite == true ? SolarIconsBold.heart : SolarIconsOutline.heart,
                    size: 16,
                    color: item.isFavorite == true ? const Color(0xFFFFB14E) : (isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(
                  title: item.title ?? '',
                  fontSize: 14, fontFamily: FontFamily.semiBold,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  maxLine: 1,
                ),
                spaceH(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildCategoryBadge(item.categoryLabel, item.categoryColor),
                    TextCustom(
                      title: controller.timeAgo(item.updatedAt ?? item.createdAt),
                      fontSize: 10, fontFamily: FontFamily.regular,
                      color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showItemMenu(VaultModel item, bool isDark) {
    showModalBottomSheet(
      context: Get.context!,
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.primaryWhite,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuTile(SolarIconsOutline.penNewRound, 'Edit', () { Get.back(); controller.goToEdit(item); }, isDark),
            _buildMenuTile(
              item.isPinned == true ? SolarIconsOutline.pin : SolarIconsBold.pin,
              item.isPinned == true ? 'Unpin' : 'Pin',
              () { Get.back(); controller.togglePin(item); }, isDark,
            ),
            _buildMenuTile(
              item.isFavorite == true ? SolarIconsOutline.heart : SolarIconsBold.heart,
              item.isFavorite == true ? 'Unfavorite' : 'Favorite',
              () { Get.back(); controller.toggleFavorite(item); }, isDark,
            ),
            _buildMenuTile(SolarIconsOutline.trashBin2, 'Delete', () { Get.back(); controller.deleteItem(item); }, isDark, isDanger: true),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuTile(IconData icon, String label, VoidCallback onTap, bool isDark, {bool isDanger = false}) {
    final color = isDanger ? AppThemeData.danger300 : (isDark ? AppThemeData.grey3 : AppThemeData.grey7);
    return ListTile(
      leading: Icon(icon, size: 20, color: color),
      title: TextCustom(title: label, fontSize: 14, fontFamily: FontFamily.medium, color: color),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
    );
  }

  Widget _buildListFooter(bool isDark) {
    return Obx(() {
      final total = controller.filteredItems.length;
      final all = controller.vaultItems.length;
      final start = total > 0 ? 1 : 0;
      final end = total;
      return Container(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: TextCustom(
          title: 'Showing $start to $end of $all items',
          fontSize: 12, fontFamily: FontFamily.regular,
          color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
        ),
      );
    });
  }

  // ═══════════════════════════════════════════════
  //  DETAIL PANEL
  // ═══════════════════════════════════════════════

  Widget _buildDetailPanel(bool isDark) {
    return Obx(() {
      final item = controller.selectedItem;
      if (item == null) return _buildDetailEmpty(isDark);
      return Column(
        children: [
          _buildDetailHeaderBar(item, isDark),
          Expanded(child: _buildDetailContent(item, isDark)),
        ],
      );
    });
  }

  Widget _buildDetailPanelMobile(bool isDark) {
    return Obx(() {
      final item = controller.selectedItem;
      if (item == null) return _buildDetailEmpty(isDark);
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0A0E1A) : AppThemeData.grey2,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(52),
          child: _buildDetailHeaderBar(item, isDark),
        ),
        body: _buildDetailContent(item, isDark),
      );
    });
  }

  Widget _buildDetailHeaderBar(VaultModel item, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => controller.selectItem(null),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(SolarIconsOutline.altArrowLeft, size: 18, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => controller.toggleFavorite(item),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                item.isFavorite == true ? SolarIconsBold.heart : SolarIconsOutline.heart,
                size: 18,
                color: item.isFavorite == true ? const Color(0xFFFFB14E) : (isDark ? AppThemeData.grey4 : AppThemeData.grey7),
              ),
            ),
          ),
          spaceW(width: 8),
          GestureDetector(
            onTap: () => _showItemMenu(item, isDark),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppThemeData.grey9 : AppThemeData.grey2,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.more_vert_rounded, size: 18, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailContent(VaultModel item, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: item.categoryColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: item.iconUrl != null && item.iconUrl!.isNotEmpty
                    ? ClipRRect(borderRadius: BorderRadius.circular(16), child: NetworkImageWidget(imageUrl: item.iconUrl!, fit: BoxFit.cover))
                    : Icon(item.categoryIcon, color: item.categoryColor, size: 28),
              ),
              spaceW(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextCustom(
                      title: item.title ?? '',
                      fontSize: 20, fontFamily: FontFamily.bold,
                      color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                      maxLine: 2,
                    ),
                    spaceH(height: 4),
                    _buildCategoryBadge(item.categoryLabel, item.categoryColor),
                  ],
                ),
              ),
            ],
          ),
          spaceH(height: 24),
          Divider(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, height: 1),
          spaceH(height: 20),

          if (item.username != null && item.username!.isNotEmpty) ...[
            _buildDetailField(
              icon: SolarIconsOutline.user,
              label: controller.fieldLabel('username'),
              value: item.username!,
              isDark: isDark,
              isPassword: false,
              fieldId: '${item.id}_username',
            ),
            spaceH(height: 12),
          ],
          if (item.email != null && item.email!.isNotEmpty) ...[
            _buildDetailField(
              icon: SolarIconsOutline.letter,
              label: 'Email',
              value: item.email!,
              isDark: isDark,
              isPassword: false,
              fieldId: '${item.id}_email',
            ),
            spaceH(height: 12),
          ],
          if (item.password != null && item.password!.isNotEmpty) ...[
            _buildDetailPasswordField(item, isDark),
            spaceH(height: 12),
          ],
          if (item.website != null && item.website!.isNotEmpty) ...[
            _buildDetailField(
              icon: SolarIconsOutline.link,
              label: controller.fieldLabel('website'),
              value: item.website!,
              isDark: isDark,
              isPassword: false,
              fieldId: '${item.id}_website',
            ),
            spaceH(height: 12),
          ],
          if (item.phone != null && item.phone!.isNotEmpty) ...[
            _buildDetailField(
              icon: SolarIconsOutline.phone,
              label: controller.fieldLabel('phone'),
              value: item.phone!,
              isDark: isDark,
              isPassword: false,
              fieldId: '${item.id}_phone',
            ),
            spaceH(height: 12),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            _buildNotesSection(item, isDark),
            spaceH(height: 16),
          ],
          if (item.tags != null && item.tags!.isNotEmpty) ...[
            _buildTagsSection(item, isDark),
            spaceH(height: 24),
          ],

          _buildMetadataRow(item, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailField({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
    required bool isPassword,
    required String fieldId,
  }) {
    final isRevealed = controller.revealedFields.contains(fieldId);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
        border: isPassword ? Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, size: 15, color: AppThemeData.primary50),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                spaceH(height: 3),
                TextCustom(
                  title: isPassword ? (isRevealed ? value : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022') : value,
                  fontSize: 14, fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                  maxLine: 1,
                ),
              ],
            ),
          ),
          if (isPassword)
            GestureDetector(
              onTap: () => controller.revealField(fieldId),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(isRevealed ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye, size: 15, color: AppThemeData.primary50),
              ),
            ),
          if (isPassword) spaceW(width: 6),
          GestureDetector(
            onTap: () => controller.copyToClipboard(value, label: label),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(SolarIconsOutline.copy, size: 15, color: AppThemeData.primary50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailPasswordField(VaultModel item, bool isDark) {
    final fieldId = '${item.id}_password';
    final isRevealed = controller.revealedFields.contains(fieldId);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(SolarIconsOutline.lockKeyhole, size: 15, color: AppThemeData.primary50),
          ),
          spaceW(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Password', fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
                spaceH(height: 3),
                TextCustom(
                  title: isRevealed ? (item.password ?? '') : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                  fontSize: 14, fontFamily: FontFamily.medium,
                  color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => controller.revealField(fieldId),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(isRevealed ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye, size: 15, color: AppThemeData.primary50),
            ),
          ),
          spaceW(width: 6),
          GestureDetector(
            onTap: () => controller.copyToClipboard(item.password ?? '', label: 'Password'),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(SolarIconsOutline.copy, size: 15, color: AppThemeData.primary50),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(VaultModel item, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.grey9 : AppThemeData.grey1,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(SolarIconsOutline.notes, size: 15, color: AppThemeData.primary50),
              ),
              spaceW(width: 12),
              TextCustom(title: 'Notes', fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            ],
          ),
          spaceH(height: 8),
          TextCustom(
            title: item.notes ?? '',
            fontSize: 13, fontFamily: FontFamily.regular,
            color: isDark ? AppThemeData.grey3 : AppThemeData.grey7,
          ),
        ],
      ),
    );
  }

  Widget _buildTagsSection(VaultModel item, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 24, height: 24,
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)),
              child: Icon(SolarIconsOutline.tag, color: AppThemeData.primary50, size: 13),
            ),
            spaceW(width: 8),
            TextCustom(title: 'Tags', fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
          ],
        ),
        spaceH(height: 8),
        Wrap(
          spacing: 6, runSpacing: 6,
          children: item.tags!.map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppThemeData.primary50.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextCustom(title: '#$tag', fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(VaultModel item, bool isDark) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: 'Created', fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              spaceH(height: 4),
              TextCustom(
                title: controller.formatDateTime(item.createdAt),
                fontSize: 12, fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextCustom(title: 'Last Modified', fontSize: 11, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
              spaceH(height: 4),
              TextCustom(
                title: controller.formatDateTime(item.updatedAt),
                fontSize: 12, fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey4 : AppThemeData.grey6,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════
  //  HELPERS
  // ═══════════════════════════════════════════════

  Widget _buildCategoryBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.bold, color: color),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                color: AppThemeData.primary50.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(SolarIconsOutline.lockKeyhole, size: 40, color: AppThemeData.primary50.withValues(alpha: 0.5)),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No items found', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
            spaceH(height: 8),
            TextCustom(title: 'Add your first vault item', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            spaceH(height: 24),
            RoundShapeButton(
              title: 'Add Item',
              buttonColor: AppThemeData.primary50,
              buttonTextColor: Colors.white,
              borderColor: Colors.transparent,
              borderRadius: 14,
              height: 48,
              onTap: controller.goToAdd,
              titleWidget: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(SolarIconsOutline.addCircle, size: 18, color: Colors.white),
                  SizedBox(width: 8),
                  TextCustom(title: 'Add Item', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailEmpty(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(SolarIconsOutline.cursor, size: 48, color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
          spaceH(height: 16),
          TextCustom(title: 'Select an item to view details', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
        ],
      ),
    );
  }
}
