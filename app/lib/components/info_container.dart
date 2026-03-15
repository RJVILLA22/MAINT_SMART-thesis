import 'package:app/utils/block_sizes.dart';
import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class InfoContainer extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? iconColor;

  const InfoContainer({
    Key? key,
    required this.text,
    this.icon,
    this.backgroundColor,
    this.textColor,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppSizes appSizes = AppSizes();
    appSizes.initSizes(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(AppSizes.blockSizeVertical * 2),
      margin: EdgeInsets.only(
        left: AppSizes.blockSizeHorizontal * 5,
        right: AppSizes.blockSizeHorizontal * 5,
        top: AppSizes.blockSizeVertical * 2, // Reduced from 3
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFE8E6FF), // Light purple/blue
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(shape: BoxShape.circle),
            child: Icon(
              icon ?? Icons.info_outline,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
