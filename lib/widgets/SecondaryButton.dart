/// @Author: Raziqrr rzqrdzn03@gmail.com
/// @Date: 2024-08-06 23:29:12
/// @LastEditors: Raziqrr rzqrdzn03@gmail.com
/// @LastEditTime: 2024-08-06 23:30:51
/// @FilePath: lib/widgets/SecondaryButton.dart
/// @Description: 这是默认设置,可以在设置》工具》File Description中进行配置

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key, required this.onPressed, required this.text});
  final void Function() onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(
        text,
        style: GoogleFonts.montserrat(color: CupertinoColors.systemGreen),
      ),
      style: OutlinedButton.styleFrom(
          side: BorderSide(color: CupertinoColors.systemGreen)),
    );
  }
}
