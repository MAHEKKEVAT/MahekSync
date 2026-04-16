// ignore_for_file: prefer_typing_uninitialized_variables, must_be_immutable, strict_top_level_inference

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
  final Function() onPress;
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
    required this.onPress,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /// Title (if provided) - shown above the text field
        if (title != null && title!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextCustom(
              title: title!.tr,
              fontSize: 14,
              fontFamily: FontFamily.medium,
              color: themeChange.isDarkTheme() ? AppThemeData.grey4 : AppThemeData.grey8,
            ),
          ),
        TextFormField(
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
          onTap: onPress,
          style: TextStyle(
            color: themeChange.isDarkTheme() ? AppThemeData.grey1 : AppThemeData.grey10,
            fontFamily: FontFamily.regular,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
            isDense: true,
            filled: true,
            enabled: enable ?? true,
            fillColor: fillColor ?? (themeChange.isDarkTheme() ? AppThemeData.grey9 : AppThemeData.grey2),
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
              color: themeChange.isDarkTheme() ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 12 to 24
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 12 to 24
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 12 to 24
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 12 to 24
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide:  BorderSide(color: AppThemeData.primary50, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// MobileNumberTextField also updated with more rounded corners
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: TextCustom(
            title: title.tr,
            fontSize: 14,
            fontFamily: FontFamily.medium,
            color: themeChange.isDarkTheme() ? AppThemeData.grey4 : AppThemeData.grey8,
          ),
        ),
        TextFormField(
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
            color: themeChange.isDarkTheme() ? AppThemeData.grey1 : AppThemeData.grey10,
            fontFamily: FontFamily.regular,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
            isDense: true,
            filled: true,
            enabled: enabled ?? true,
            fillColor: themeChange.isDarkTheme() ? AppThemeData.grey9 : AppThemeData.grey2,
            contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            prefixIcon: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CountryCodePicker(
                  searchStyle: TextStyle(color: themeChange.isDarkTheme() ? AppThemeData.grey2 : AppThemeData.grey10, fontFamily: FontFamily.regular),
                  showFlag: true,
                  onChanged: (value) {
                    final code = value.dialCode.toString();
                    onCountryCodeChanged(code);
                  },
                  dialogTextStyle: TextStyle(fontFamily: FontFamily.regular, color: themeChange.isDarkTheme() ? AppThemeData.grey2 : AppThemeData.grey10),
                  dialogBackgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2,
                  initialSelection: countryCode,
                  comparator: (a, b) => b.name!.compareTo(a.name.toString()),
                  backgroundColor: themeChange.isDarkTheme() ? AppThemeData.grey10 : AppThemeData.grey2,
                  flagDecoration: const BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(2))),
                  textStyle: TextStyle(fontSize: 15, color: themeChange.isDarkTheme() ? AppThemeData.grey4 : AppThemeData.grey8, fontFamily: FontFamily.regular),
                ),
                Text(
                  "|",
                  style: TextStyle(fontSize: 16, fontFamily: FontFamily.light, color: themeChange.isDarkTheme() ? AppThemeData.grey7 : AppThemeData.grey4),
                ),
                spaceW(width: 16),
              ],
            ),
            hintText: "Enter Mobile Number".tr,
            hintStyle: TextStyle(
              fontSize: 16,
              fontFamily: FontFamily.regular,
              color: themeChange.isDarkTheme() ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 10 to 24
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 10 to 24
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 10 to 24
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 10 to 24
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),  // ✅ Changed from 10 to 24
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide:  BorderSide(color: AppThemeData.primary50, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

// CustomFieldTextField remains the same or update if needed
class CustomFieldTextField extends StatelessWidget {
  final String hintText;
  final validator;
  final String? icon;
  bool? obscureText = false;
  Color? color;
  Color? fillColor;
  final int? line;
  final TextEditingController controller;
  final Function() onPress;
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
    required this.onPress,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
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
          onTap: onPress,
          style: TextStyle(
            color: themeChange.isDarkTheme() ? AppThemeData.grey1 : AppThemeData.grey10,
            fontFamily: FontFamily.regular,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            errorStyle: const TextStyle(fontFamily: FontFamily.regular, fontSize: 12),
            isDense: true,
            filled: true,
            enabled: enable ?? true,
            fillColor: fillColor ?? (themeChange.isDarkTheme() ? AppThemeData.grey9 : AppThemeData.grey2),
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
              color: themeChange.isDarkTheme() ? AppThemeData.grey6 : AppThemeData.grey5,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: const BorderSide(color: AppThemeData.danger300, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: themeChange.isDarkTheme() ? AppThemeData.grey8 : AppThemeData.grey4,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide:  BorderSide(color: AppThemeData.primary50, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}