import 'package:flutter/material.dart';

class StackView extends StatelessWidget {
  const StackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Container(height: 200, width: 200, color: Colors.blue),
            Container(height: 100, width: 100, color: Colors.red),
          ],
        ),
      ),
    );
  }
}
