import 'dart:async';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/constant/constants.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/font_family.dart';

/// ===============================
/// REMINDER DATA MODEL
/// ===============================
class ReminderData {
  final String? id;
  final String? name;
  final String? description;
  final String? iconUrl;
  final DateTime? expiryDate;
  final bool? isActive;

  ReminderData({this.id, this.name, this.description, this.iconUrl, this.expiryDate, this.isActive});

  factory ReminderData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderData(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      iconUrl: data['iconUrl'],
      expiryDate: data['expiryDate']?.toDate(),
      isActive: data['isActive'] ?? true,
    );
  }

  String get formattedExpiryDate {
    if (expiryDate == null) return '';
    return '${expiryDate!.day.toString().padLeft(2, '0')}/${expiryDate!.month.toString().padLeft(2, '0')}/${expiryDate!.year}';
  }

  int get daysRemaining => expiryDate != null ? expiryDate!.difference(DateTime.now()).inDays : 0;
  bool get isExpiringSoon => daysRemaining <= 3 && daysRemaining >= 0;
}

/// ===============================
/// GLOBAL REMINDER CONTROLLER
/// ===============================
class MahekReminderController extends GetxController {
  Timer? _ownerCheckTimer;
  Timer? _autoTimer;
  OverlayEntry? _overlayEntry;
  StreamSubscription? _reminderSubscription;

  final isShowing = false.obs;
  final activeReminders = <ReminderData>[].obs;
  int _currentIndex = 0;
  bool _isListening = false;

  final interval = const Duration(seconds: 10);
  final visibleFor = const Duration(seconds: 6);

  @override
  void onInit() {
    super.onInit();
    print('🔔 MahekReminderController onInit - waiting for owner...');
    _checkForOwnerAndStart();
  }

  void _checkForOwnerAndStart() {
    _ownerCheckTimer?.cancel();
    _ownerCheckTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      final ownerId = MahekConstant.ownerModel?.id;
      if (ownerId != null && !_isListening) {
        print('✅ Owner found: $ownerId');
        _ownerCheckTimer?.cancel();
        _loadActiveReminders(ownerId);
        _startTimer();
      }
    });
  }

  void _loadActiveReminders(String ownerId) {
    _isListening = true;
    print('📡 Fetching reminders for: $ownerId');

    _reminderSubscription?.cancel();
    _reminderSubscription = FirebaseFirestore.instance
        .collection('reminders')
        .where('ownerId', isEqualTo: ownerId)
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      activeReminders.value = snapshot.docs.map((doc) => ReminderData.fromFirestore(doc)).toList();
      activeReminders.sort((a, b) {
        if (a.expiryDate == null) return 1;
        if (b.expiryDate == null) return -1;
        return a.expiryDate!.compareTo(b.expiryDate!);
      });
      print('📋 Loaded ${activeReminders.length} active reminders');
    });
  }

  void _startTimer() {
    _autoTimer?.cancel();
    print('⏰ Timer started - will show every ${interval.inSeconds}s');
    Future.delayed(const Duration(seconds: 5), () => _tryShow());
    _autoTimer = Timer.periodic(interval, (_) => _tryShow());
  }

  void _tryShow() {
    if (activeReminders.isEmpty) return;
    final navigator = Get.key.currentState?.overlay;
    if (navigator == null) return;

    _overlayEntry?.remove();
    _overlayEntry = null;

    final reminder = activeReminders[_currentIndex % activeReminders.length];
    _currentIndex++;
    print('📢 Showing: ${reminder.name}');

    _overlayEntry = OverlayEntry(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Positioned(
          left: 20,
          bottom: 20,
          child: Material(
            color: Colors.transparent,
            child: _ReminderToast(reminder: reminder, isDark: isDark, onClose: _removeOverlay),
          ),
        );
      },
    );

    navigator.insert(_overlayEntry!);
    isShowing.value = true;
    Future.delayed(visibleFor, _removeOverlay);
  }

  void _removeOverlay() {
    try { _overlayEntry?.remove(); } catch (_) {}
    _overlayEntry = null;
    isShowing.value = false;
  }

  @override
  void onClose() {
    _ownerCheckTimer?.cancel();
    _autoTimer?.cancel();
    _reminderSubscription?.cancel();
    _removeOverlay();
    super.onClose();
  }
}

