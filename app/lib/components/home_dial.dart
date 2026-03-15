import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class FeatureButton extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;
  final Color? borderColor;
  final Color? backgroundColor;
  final Color? textColor;
  final double? iconSize;
  final double? fontSize;

  const FeatureButton({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
    this.borderColor,
    this.backgroundColor,
    this.textColor,
    this.iconSize,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: AppSizes.blockSizeHorizontal * 40, // Responsive width
        height: AppSizes.blockSizeVertical * 20, // Responsive height
        decoration: BoxDecoration(
          color: backgroundColor ?? maintColor.primary,
          borderRadius: BorderRadius.circular(AppSizes.blockSizeHorizontal * 4),
          border: Border.all(
            color: backgroundColor ?? maintColor.primary,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(1.0),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon Section
            Expanded(
              flex: 3,
              child: Padding(
                padding: EdgeInsets.all(AppSizes.blockSizeHorizontal * 2),
                child: Image.asset(
                  iconPath,
                  width: iconSize ?? AppSizes.blockSizeHorizontal * 30,
                  height: iconSize ?? AppSizes.blockSizeHorizontal * 30,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Text Section
            Expanded(
              flex: 1,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.blockSizeHorizontal * 1.5,
                ),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: fontSize ?? AppSizes.blockSizeHorizontal * 5,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.white,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
