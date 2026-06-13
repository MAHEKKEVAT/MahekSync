import 'dart:async';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/models/device_model.dart';
import 'package:maheksync/app/models/purchase_model.dart';
import 'package:maheksync/app/models/subscription_model.dart';
import 'package:maheksync/app/models/dues_tracker_model.dart';
import 'package:maheksync/app/models/reminder_model.dart';
import 'package:maheksync/app/models/personal_task_model.dart';
import 'package:maheksync/app/models/vault_model.dart';
import 'package:maheksync/app/models/my_contacts_model.dart';
import 'package:maheksync/app/firestore_utills/device_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/purchase_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/subscription_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/dues_tracker_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/reminder_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/personal_task_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/vault_firestore_utils.dart';
import 'package:maheksync/app/firestore_utills/sentinel_firestore_utils.dart';
import 'package:maheksync/app/modules/my_contacts/my_contacts_crud.dart';

class DashboardHomeController extends GetxController {
  static DashboardHomeController get to => Get.find();

  final isLoading = true.obs;

  final deviceCount = 0.obs;
  final purchaseCount = 0.obs;
  final subscriptionCount = 0.obs;
  final duesCount = 0.obs;
  final reminderCount = 0.obs;
  final taskCount = 0.obs;
  final vaultCount = 0.obs;
  final contactCount = 0.obs;

  final latestDevices = <DeviceModel>[].obs;
  final latestPurchases = <PurchaseModel>[].obs;
  final latestSubscriptions = <SubscriptionModel>[].obs;
  final latestDues = <DuesTrackerModel>[].obs;
  final latestReminders = <ReminderModel>[].obs;
  final latestTasks = <PersonalTaskModel>[].obs;
  final latestVaultItems = <VaultModel>[].obs;
  final latestContacts = <MyContactsModel>[].obs;

  final sentinelPasswordSet = false.obs;
  final sentinelLocked = false.obs;

  final List<StreamSubscription> _subs = [];

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  @override
  void onClose() {
    for (final s in _subs) {
      s.cancel();
    }
    super.onClose();
  }

  int get totalItems =>
      deviceCount.value +
      purchaseCount.value +
      subscriptionCount.value +
      duesCount.value +
      reminderCount.value +
      taskCount.value +
      vaultCount.value;

  int get totalModules => [
        deviceCount,
        purchaseCount,
        subscriptionCount,
        duesCount,
        reminderCount,
        taskCount,
        vaultCount,
      ].where((rx) => rx.value > 0).length;

  int get highPriorityReminderCount =>
      latestReminders.where((r) => r.importance == 'HIGH').length;

  int get overdueTaskCount =>
      latestTasks.where((t) => t.isOverdue).length;

  int get oweDuesCount =>
      latestDues.where((d) => d.dueType == DueType.owe).length;

  int get overdueReminderCount =>
      latestReminders.where((r) => r.isExpired).length;

  bool get hasAlerts =>
      highPriorityReminderCount > 0 ||
      overdueTaskCount > 0 ||
      overdueReminderCount > 0;

  // ── Today Focus (for TodayFocusSection) ──────────────────────
  List<PersonalTaskModel> get overdueTasks =>
      latestTasks.where((t) => t.isOverdue).toList();

  List<DuesTrackerModel> get expiringDues {
    final now = DateTime.now();
    final in7Days = now.add(const Duration(days: 7));
    return latestDues.where((d) =>
        !DueStatus.isSettled(d.status) &&
        d.oweDate != null &&
        d.oweDate!.isBefore(in7Days)).toList();
  }

  List<ReminderModel> get urgentReminders =>
      latestReminders.where((r) => r.importance == 'HIGH' || (r.isExpired)).toList();

  bool get hasTodayFocus =>
      overdueTasks.isNotEmpty || expiringDues.isNotEmpty || urgentReminders.isNotEmpty;

