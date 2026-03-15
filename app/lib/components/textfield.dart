import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class MaintTextField extends StatelessWidget {
  final Icon? icon;
  final controller;
  final String hintText;
  final bool obscureText;

  const MaintTextField({
    super.key,
    this.icon,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hintText,
            style: TextStyle(
              color: maintColor.primaryDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 40,
            child: TextField(
              controller: controller,
              obscureText: obscureText,
              style: TextStyle(fontSize: 16),
              decoration: InputDecoration(
                filled: true, // Enables background color
                fillColor: maintColor.primaryComplement,
                prefixIcon: icon,
                prefixIconConstraints: BoxConstraints(
                  minWidth: 25, // Adjust to control icon width
                  minHeight: 35,
                ),
                border: UnderlineInputBorder(
                  // Bottom stroke only
                  borderSide: BorderSide(
                    color: maintColor.gradientPrimary,
                    width: 1.0,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  // Bottom stroke for focused state
                  borderSide: BorderSide(color: maintColor.primary, width: 2.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
