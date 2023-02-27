import 'package:autocomplete/src/shared/utils/decoration.dart';
import 'package:flutter/material.dart';

class AppBox extends StatelessWidget {
  const AppBox({
    super.key,
    required this.child,
    this.width,
    this.boxDecoration,
  });

  final Widget child;
  final double? width;
  final BoxDecoration? boxDecoration;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? MediaQuery.of(context).size.width * .75,
      decoration: boxDecoration ?? appSecondaryBoxDecoration,
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