  String get todayFocusSummary {
    final parts = <String>[];
    if (overdueTasks.isNotEmpty) parts.add('${overdueTasks.length} task overdue');
    if (expiringDues.isNotEmpty) parts.add('${expiringDues.length} due pending');
    if (urgentReminders.isNotEmpty) parts.add('${urgentReminders.length} reminder');
    return parts.isEmpty ? 'All clear for today!' : parts.join(', ');
  }

  // ── Life Overview (for LifeOverviewSection) ──────────────────
  int get pendingTasks => latestTasks.where((t) => !(t.isCompleted ?? false)).length;

  double get totalOweAmount =>
      latestDues.where((d) => d.dueType == DueType.owe && d.amount != null).fold(0.0, (sum, d) => sum + d.amount!);

  double get totalOwedToMe =>
      latestDues.where((d) => d.dueType == DueType.take && d.amount != null).fold(0.0, (sum, d) => sum + d.amount!);

  String get totalOweFormatted {
    if (totalOweAmount >= 100000) return '\u20B9${(totalOweAmount / 100000).toStringAsFixed(1)}L';
    if (totalOweAmount >= 1000) return '\u20B9${(totalOweAmount / 1000).toStringAsFixed(1)}K';
    return '\u20B9${totalOweAmount.toStringAsFixed(0)}';
  }

  String get totalOwedFormatted {
    if (totalOwedToMe >= 100000) return '\u20B9${(totalOwedToMe / 100000).toStringAsFixed(1)}L';
    if (totalOwedToMe >= 1000) return '\u20B9${(totalOwedToMe / 1000).toStringAsFixed(1)}K';
    return '\u20B9${totalOwedToMe.toStringAsFixed(0)}';
  }

  // ── Financial Snapshot (for FinancialSnapshotCard) ──────────
  String get monthlyPurchaseTotal {
    final now = DateTime.now();
    final monthPurchases = latestPurchases.where((p) =>
        p.purchaseDate != null &&
        p.purchaseDate!.month == now.month &&
        p.purchaseDate!.year == now.year);
    final total = monthPurchases.fold<double>(0, (sum, p) => sum + (p.price ?? 0));
    if (total >= 100000) return '\u20B9${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '\u20B9${(total / 1000).toStringAsFixed(1)}K';
    return '\u20B9${total.toStringAsFixed(0)}';
  }

  String get monthlyDueTotal {
    final now = DateTime.now();
    final monthDues = latestDues.where((d) =>
        !DueStatus.isSettled(d.status) &&
        d.oweDate != null &&
        d.oweDate!.month == now.month &&
        d.oweDate!.year == now.year);
    final total = monthDues.fold<double>(0, (sum, d) => sum + (d.amount ?? 0));
    if (total >= 100000) return '\u20B9${(total / 100000).toStringAsFixed(1)}L';
    if (total >= 1000) return '\u20B9${(total / 1000).toStringAsFixed(1)}K';
    return '\u20B9${total.toStringAsFixed(0)}';
  }

  // ── Security Score (computed once, for SecurityStatusCard) ──
  int get securityScore {
    int score = 0;
    if (sentinelPasswordSet.value) score += 40;
    if (!sentinelLocked.value) score += 30;
    if (deviceCount.value > 0) score += 10;
    if (vaultCount.value > 0) score += 10;
    if (contactCount.value > 0) score += 10;
    return score.clamp(0, 100);
  }

  bool get isSecurityGood => securityScore >= 70;

  List<String> get securityTips {
    final tips = <String>[];
    if (!sentinelPasswordSet.value) tips.add('Set up Sentinel password');
    if (sentinelLocked.value) tips.add('Unlock Sentinel access');
    if (deviceCount.value == 0) tips.add('Add your first device');
    if (vaultCount.value == 0) tips.add('Secure a vault item');
    return tips;
  }

