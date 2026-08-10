import 'package:flutter/material.dart';
import 'package:practiceapp/playerBox.dart';

class LudoBorder extends StatelessWidget {
  const LudoBorder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          width: 600,
          height: 600,
          color: Colors.grey,
          child: Stack(
            children: [
              Positioned(left: 0, top: 0, child: Playerbox(color: Colors.red)),
              Positioned(
                right: 0,
                top: 0,
                child: Playerbox(color: Colors.blue),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
