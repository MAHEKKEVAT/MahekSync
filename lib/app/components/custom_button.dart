// ignore_for_file: depend_on_referenced_packages, deprecated_member_use

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/font_family.dart';
import '../widgets/global_widgets.dart';
import '../widgets/text_widget.dart';

class CustomButtonWidget extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? padding;
  final Color? buttonColor;
  final Color? borderColor;
  final Color? textColor;
  final String? title;
  final double? textSize;
  final double? radius;

  final Widget? titleWidget;

  final VoidCallback? onPress;

  const CustomButtonWidget({
    super.key,
    this.width,
    this.height,
    this.padding,
    this.buttonColor,
    this.borderColor,
    this.textSize,
    this.radius,

    required this.title,
    this.textColor,
    this.titleWidget,

    required this.onPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        width: width,
        height: height,
        decoration: buttonColor == null
            ? BoxDecoration(color: AppThemeData.primary50, borderRadius: BorderRadius.circular(radius ?? 8))
            : BoxDecoration(
          color: buttonColor,
          border: Border.all(color: borderColor ?? buttonColor!),
          borderRadius: BorderRadius.circular(radius ?? 8),
        ),
        child: Material(
          color: Colors.transparent,
          child: Center(
            child: Padding(
              padding: paddingEdgeInsets(vertical: 10, horizontal: 16),
              child: titleWidget ?? TextCustom(title: title!, fontSize: textSize ?? 16, fontFamily: FontFamily.regular, color: textColor ?? (AppThemeData.primaryWhite)),
            ),
          ),
        ),
      ),
    );
  }
}
