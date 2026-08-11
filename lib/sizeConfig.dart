import 'package:flutter/material.dart';

class SizeConfig {
  static late double width;
  static late double height;
  static init(BuildContext context) {
    width = MediaQuery.sizeOf(context).width;
    height = MediaQuery.sizeOf(context).height;
  }
}
