import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:solar_icons/solar_icons.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/responsive.dart';
import 'package:maheksync/app/widgets/global_widgets.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import '../../../models/vault_model.dart';
import '../controllers/vault_controller.dart';

class VaultView extends GetView<VaultController> {
  const VaultView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isMobile = ResponsiveWidget.isMobile(context);

    return Scaffold(
      backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: MahekLoader(showBackgroundOverlay: true, message: 'Loading Vault...'));
        }
        return isMobile ? _buildMobileLayout(isDark) : _buildDesktopLayout(isDark);
      }),
      floatingActionButton: isMobile ? _buildFloatingButton(isDark) : null,
    );
  }

  Widget _buildDesktopLayout(bool isDark) {
    return Row(
      children: [
        Expanded(flex: 5, child: _buildLeftPanel(isDark)),
        Container(width: 1, color: isDark ? AppThemeData.grey8.withValues(alpha: 0.2) : AppThemeData.grey3.withValues(alpha: 0.3)),
        Expanded(flex: 4, child: _buildRightPanel(isDark)),
      ],
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 14),
          _buildStatsCards(isDark),
          spaceH(height: 14),
          _buildSearchBar(isDark),
          spaceH(height: 10),
          _buildCategoryFilters(isDark),
          spaceH(height: 14),
          Expanded(child: _buildVaultGrid(isDark)),
        ],
      ),
    );
  }

  Widget _buildLeftPanel(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(isDark),
          spaceH(height: 16),
          _buildStatsCards(isDark),
          spaceH(height: 16),
          _buildSearchBar(isDark),
          spaceH(height: 10),
          _buildCategoryFilters(isDark),
          spaceH(height: 14),
          Expanded(child: _buildVaultGrid(isDark)),
        ],
      ),
    );
  }

  Widget _buildRightPanel(bool isDark) {
    return Obx(() {
      if (controller.filteredItems.isEmpty) return _buildEmptyState(isDark);
      return _buildDetailsPanel(isDark);
    });
  }

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppThemeData.primary50, const Color(0xFF6C63FF)]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppThemeData.primary50.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 4))],
              ),
              child: Icon(SolarIconsBold.lockKeyhole, color: Colors.white, size: 26),
            ),
            spaceW(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextCustom(title: 'Vault', fontSize: 24, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
                TextCustom(title: 'Secure information', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
              ],
            ),
          ],
        ),
        if (!ResponsiveWidget.isMobile(Get.context!))
          ElevatedButton.icon(
            onPressed: controller.goToAdd,
            icon: Icon(SolarIconsOutline.addCircle, size: 18),
            label: const TextCustom(title: 'Add Item', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ),
      ],
    );
  }

  Widget _buildStatsCards(bool isDark) {
    return Obx(() => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: [
        _buildStatChip('Total', '${controller.totalItems}', AppThemeData.primary50, isDark),
        spaceW(width: 8),
        _buildStatChip('Favorites', '${controller.favoriteCount}', const Color(0xFF6C63FF), isDark),
        spaceW(width: 8),
        _buildStatChip('Pinned', '${controller.pinnedCount}', AppThemeData.pending400, isDark),
        spaceW(width: 8),
        _buildStatChip('Hidden', '${controller.hiddenCount}', AppThemeData.grey5, isDark),
      ]),
    ));
  }

  Widget _buildStatChip(String label, String value, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        TextCustom(title: value, fontSize: 16, fontFamily: FontFamily.bold, color: color),
        spaceW(width: 6),
        TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6),
      ]),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02), blurRadius: 8, offset: const Offset(0, 2))],
        border: Border.all(color: isDark ? AppThemeData.grey8 : AppThemeData.grey3, width: 0.5),
      ),
      child: TextField(
        onChanged: controller.updateSearchQuery,
        style: TextStyle(fontFamily: FontFamily.medium, fontSize: 14, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        decoration: InputDecoration(
          hintText: 'Search vault...',
          hintStyle: TextStyle(fontFamily: FontFamily.regular, fontSize: 14, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          prefixIcon: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
            child: Icon(SolarIconsOutline.minimalisticMagnifier, color: AppThemeData.primary50, size: 20),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCategoryFilters(bool isDark) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Obx(() => Row(children: controller.categories.map((cat) {
        final isSelected = controller.selectedCategory.value == cat;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => controller.filterByCategory(cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected ? AppThemeData.primary50.withValues(alpha: 0.15) : (isDark ? AppThemeData.grey9 : AppThemeData.grey1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: isSelected ? AppThemeData.primary50 : (isDark ? AppThemeData.grey8 : AppThemeData.grey3), width: isSelected ? 1.5 : 0.5),
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
      }).toList())),
    );
  }

  Widget _buildVaultGrid(bool isDark) {
    return Obx(() {
      if (controller.filteredItems.isEmpty) return _buildEmptyState(isDark);
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(maxCrossAxisExtent: 340, mainAxisSpacing: 10, crossAxisSpacing: 10, childAspectRatio: 2.0),
        itemCount: controller.filteredItems.length,
        itemBuilder: (context, index) => _buildVaultCard(controller.filteredItems[index], isDark),
      );
    });
  }

  Widget _buildVaultCard(VaultModel item, bool isDark) {
    final isRevealed = controller.revealedFields.contains(item.id);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: (item.isPinned == true)
            ? AppThemeData.primary50.withValues(alpha: isDark ? 0.06 : 0.04)
            : (isDark ? AppThemeData.primaryBlack : AppThemeData.primaryWhite),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: item.isPinned == true ? AppThemeData.primary50.withValues(alpha: 0.4) : (isDark ? AppThemeData.grey8 : AppThemeData.grey3).withValues(alpha: 0.5), width: item.isPinned == true ? 1.5 : 0.5),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => controller.goToEdit(item),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 36, height: 36,
                      decoration: BoxDecoration(color: item.categoryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                      child: Icon(item.categoryIcon, color: item.categoryColor, size: 18),
                    ),
                    spaceW(width: 10),
                    Expanded(
                      child: TextCustom(title: item.title ?? '', fontSize: 14, fontFamily: FontFamily.semiBold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1),
                    ),
                    GestureDetector(
                      onTap: () => controller.toggleFavorite(item),
                      child: Icon(item.isFavorite == true ? SolarIconsBold.heart : SolarIconsOutline.heart, size: 18, color: item.isFavorite == true ? const Color(0xFF6C63FF) : (isDark ? AppThemeData.grey6 : AppThemeData.grey5)),
                    ),
                  ],
                ),
                spaceH(height: 8),
                Row(
                  children: [
                    _buildBadge(item.categoryLabel, item.categoryColor, isDark),
                    const Spacer(),
                    if (item.username != null && item.username!.isNotEmpty)
                      Flexible(child: TextCustom(title: isRevealed ? (item.username ?? '') : '\u2022\u2022\u2022\u2022\u2022\u2022', fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey5 : AppThemeData.grey6, maxLine: 1)),
                  ],
                ),
                if (item.tags != null && item.tags!.isNotEmpty) ...[
                  spaceH(height: 6),
                  Wrap(spacing: 4, runSpacing: 2, children: item.tags!.take(2).map((tag) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(4)),
                    child: TextCustom(title: '#$tag', fontSize: 9, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
                  )).toList()),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailsPanel(bool isDark) {
    final item = controller.filteredItems.first;
    final isRevealed = controller.revealedFields.contains(item.id);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: item.categoryColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(item.categoryIcon, color: item.categoryColor, size: 24),
              ),
              spaceW(width: 12),
              Expanded(child: TextCustom(title: item.title ?? '', fontSize: 20, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 2)),
            ],
          ),
          spaceH(height: 20),
          _buildDetailRow('Category', item.categoryLabel, item.categoryColor, isDark),
          if (item.username != null && item.username!.isNotEmpty) ...[
            spaceH(height: 12),
            _buildCopyRow('Username', item.username!, isDark, isRevealed, item.id ?? ''),
          ],
          if (item.email != null && item.email!.isNotEmpty) ...[
            spaceH(height: 12),
            _buildCopyRow('Email', item.email!, isDark, true, item.id ?? ''),
          ],
          if (item.password != null && item.password!.isNotEmpty) ...[
            spaceH(height: 12),
            _buildHiddenField('Password', item.password!, isDark, item.id ?? '', isRevealed),
          ],
          if (item.website != null && item.website!.isNotEmpty) ...[
            spaceH(height: 12),
            _buildCopyRow('Website', item.website!, isDark, true, item.id ?? ''),
          ],
          if (item.phone != null && item.phone!.isNotEmpty) ...[
            spaceH(height: 12),
            _buildCopyRow('Phone', item.phone!, isDark, true, item.id ?? ''),
          ],
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            spaceH(height: 16),
            _buildSectionTitle('Notes', SolarIconsOutline.notes, isDark),
            spaceH(height: 6),
            TextCustom(title: item.notes ?? '', fontSize: 13, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
          ],
          if (item.tags != null && item.tags!.isNotEmpty) ...[
            spaceH(height: 16),
            _buildSectionTitle('Tags', SolarIconsOutline.tag, isDark),
            spaceH(height: 6),
            Wrap(spacing: 6, runSpacing: 4, children: item.tags!.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: TextCustom(title: '#$tag', fontSize: 12, fontFamily: FontFamily.medium, color: AppThemeData.primary50),
            )).toList()),
          ],
          spaceH(height: 24),
          _buildDetailActions(item, isDark),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color color, bool isDark) {
    return Row(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
        child: TextCustom(title: value, fontSize: 12, fontFamily: FontFamily.bold, color: color),
      ),
      const Spacer(),
      TextCustom(title: label, fontSize: 11, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
    ]);
  }

  Widget _buildCopyRow(String label, String value, bool isDark, bool showValue, String fieldId) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(12)),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          spaceH(height: 2),
          TextCustom(title: showValue ? value : '\u2022\u2022\u2022\u2022\u2022\u2022', fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10, maxLine: 1),
        ])),
        GestureDetector(
          onTap: () => controller.copyToClipboard(value, label: label),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(SolarIconsOutline.copy, size: 16, color: AppThemeData.primary50),
          ),
        ),
      ]),
    );
  }

  Widget _buildHiddenField(String label, String value, bool isDark, String fieldId, bool isRevealed) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: isDark ? AppThemeData.grey9 : AppThemeData.grey1, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppThemeData.primary50.withValues(alpha: 0.15))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextCustom(title: label, fontSize: 10, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
          spaceH(height: 2),
          TextCustom(title: isRevealed ? value : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022', fontSize: 13, fontFamily: FontFamily.medium, color: isDark ? AppThemeData.grey1 : AppThemeData.grey10),
        ])),
        GestureDetector(
          onTap: () => controller.revealField(fieldId),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(isRevealed ? SolarIconsOutline.eyeClosed : SolarIconsOutline.eye, size: 16, color: AppThemeData.primary50),
          ),
        ),
        spaceW(width: 6),
        if (isRevealed)
          GestureDetector(
            onTap: () => controller.copyToClipboard(value, label: label),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
              child: Icon(SolarIconsOutline.copy, size: 16, color: AppThemeData.primary50),
            ),
          ),
      ]),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(children: [
      Container(width: 24, height: 24, decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(7)), child: Icon(icon, color: AppThemeData.primary50, size: 13)),
      spaceW(width: 8),
      TextCustom(title: title, fontSize: 12, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7),
    ]);
  }

  Widget _buildDetailActions(VaultModel item, bool isDark) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => controller.goToEdit(item),
            icon: Icon(SolarIconsOutline.penNewRound, size: 16),
            label: const TextCustom(title: 'Edit', fontSize: 13, fontFamily: FontFamily.semiBold, color: Colors.white),
            style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ),
        spaceW(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => controller.toggleFavorite(item),
            icon: Icon(item.isFavorite == true ? SolarIconsOutline.heart : SolarIconsBold.heart, size: 16, color: const Color(0xFF6C63FF)),
            label: TextCustom(title: item.isFavorite == true ? 'Unfav' : 'Favorite', fontSize: 13, fontFamily: FontFamily.semiBold, color: const Color(0xFF6C63FF)),
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: Color(0xFF6C63FF))),
          ),
        ),
      ]),
      spaceH(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () => controller.deleteItem(item),
          icon: Icon(SolarIconsOutline.trashBin2, size: 16, color: AppThemeData.danger300),
          label: const TextCustom(title: 'Delete', fontSize: 13, fontFamily: FontFamily.semiBold, color: AppThemeData.danger300),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), side: const BorderSide(color: AppThemeData.danger300)),
        ),
      ),
    ]);
  }

  Widget _buildBadge(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
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
              decoration: BoxDecoration(color: AppThemeData.primary50.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24)),
              child: Icon(SolarIconsOutline.lockKeyhole, size: 40, color: AppThemeData.primary50.withValues(alpha: 0.5)),
            ),
            spaceH(height: 20),
            TextCustom(title: 'No items found', fontSize: 18, fontFamily: FontFamily.bold, color: isDark ? AppThemeData.grey3 : AppThemeData.grey7),
            spaceH(height: 8),
            TextCustom(title: 'Add your first vault item', fontSize: 14, fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey6 : AppThemeData.grey5),
            spaceH(height: 24),
            ElevatedButton.icon(
              onPressed: controller.goToAdd,
              icon: Icon(SolarIconsOutline.addCircle, size: 18),
              label: const TextCustom(title: 'Add Item', fontSize: 14, fontFamily: FontFamily.semiBold, color: Colors.white),
              style: ElevatedButton.styleFrom(backgroundColor: AppThemeData.primary50, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingButton(bool isDark) {
    return FloatingActionButton(
      onPressed: controller.goToAdd,
      backgroundColor: AppThemeData.primary50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Icon(SolarIconsOutline.addCircle, color: Colors.white, size: 28),
    );
  }
}
