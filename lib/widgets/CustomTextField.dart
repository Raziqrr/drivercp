/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-05 21:57:24
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-07 21:31:43
/// @FilePath: lib/widgets/CustomTextField.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Customtextfield extends StatelessWidget {
  const Customtextfield(
      {super.key,
      this.keyboardType = TextInputType.text,
      required this.controller,
      this.obscureText = false,
      required this.inputFormatters,
      this.maxLines = 1,
      required this.hintText,
      this.suffixIcon = null,
      required this.errorText,
      required this.onChanged,
      this.readOnly = false,
      this.onTap = null});
  final TextInputType keyboardType;
  final TextEditingController controller;
  final bool obscureText;
  final List<TextInputFormatter> inputFormatters;
  final int maxLines;
  final String hintText;
  final Widget? suffixIcon;
  final String errorText;
  final void Function(String)? onChanged;
  final bool readOnly;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
      keyboardType: keyboardType,
      controller: controller,
      obscureText: obscureText,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      decoration: InputDecoration(
        errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.red,
              width: 3,
            )),
        focusedBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.blue,
              width: 3,
            )),
        enabledBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 3,
            )),
        border: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey,
              width: 3,
            )),
        errorText: errorText == "" ? null : errorText,
        hintText: hintText,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
