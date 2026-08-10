import 'package:flutter/material.dart';

class Playerbox extends StatelessWidget {
  final Color color;
  const Playerbox({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(width: 230, height: 230, color: color);
  }
}
