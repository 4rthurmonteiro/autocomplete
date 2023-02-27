import 'package:autocomplete/src/shared/utils/colors.dart';
import 'package:flutter/material.dart';

class AppText extends StatelessWidget {
  const AppText({
    super.key,
    required this.text,
    this.color,
    this.fontWeight,
  });

  factory AppText.customColor({
    required String text,
    required Color color,
  }) =>
      AppText(
        text: text,
        color: color,
      );

  final String text;
  final Color? color;
  final FontWeight? fontWeight;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: color ?? appPrimaryColor,
        fontWeight: fontWeight,
      ),
    );
  }
}
