import 'package:flutter/material.dart';

void main() {
  runApp(
    const MaterialApp(debugShowCheckedModeBanner: false, home: LudoBoard()),
  );
}

class LudoBoard extends StatelessWidget {
  const LudoBoard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AspectRatio(
          aspectRatio: 1,
          child: Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    _home(Colors.red),
                    _path(Colors.blue),
                    _home(Colors.blue),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _path(Colors.red),
                    _center(),
                    _path(Colors.orange),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    _home(Colors.green),
                    _path(Colors.green),
                    _home(Colors.orange),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _home(Color color) {
    return Expanded(
      child: Container(
        color: color,
        margin: const EdgeInsets.all(1),
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: GridView.count(
              crossAxisCount: 2,
              padding: const EdgeInsets.all(20),
              children: List.generate(
                4,
                (_) => Center(
                  child: CircleAvatar(radius: 15, backgroundColor: color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _path(Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(1),
        color: Colors.white,
        child: Column(
          children: List.generate(
            6,
            (index) => Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: index == 2 || index == 3 ? color : Colors.white,
                  border: Border.all(color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _center() {
    return Expanded(
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            _triangle(Alignment.topCenter, Colors.red),
            _triangle(Alignment.centerRight, Colors.orange),
            _triangle(Alignment.bottomCenter, Colors.green),
            _triangle(Alignment.centerLeft, Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _triangle(Alignment alignment, Color color) {
    return Align(
      alignment: alignment,
      child: Container(width: 60, height: 60, color: color),
    );
  }
}
