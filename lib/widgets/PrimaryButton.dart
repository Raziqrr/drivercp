/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-05 22:21:05
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-05 22:24:35
/// @FilePath: lib/widgets/PrimaryButton.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Primarybutton extends StatelessWidget {
  const Primarybutton({super.key, required this.onPressed, required this.text});
  final void Function()? onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.montserrat(
            color: Colors.white, fontWeight: FontWeight.bold),
      ),
      style: ElevatedButton.styleFrom(
          backgroundColor: CupertinoColors.systemGreen),
    );
  }
}
