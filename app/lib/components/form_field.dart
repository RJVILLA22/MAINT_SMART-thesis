import 'package:app/utils/color_constants.dart';
import 'package:flutter/material.dart';

class MaintFormField extends StatefulWidget {
  final Icon? icon;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const MaintFormField({
    super.key,
    this.icon,
    required this.controller,
    required this.hintText,
    required this.obscureText,
  });

  @override
  State<MaintFormField> createState() => _MaintFormFieldState();
}

class _MaintFormFieldState extends State<MaintFormField> {
  late bool _isObscured;

  @override
  void initState() {
    super.initState();
    _isObscured = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 20.0, top: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Label above the field
          Text(
            widget.hintText,
            style: TextStyle(
              color: maintColor.primaryDark,
              fontSize: 16,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 8),

          /// Text field container
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: widget.controller,
              obscureText: _isObscured,
              style: const TextStyle(fontSize: 14),
              decoration: InputDecoration(
                hintStyle: TextStyle(color: Colors.grey[500]),
                prefixIcon: widget.icon,
                suffixIcon:
                    widget.obscureText
                        ? IconButton(
                          icon: Icon(
                            _isObscured
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            color: maintColor.primaryDark.withOpacity(0.7),
                          ),
                          onPressed: () {
                            setState(() {
                              _isObscured = !_isObscured;
                            });
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: maintColor.primary, width: 2.0),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
