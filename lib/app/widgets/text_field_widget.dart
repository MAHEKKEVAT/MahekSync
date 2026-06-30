// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable, strict_top_level_inference

import 'dart:math';

import 'package:country_code_picker/country_code_picker.dart';
import 'package:maheksync/app/utils/app_colors.dart';
import 'package:maheksync/app/utils/dark_theme_provider.dart';
import 'package:maheksync/app/utils/font_family.dart';
import 'package:maheksync/app/utils/validate_mobile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:maheksync/app/widgets/text_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'global_widgets.dart';

// ══════════════════════════════════════════════════════════════════════════════
//  ANIMATED GRADIENT BORDER WRAPPER
//  Sweep-gradient border that "walks" around the field when focused
// ══════════════════════════════════════════════════════════════════════════════

class _AnimatedBorderField extends StatefulWidget {
  final Widget Function(FocusNode focusNode) builder;
  final bool isDark;
  final bool isEnabled;
  final Color fillColor;
  final double borderRadius;
  final double borderWidth;

  const _AnimatedBorderField({
    required this.builder,
    required this.isDark,
    required this.isEnabled,
    required this.fillColor,
    this.borderRadius = 24,
    this.borderWidth = 2.0,
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
    final bw = widget.borderWidth;
    final showGradient = _isFocused && !_hasError && widget.isEnabled;
    final child = widget.builder(_focusNode);

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(r),
            boxShadow: showGradient
                ? [
                    BoxShadow(
                      color: AppThemeData.primary50.withValues(alpha: 0.20),
                      blurRadius: 14,
                      spreadRadius: -1,
                    ),
                  ]
                : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(r),
            child: Container(
              padding: EdgeInsets.all(bw),
              decoration: BoxDecoration(
                gradient: showGradient
                    ? SweepGradient(
                        center: FractionalOffset.center,
                        transform: GradientRotation(_controller.value * 2 * pi),
                        colors: [
                          AppThemeData.primary50,
                          AppThemeData.neonBlue,
                          AppThemeData.neonTeal,
                          AppThemeData.neonMint,
                          AppThemeData.neonPurple,
                          AppThemeData.primary50,
                        ],
                      )
                    : null,
                border: showGradient
                    ? null
                    : Border.all(color: _normalBorderColor, width: 1),
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.fillColor,
                ),
                child: child,
              ),
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
    final bw = 2.0;
    final fieldFill = fillColor ?? (isDark ? AppThemeData.grey9 : AppThemeData.grey2);
    final normalBorder = isDark ? AppThemeData.grey8 : AppThemeData.grey4;

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
          borderWidth: bw,
          builder: (focusNode) => TextFormField(
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
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              fontFamily: FontFamily.regular,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
              isDense: true,
              filled: true,
              enabled: enable ?? true,
              fillColor: fieldFill,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  MOBILE NUMBER TEXT FIELD
// ══════════════════════════════════════════════════════════════════════════════

class MobileNumberTextField extends StatelessWidget {
  final String title;
  String countryCode = "";
  final ValueChanged<String> onCountryCodeChanged;
  final TextEditingController controller;
  final Function() onPress;
  final bool? enabled;
  final bool? readOnly;

  MobileNumberTextField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    required this.onPress,
    required this.title,
    this.enabled,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    final themeChange = Provider.of<DarkThemeProvider>(context);
    final isDark = themeChange.isDarkTheme();
    final r = 24.0;
    final bw = 2.0;
    final fieldFill = isDark ? AppThemeData.grey9 : AppThemeData.grey2;
    final normalBorder = isDark ? AppThemeData.grey8 : AppThemeData.grey4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextCustom(
            title: title.tr,
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
          borderWidth: bw,
          builder: (focusNode) => TextFormField(
            focusNode: focusNode,
            cursorColor: AppThemeData.primary50,
            validator: (value) => validateMobile(value, countryCode),
            keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.allow(RegExp("[0-9]")),
              PhoneNumberInputFormatter(mask: phoneMaskForCountryCode(countryCode), maxLength: phoneMaxLengthForCountryCode(countryCode)),
            ],
            textCapitalization: TextCapitalization.sentences,
            controller: controller,
            textAlign: TextAlign.start,
            readOnly: readOnly ?? false,
            style: TextStyle(
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              fontFamily: FontFamily.regular,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
              isDense: true,
              filled: true,
              enabled: enabled ?? true,
              fillColor: fieldFill,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              prefixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CountryCodePicker(
                    searchStyle: TextStyle(color: isDark ? AppThemeData.grey2 : AppThemeData.grey10, fontFamily: FontFamily.regular),
                    showFlag: true,
                    onChanged: (value) {
                      final code = value.dialCode.toString();
                      onCountryCodeChanged(code);
                    },
                    dialogTextStyle: TextStyle(fontFamily: FontFamily.regular, color: isDark ? AppThemeData.grey2 : AppThemeData.grey10),
                    dialogBackgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
                    initialSelection: countryCode,
                    comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                    backgroundColor: isDark ? AppThemeData.grey10 : AppThemeData.grey2,
                    flagDecoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2))),
                    textStyle: TextStyle(fontSize: 15, color: isDark ? AppThemeData.grey4 : AppThemeData.grey8, fontFamily: FontFamily.regular),
                  ),
                  Text(
                    "|",
                    style: TextStyle(fontSize: 16, fontFamily: FontFamily.light, color: isDark ? AppThemeData.grey7 : AppThemeData.grey4),
                  ),
                  spaceW(width: 16),
                ],
              ),
              hintText: "Enter Mobile Number".tr,
              hintStyle: TextStyle(
                fontSize: 16,
                fontFamily: FontFamily.regular,
                color: isDark ? AppThemeData.grey6 : AppThemeData.grey5,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
//  CUSTOM FIELD TEXT FIELD
// ══════════════════════════════════════════════════════════════════════════════

class CustomFieldTextField extends StatelessWidget {
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

  CustomFieldTextField({
    super.key,
    this.textInputType,
    this.validator,
    this.enable,
    this.icon,
    this.prefix,
    this.suffix,
    this.obscureText,
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
    final bw = 2.0;
    final fieldFill = fillColor ?? (isDark ? AppThemeData.grey9 : AppThemeData.grey2);
    final normalBorder = isDark ? AppThemeData.grey8 : AppThemeData.grey4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _AnimatedBorderField(
          isDark: isDark,
          isEnabled: enabled ?? true,
          fillColor: fieldFill,
          borderRadius: r,
          borderWidth: bw,
          builder: (focusNode) => TextFormField(
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
              color: isDark ? AppThemeData.grey1 : AppThemeData.grey10,
              fontFamily: FontFamily.regular,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
              isDense: true,
              filled: true,
              enabled: enable ?? true,
              fillColor: fieldFill,
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
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(r),
                borderSide: BorderSide(color: normalBorder, width: 1),
              ),
              focusedBorder: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
