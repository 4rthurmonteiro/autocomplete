import 'package:autocomplete/src/shared/utils/colors.dart';
import 'package:flutter/material.dart';

class AppDivider extends StatelessWidget {
  const AppDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 10,
      color: appPrimaryColor,
      thickness: 2,
    );
  }
}
