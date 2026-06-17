import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maheksync/app/widgets/mahek_loader.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class ToastService {
  static final ToastService _instance = ToastService._internal();
  factory ToastService() => _instance;
  ToastService._internal();

  OverlayEntry? _currentToast;
  OverlayEntry? _currentLoader;

  // ─── Loader ──────────────────────────────────────────────────

  void showLoader(String message) {
    try {
      if (_currentLoader != null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (_currentLoader != null) return;

          final overlay = navigatorKey.currentState?.overlay;
          if (overlay == null) return;

          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;

          final isDark = Theme.of(ctx).brightness == Brightness.dark;

          _currentLoader = OverlayEntry(
            builder: (_) => _GlassmorphicLoader(
              message: message,
              isDark: isDark,
            ),
          );

          overlay.insert(_currentLoader!);
        } catch (e) {
          developer.log("Error showing loader: $e");
        }
      });
    } catch (e) {
      developer.log("Error in showLoader: $e");
    }
  }

  void closeLoader() {
    try {
      final entry = _currentLoader;
      _currentLoader = null;

      if (entry == null) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          entry.remove();
        } catch (e) {
          developer.log("Error closing loader: $e");
        }
      });
    } catch (e) {
      developer.log("Error in closeLoader: $e");
      _currentLoader = null;
    }
  }

  // ─── Toasts ──────────────────────────────────────────────────

  void showSuccessToast(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    _showToast(
      title: message,
      subtitle: subtitle,
      accentColor: const Color(0xFF34C759),
      icon: Icons.check_circle_rounded,
    );
  }

  void showErrorToast(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    _showToast(
      title: message,
      subtitle: subtitle,
      accentColor: const Color(0xFFFF3B30),
      icon: Icons.cancel_rounded,
    );
  }

  void showWarningToast(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    _showToast(
      title: message,
      subtitle: subtitle,
      accentColor: const Color(0xFFFF9500),
      icon: Icons.warning_rounded,
    );
  }

  void _showToast({
    required String title,
    String? subtitle,
    required Color accentColor,
    required IconData icon,
  }) {
    final oldToast = _currentToast;
    _currentToast = null;

    if (oldToast != null) {
      try {
        oldToast.remove();
      } catch (_) {}
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final overlay = navigatorKey.currentState?.overlay;
        if (overlay == null) return;

        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;

        final isDark = Theme.of(ctx).brightness == Brightness.dark;

        late final OverlayEntry entry;
        entry = OverlayEntry(
          builder: (_) => _GlassmorphicToast(
            title: title,
            subtitle: subtitle,
            accentColor: accentColor,
            icon: icon,
            isDark: isDark,
            onDismiss: () {
              if (_currentToast == entry) {
                _currentToast = null;
              }
              try {
                entry.remove();
              } catch (_) {}
            },
          ),
        );

        _currentToast = entry;
        overlay.insert(entry);
      } catch (e) {
        developer.log("Error inserting toast: $e");
      }
    });
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASSMORPHIC TOAST — Reference match, bottom-right
// ═══════════════════════════════════════════════════════════════

class _GlassmorphicToast extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Color accentColor;
  final IconData icon;
  final bool isDark;
  final VoidCallback onDismiss;

  const _GlassmorphicToast({
    required this.title,
    this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.isDark,
    required this.onDismiss,
  });

  @override
  State<_GlassmorphicToast> createState() => _GlassmorphicToastState();
}

class _GlassmorphicToastState extends State<_GlassmorphicToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnim;
  late final Animation<double> _fadeAnim;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0.4, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_dismissed) _dismiss();
    });
  }

  void _dismiss() {
    if (_dismissed) return;
    _dismissed = true;
    if (_controller.status == AnimationStatus.forward ||
        _controller.isAnimating) {
      _controller.reverse().then((_) {
        if (mounted) widget.onDismiss();
      });
    } else {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isDark = widget.isDark;

    return Positioned(
      bottom: bottomPadding + 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: _dismiss,
              child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 480),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.93)
                        : const Color(0xFF1A1A1E).withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.06)
                          : Colors.white.withValues(alpha: 0.08),
                      width: 0.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: widget.accentColor.withValues(alpha: 0.12),
                        blurRadius: 28,
                        offset: const Offset(0, 10),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Left accent bar ───────────────────
                        Container(
                          width: 3.5,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              bottomLeft: Radius.circular(16),
                            ),
                          ),
                        ),
                        // ── Icon container ──────────────────────
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(widget.icon, color: widget.accentColor, size: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        // ── Title + subtitle ────────────────────
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.title,
                                  style: TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    height: 1.2,
                                    color: isDark ? const Color(0xFF1A1A1E) : Colors.white,
                                    decoration: TextDecoration.none,
                                  ),
                                ),
                                if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                                  const SizedBox(height: 3),
                                  Text(
                                    widget.subtitle!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      height: 1.3,
                                      color: isDark
                                          ? const Color(0xFF1A1A1E).withValues(alpha: 0.55)
                                          : Colors.white.withValues(alpha: 0.55),
                                      decoration: TextDecoration.none,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // ── Close button ────────────────────────
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 10, 0),
                            child: GestureDetector(
                              onTap: _dismiss,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.06)
                                      : Colors.white.withValues(alpha: 0.08),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  size: 14,
                                  color: isDark
                                      ? Colors.black.withValues(alpha: 0.4)
                                      : Colors.white.withValues(alpha: 0.5),
                                ),
                              ),
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
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// GLASSMORPHIC LOADER — Compact centered overlay
// ═══════════════════════════════════════════════════════════════

class _GlassmorphicLoader extends StatefulWidget {
  final String message;
  final bool isDark;

  const _GlassmorphicLoader({
    required this.message,
    required this.isDark,
  });

  @override
  State<_GlassmorphicLoader> createState() => _GlassmorphicLoaderState();
}

class _GlassmorphicLoaderState extends State<_GlassmorphicLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnim;
  late final Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _scaleAnim = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnim,
      child: ScaleTransition(
        scale: _scaleAnim,
        child: Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                width: 200,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                decoration: BoxDecoration(
                  color: widget.isDark
                      ? Colors.white.withValues(alpha: 0.92)
                      : const Color(0xFF1C1C1E).withValues(alpha: 0.90),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: widget.isDark
                        ? Colors.black.withValues(alpha: 0.06)
                        : Colors.white.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: widget.isDark ? 0.08 : 0.3),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MahekLoader(size: 40, showBranding: false),
                    const SizedBox(height: 20),
                    Text(
                      widget.message,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: widget.isDark
                            ? const Color(0xFF1C1C1E).withValues(alpha: 0.8)
                            : Colors.white.withValues(alpha: 0.9),
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

enum ToastPosition {
  top,
  bottom,
}
