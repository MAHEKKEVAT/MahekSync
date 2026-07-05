// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable, strict_top_level_inference

import 'dart:math';

import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  ANIMATED GRADIENT BORDER WRAPPER
//  Clean single border → sweep gradient on focus
//  Per-character gradient text on focus via RichText overlay
// ══════════════════════════════════════════════════════════════════════════════

const List<Color> kTextGradientColors = [
  AppThemeData.neonRed,
  AppThemeData.neonOrange,
  AppThemeData.neonYellow,
  AppThemeData.neonMint,
  AppThemeData.neonCyan,
  AppThemeData.neonTeal,
  AppThemeData.neonBlue,
  AppThemeData.neonPurple,
  AppThemeData.neonLavender,
  AppThemeData.neonPink,
];

class _AnimatedBorderField extends StatefulWidget {
  final Widget Function(FocusNode focusNode, bool isFocused) builder;
  final bool isDark;
  final bool isEnabled;
  final Color fillColor;
  final double borderRadius;

  const _AnimatedBorderField({
    required this.builder,
    required this.isDark,
    required this.isEnabled,
    required this.fillColor,
    this.borderRadius = 24,
  });

  @override
  State<_AnimatedBorderField> createState() => _AnimatedBorderFieldState();
}

class _AnimatedBorderFieldState extends State<_AnimatedBorderField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;
  bool _hasError = false;

  static final _borderGradientColors = [
    AppThemeData.primary50,
    AppThemeData.neonBlue,
    AppThemeData.neonTeal,
    AppThemeData.neonMint,
    AppThemeData.neonPurple,
    AppThemeData.primary50,
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (!mounted) return;
    final focused = _focusNode.hasFocus;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _isFocused = focused);
    });
    if (focused && widget.isEnabled) {
      _controller.repeat();
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  void setError(bool hasError) {
    if (_hasError != hasError) {
      setState(() => _hasError = hasError);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  Color get _normalBorderColor =>
      widget.isDark ? AppThemeData.grey8 : AppThemeData.grey4;

  @override
  Widget build(BuildContext context) {
    final r = widget.borderRadius;
    final showGradient = _isFocused && !_hasError && widget.isEnabled;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final child = widget.builder(_focusNode, _isFocused);
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            boxShadow: showGradient
                ? [
                    BoxShadow(
                      color: AppThemeData.primary50.withValues(alpha: 0.18),
                      blurRadius: 12,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: Container(
            padding: const EdgeInsets.all(1.5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(r),
              gradient: showGradient
                  ? SweepGradient(
                      center: FractionalOffset.center,
                      transform: GradientRotation(_controller.value * 2 * pi),
                      colors: _borderGradientColors,
                    )
                  : null,
              color: showGradient ? null : _normalBorderColor,
            ),
            child: Container(
              decoration: BoxDecoration(
                color: widget.fillColor,
                borderRadius: BorderRadius.circular(r - 1.5),
              ),
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  TEXT FIELD WIDGET
// ══════════════════════════════════════════════════════════════════════════════

class TextFieldWidget extends StatelessWidget {
  final String? title;
  final String hintText;
  final validator;
  final String? icon;
  bool? obscureText = false;
  Color? color;
  Color? fillColor;
  final int? line;
  final TextEditingController controller;
  final Function()? onPress;
  final Widget? prefix;
  final Widget? suffix;
  final bool? enable;
  final bool? enabled;
  final bool? readOnly;
  final TextInputType? textInputType;
  final List<TextInputFormatter>? inputFormatters;

  TextFieldWidget({
    super.key,
    this.textInputType,
    this.validator,
    this.enable,
    this.icon,
    this.prefix,
    this.suffix,
    this.obscureText,
    this.title,
    required this.hintText,
    required this.controller,
    this.onPress,
    this.enabled,
    this.readOnly,
    this.color,
    this.fillColor,
    this.line,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final r = 24.0;
    final fieldFill = fillColor ?? (isDark ? AppThemeData.grey9 : AppThemeData.grey2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextCustom(
              title: title!.tr,
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: isDark ? AppThemeData.grey4 : AppThemeData.grey8,
            ),
          ),
        _AnimatedBorderField(
          isDark: isDark,
          isEnabled: enabled ?? true,
          fillColor: fieldFill,
          borderRadius: r,
          builder: (focusNode, isFocused) => TextFormField(
            focusNode: focusNode,
            validator: validator ?? (value) => value != null && value.isNotEmpty ? null : 'This field required'.tr,
            keyboardType: textInputType ?? TextInputType.text,
            inputFormatters: inputFormatters,
            textCapitalization: TextCapitalization.sentences,
            controller: controller,
            textAlign: TextAlign.start,
            enabled: enabled,
            obscureText: obscureText ?? false,
            readOnly: readOnly ?? false,
            maxLines: line ?? 1,
            textAlignVertical: TextAlignVertical.center,
            cursorColor: AppThemeData.primary50,
            onTap: onPress != null ? () => onPress!() : null,
            style: TextStyle(
              foreground: isFocused
                  ? (Paint()
                    ..shader = const LinearGradient(
                      colors: kTextGradientColors,
                      tileMode: TileMode.repeated,
                    ).createShader(const Rect.fromLTWH(0, 0, 120, 30)))
                  : null,
              color: isFocused ? null : (isDark ? AppThemeData.grey1 : AppThemeData.grey10),
              fontFamily: isFocused ? FontFamily.bold : FontFamily.regular,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
              isDense: true,
              filled: false,
              enabled: enable ?? true,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              prefixIcon: prefix != null
                  ? Padding(padding: const EdgeInsets.only(left: 12, right: 8), child: prefix)
                  : null,
              suffixIcon: suffix != null
                  ? Padding(padding: const EdgeInsets.all(12), child: suffix)
                  : null,
              hintText: hintText.tr,
              hintStyle: TextStyle(
                fontSize: 16,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
