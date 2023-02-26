import 'package:autocomplete/src/shared/utils/decoration.dart';
import 'package:flutter/material.dart';

class AppBox extends StatelessWidget {
  const AppBox({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * .75,
      decoration: appSecondaryBoxDecoration,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }
}