  List<String> get activeModuleLabels {
    final labels = <String>[];
    if (deviceCount.value > 0) labels.add('Devices');
    if (purchaseCount.value > 0) labels.add('Purchases');
    if (subscriptionCount.value > 0) labels.add('Subscriptions');
    if (duesCount.value > 0) labels.add('Dues');
    if (reminderCount.value > 0) labels.add('Reminders');
    if (taskCount.value > 0) labels.add('Tasks');
    if (vaultCount.value > 0) labels.add('Vault');
    return labels;
  }

  void _initData() {
    final ownerId = MahekConstant.ownerModel?.id;
    if (ownerId == null || ownerId.isEmpty) {
      isLoading.value = false;
      return;
    }

    var loaded = 0;
    const total = 9;
    void markReady() {
      loaded++;
      if (loaded >= total) isLoading.value = false;
    }

    var dReady = false, pReady = false, sReady = false, duReady = false;
    var rReady = false, tReady = false, vReady = false, coReady = false, seReady = false;

    _subs.add(DeviceFirestoreUtils.getUserDevices(ownerId).listen((items) {
      deviceCount.value = items.length;
      latestDevices.value = items.take(3).toList();
      if (!dReady) { dReady = true; markReady(); }
    }, onError: (_) { if (!dReady) { dReady = true; markReady(); } }));

    _subs.add(PurchaseFirestoreUtils.getUserPurchases(ownerId).listen((items) {
      purchaseCount.value = items.length;
      latestPurchases.value = items.take(3).toList();
      if (!pReady) { pReady = true; markReady(); }
    }, onError: (_) { if (!pReady) { pReady = true; markReady(); } }));

    _subs.add(SubscriptionFirestoreUtils.getUserSubscriptions(ownerId).listen((items) {
      subscriptionCount.value = items.length;
      latestSubscriptions.value = items.take(3).toList();
      if (!sReady) { sReady = true; markReady(); }
    }, onError: (_) { if (!sReady) { sReady = true; markReady(); } }));

    _subs.add(DuesTrackerFirestoreUtils.getUserDues(ownerId).listen((items) {
      duesCount.value = items.length;
      latestDues.value = items.take(3).toList();
      if (!duReady) { duReady = true; markReady(); }
    }, onError: (_) { if (!duReady) { duReady = true; markReady(); } }));

    _subs.add(ReminderFirestoreUtils.getUserReminders(ownerId).listen((items) {
      reminderCount.value = items.length;
      latestReminders.value = items.take(3).toList();
      if (!rReady) { rReady = true; markReady(); }
    }, onError: (_) { if (!rReady) { rReady = true; markReady(); } }));

    _subs.add(PersonalTaskFirestoreUtils.getUserTasks(ownerId).listen((items) {
      taskCount.value = items.length;
      latestTasks.value = items.take(3).toList();
      if (!tReady) { tReady = true; markReady(); }
    }, onError: (_) { if (!tReady) { tReady = true; markReady(); } }));

    _subs.add(VaultFirestoreUtils.getVaultItems(ownerId).listen((items) {
      vaultCount.value = items.length;
      latestVaultItems.value = items.take(3).toList();
      if (!vReady) { vReady = true; markReady(); }
    }, onError: (_) { if (!vReady) { vReady = true; markReady(); } }));

    _subs.add(MyContactsCrud.streamContacts().listen((items) {
      contactCount.value = items.length;
      latestContacts.value = items.take(3).toList();
      if (!coReady) { coReady = true; markReady(); }
    }, onError: (_) { if (!coReady) { coReady = true; markReady(); } }));

    SentinelFirestoreUtils.getCurrentSentinelAccess(ownerId).then((s) {
      sentinelPasswordSet.value = s?.isPasswordSet ?? false;
      sentinelLocked.value = s?.isLocked ?? false;
      if (!seReady) { seReady = true; markReady(); }
    }).catchError((_) {
      if (!seReady) { seReady = true; markReady(); }
    });

    Future.delayed(const Duration(seconds: 4), () {
      if (isLoading.value) isLoading.value = false;
    });
  }
}
