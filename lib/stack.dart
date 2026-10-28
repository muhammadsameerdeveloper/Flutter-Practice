import 'package:flutter/material.dart';

class StackView extends StatelessWidget {
  const StackView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Advanced Stack"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background Container
            Container(
              height: 300,
              width: 250,
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
            ),

            // Image
            Positioned(
              top: 10,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Image.network(
                  "https://picsum.photos/250/180",
                  height: 180,
                  width: 230,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Product Name
            const Positioned(
              left: 15,
              bottom: 55,
              child: Text(
                "Beautiful Product",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // Price
            const Positioned(
              left: 15,
              bottom: 20,
              child: Text(
                "\$250",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),

            // Favorite Icon
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite, color: Colors.red),
              ),
            ),

            // Offer Badge
            Positioned(
              top: 20,
              left: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  "SALE",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
