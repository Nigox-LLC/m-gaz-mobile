import 'package:flutter/material.dart';

class SizeConfig {
  static double width = 0.0;
  static double height = 0.0;

  static void init(BuildContext context) {
    final size = MediaQuery.of(context).size;
    width = size.width;
    height = size.height;
  }
}

extension SizeExtension on int {
  SizedBox getH() => SizedBox(height: (this / 812) * SizeConfig.height);

  SizedBox getW() => SizedBox(width: (this / 375) * SizeConfig.width);

  double get h => (this / 812) * SizeConfig.height;

  double get w => (this / 375) * SizeConfig.width;
}
