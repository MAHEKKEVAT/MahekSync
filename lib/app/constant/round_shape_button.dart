import 'package:flutter/material.dart';

import '../utils/font_family.dart';

class RoundShapeButton extends StatelessWidget {
  final String title;
  final Color buttonColor;
  final Color buttonTextColor;
  final Color? borderColor;
  final VoidCallback onTap;
  final Size? size;
  final double? textSize;
  final double? borderRadius;
  final Widget? titleWidget;
  final double? width;
  final double? height;

  const RoundShapeButton({
    super.key,
    required this.title,
    required this.buttonColor,
    required this.buttonTextColor,
    this.borderColor,
    required this.onTap,
    this.size,
    this.textSize,
    this.borderRadius = 30,
    this.titleWidget,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? size?.width,
      height: height ?? size?.height,
      child: ElevatedButton(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.all<Color>(Colors.white),
          backgroundColor: WidgetStateProperty.all<Color>(buttonColor),
          elevation: WidgetStateProperty.all<double>(0),
          shape: WidgetStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(borderRadius ?? 30),
              side: BorderSide(color: borderColor ?? Colors.transparent, width: 1.5),
            ),
          ),
        ),
        onPressed: onTap,
        child: titleWidget ??
            Text(
              title,
              style: TextStyle(
                fontFamily: FontFamily.regular,
                fontSize: textSize ?? 16,
                fontWeight: FontWeight.w600,
                color: buttonTextColor,
              ),
            ),
      ),
    );
  }
}