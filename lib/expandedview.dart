import 'package:flutter/material.dart';

class ExpandedView extends StatelessWidget {
  const ExpandedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Expanded Example")),
      body: Row(
        children: [
          Expanded(child: Container(height: 150, color: Colors.red)),
          Expanded(child: Container(height: 150, color: Colors.blue)),
          Expanded(child: Container(height: 150, color: Colors.green)),
        ],
      ),
    );
  }
}
