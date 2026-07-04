import 'dart:async';
import 'dart:developer' as developer;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:maheksync/app/utils/font_family.dart';
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

  void showInfoToast(String message, {String? subtitle, ToastPosition position = ToastPosition.top}) {
    _showToast(
      title: message,
      subtitle: subtitle,
      accentColor: const Color(0xFF007AFF),
      icon: Icons.info_rounded,
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
//  APPLE-STYLE TOAST — Branding + message + subtitle + Now + close
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
      begin: const Offset(0.3, 0),
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

    final bgColor = isDark
        ? const Color(0xFFFAFAFA)
        : const Color(0xFF1C1C1E);
    final textColor = isDark ? const Color(0xFF1A1A1E) : Colors.white;
    final subtitleColor = isDark
        ? const Color(0xFF1A1A1E).withValues(alpha: 0.50)
        : Colors.white.withValues(alpha: 0.50);
    final closeBg = isDark
        ? Colors.black.withValues(alpha: 0.06)
        : Colors.white.withValues(alpha: 0.08);
    final closeIcon = isDark
        ? Colors.black.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.40);

    return Positioned(
      bottom: bottomPadding + 16,
      right: 16,
      child: SlideTransition(
        position: _slideAnim,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: GestureDetector(
            onTap: _dismiss,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 460),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: widget.accentColor.withValues(alpha: 0.25),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.accentColor.withValues(alpha: 0.10),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.04 : 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── Left accent bar ──
                  Container(
                    width: 3,
                    height: 36,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: widget.accentColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // ── Circle icon ──
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(widget.icon, color: widget.accentColor, size: 19),
                  ),
                  const SizedBox(width: 12),
                  // ── Branding + message + subtitle ──
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'MahekSync',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: FontFamily.bold,
                            color: widget.accentColor,
                            decoration: TextDecoration.none,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            fontFamily: FontFamily.semiBold,
                            color: textColor,
                            decoration: TextDecoration.none,
                            height: 1.3,
                          ),
                        ),
                        if (widget.subtitle != null && widget.subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            widget.subtitle!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w400,
                              fontFamily: FontFamily.regular,
                              color: subtitleColor,
                              decoration: TextDecoration.none,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // ── Now + close ──
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Now',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w400,
                          fontFamily: FontFamily.regular,
                          color: subtitleColor,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: _dismiss,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: closeBg,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close_rounded,
                            size: 13,
                            color: closeIcon,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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
