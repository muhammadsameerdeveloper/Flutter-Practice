import 'package:flutter/material.dart';

class ElementBox extends StatelessWidget {
  final String symbol;
  const ElementBox({super.key, required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 50,
      margin: EdgeInsets.all(2),
      color: Colors.blue.shade100,
      child: Center(
        child: Text(
          symbol,
          style: const TextStyle(fontSize: 20, color: Colors.blue),
        ),
      ),
    );
  }
}
