// ignore_for_file: sized_box_for_whitespace

import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final bool? obscureText;
  final String? Function(String?)? validator;
  final Widget? suffixIcon;
  final TextStyle? labelStyle;
  final InputDecoration? decoration;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.obscureText,
    this.validator,
    this.suffixIcon,
    this.labelStyle,
    this.decoration,
    IconButton? icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      child: TextFormField(
        cursorColor: Colors.black,
        controller: controller,
        obscureText: obscureText ?? false,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          labelText: labelText,
          focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black)),
          labelStyle: const TextStyle(color: Colors.black),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),
    );
  }
}
