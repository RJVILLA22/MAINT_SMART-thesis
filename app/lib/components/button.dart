import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class ActionButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? textColor;
  final Color? iconColor;
  final double? fontSize;
  final double? height;
  final double? width;
  final double? borderRadius;
  final bool isFullWidth;
  final FontWeight? fontWeight;

  const ActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconPath,
    this.icon,
    this.backgroundColor,
    this.borderColor,
    this.textColor,
    this.iconColor,
    this.fontSize,
    this.height,
    this.width,
    this.borderRadius,
    this.isFullWidth = false,
    this.fontWeight,
  });

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            isFullWidth
                ? double.infinity
                : (width ?? AppSizes.blockSizeHorizontal * 85),
        height: height ?? AppSizes.blockSizeVertical * 7,
        decoration: BoxDecoration(
          color: backgroundColor ?? maintColor.primaryComplement,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSizes.blockSizeHorizontal * 4,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Section (either asset or IconData)
            if (iconPath != null || icon != null) ...[
              if (iconPath != null)
                Image.asset(
                  iconPath!,
                  width: AppSizes.blockSizeHorizontal * 8,
                  height: AppSizes.blockSizeHorizontal * 8,
                  color: iconColor,
                  fit: BoxFit.contain,
                )
              else if (icon != null)
                Icon(
                  icon!,
                  size: AppSizes.blockSizeHorizontal * 6,
                  color: iconColor ?? const Color.fromARGB(255, 13, 20, 119),
                ),
              SizedBox(width: AppSizes.blockSizeHorizontal * 3),
            ],
            // Text Section
            Flexible(
              child: Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: fontSize ?? AppSizes.blockSizeHorizontal * 4.5,
                  fontWeight: fontWeight ?? FontWeight.w600,
                  color: textColor ?? maintColor.blackText,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Predefined style variants for common use cases
class PrimaryActionButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isFullWidth;

  const PrimaryActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconPath,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      text: text,
      iconPath: iconPath,
      icon: icon,
      onTap: onTap,
      backgroundColor: maintColor.primary,
      borderColor: maintColor.primary,
      textColor: Colors.white,
      iconColor: Colors.white,
      isFullWidth: isFullWidth,
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isFullWidth;

  const SecondaryActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconPath,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      text: text,
      iconPath: iconPath,
      icon: icon,
      onTap: onTap,
      backgroundColor: Colors.white,
      borderColor: maintColor.primary,
      textColor: maintColor.primary,
      iconColor: maintColor.primary,
      isFullWidth: isFullWidth,
    );
  }
}

class OutlineActionButton extends StatelessWidget {
  final String text;
  final String? iconPath;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isFullWidth;

  const OutlineActionButton({
    super.key,
    required this.text,
    required this.onTap,
    this.iconPath,
    this.icon,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return ActionButton(
      text: text,
      iconPath: iconPath,
      icon: icon,
      onTap: onTap,
      backgroundColor: Colors.transparent,
      borderColor: maintColor.grayText,
      textColor: maintColor.grayText,
      iconColor: maintColor.grayText,
      isFullWidth: isFullWidth,
    );
  }
}