/// ===============================
/// TOAST UI
/// ===============================
class _ReminderToast extends StatefulWidget {
  final ReminderData reminder;
  final bool isDark;
  final VoidCallback onClose;
  const _ReminderToast({required this.reminder, required this.isDark, required this.onClose});

  @override
  State<_ReminderToast> createState() => _ReminderToastState();
}

class _ReminderToastState extends State<_ReminderToast> with SingleTickerProviderStateMixin {
  late AnimationController _pc;
  late Animation<double> _slide, _fade;

  @override
  void initState() {
    super.initState();
    _pc = AnimationController(vsync: this, duration: const Duration(seconds: 6))..forward();
    _slide = Tween<double>(begin: 80, end: 0).animate(CurvedAnimation(parent: _pc, curve: const Interval(0.0, 0.2, curve: Curves.easeOutCubic)));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _pc, curve: const Interval(0.0, 0.2, curve: Curves.easeOut)));
  }

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.reminder;
    final isDark = widget.isDark;
    final accent = r.isExpiringSoon ? AppThemeData.danger300 : AppThemeData.primary50;

    return AnimatedBuilder(
      animation: _pc,
      builder: (context, _) {
        return Opacity(
          opacity: _fade.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, _slide.value),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: 340,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(colors: isDark ? [AppThemeData.primaryBlack.withValues(alpha: 0.95), AppThemeData.grey9.withValues(alpha: 0.95)] : [Colors.white.withValues(alpha: 0.95), AppThemeData.grey1.withValues(alpha: 0.95)]),
                    border: Border.all(color: accent.withValues(alpha: 0.3), width: 1.5),
                    boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.15), blurRadius: 30, offset: const Offset(0, 8)), BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 20, offset: const Offset(0, 4))],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48, height: 48,
                            decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [accent.withValues(alpha: 0.3), accent.withValues(alpha: 0.1)]), border: Border.all(color: accent.withValues(alpha: 0.4), width: 2)),
                            child: ClipOval(
                              child: r.iconUrl != null && r.iconUrl!.isNotEmpty
                                  ? Image.network(r.iconUrl!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(Icons.alarm_rounded, color: accent, size: 24))
                                  : Icon(Icons.alarm_rounded, color: accent, size: 24),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(r.name ?? 'Reminder', style: TextStyle(fontFamily: FontFamily.bold, fontSize: 16, color: isDark ? Colors.white : AppThemeData.grey10), maxLines: 1, overflow: TextOverflow.ellipsis),
                                if (r.expiryDate != null) ...[
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(Icons.calendar_today_rounded, size: 12, color: r.isExpiringSoon ? AppThemeData.danger300 : AppThemeData.grey5),
                                      const SizedBox(width: 4),
                                      Text('Due: ${r.formattedExpiryDate}', style: TextStyle(fontFamily: FontFamily.medium, fontSize: 12, color: r.isExpiringSoon ? AppThemeData.danger300 : AppThemeData.grey5)),
                                      if (r.daysRemaining > 0) ...[
                                        const SizedBox(width: 6),
                                        Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: r.isExpiringSoon ? AppThemeData.danger300.withValues(alpha: 0.15) : AppThemeData.success400.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8)), child: Text('${r.daysRemaining}d left', style: TextStyle(fontFamily: FontFamily.bold, fontSize: 10, color: r.isExpiringSoon ? AppThemeData.danger300 : AppThemeData.success400))),
                                      ],
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                          GestureDetector(onTap: widget.onClose, child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.1)), child: Icon(Icons.close_rounded, size: 18, color: isDark ? AppThemeData.grey4 : AppThemeData.grey6))),
                        ],
                      ),
                      if (r.description != null && r.description!.isNotEmpty) ...[const SizedBox(height: 10), Text(r.description!, style: TextStyle(fontFamily: FontFamily.regular, fontSize: 13, color: isDark ? AppThemeData.grey4 : AppThemeData.grey7), maxLines: 2, overflow: TextOverflow.ellipsis)],
                      const SizedBox(height: 14),
                      ClipRRect(borderRadius: BorderRadius.circular(100), child: LinearProgressIndicator(value: 1.0 - _pc.value, minHeight: 4, backgroundColor: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.08), valueColor: AlwaysStoppedAnimation<Color>(accent))),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;
  const AnimatedBuilder({super.key, required Animation<double> animation, required this.builder, this.child}) : super(listenable: animation);
  @override
  Widget build(BuildContext context) => builder(context, child);
}