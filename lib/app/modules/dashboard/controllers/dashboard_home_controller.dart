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
