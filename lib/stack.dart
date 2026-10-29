import 'package:flutter/material.dart';

class StackView extends StatefulWidget {
  const StackView({super.key});

  @override
  State<StackView> createState() => _StackViewState();
}

class _StackViewState extends State<StackView> {
  bool isFavorite = false;
  bool isAddedToCart = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Advanced Product Card"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Container(
          height: 430,
          width: 300,
          margin: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),

          child: Stack(
            children: [
              // Product Image
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(25),
                ),
                child: Image.network(
                  "https://picsum.photos/400/300",
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),

              // Image Gradient
              Positioned(
                top: 130,
                left: 0,
                right: 0,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.5),
                      ],
                    ),
                  ),
                ),
              ),

              // Sale Badge
              Positioned(
                top: 15,
                left: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    "30% OFF",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Favorite Button
              Positioned(
                top: 12,
                right: 12,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: IconButton(
                    onPressed: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: Colors.red,
                    ),
                  ),
                ),
              ),

              // Image Label
              const Positioned(
                left: 15,
                top: 205,
                child: Text(
                  "TRENDING PRODUCT",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),

              // Product Details
              Positioned(
                left: 15,
                right: 15,
                top: 265,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Premium Headphones",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 20),
                        const Text(
                          " 4.8 (120 Reviews)",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        const Text(
                          "\$120",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "\$180",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade500,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),

                        const Spacer(),

                        // Add to Cart Button
                        SizedBox(
                          height: 42,
                          width: 105,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isAddedToCart = !isAddedToCart;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isAddedToCart
                                  ? Colors.green
                                  : Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.zero,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Icon(
                              isAddedToCart ? Icons.check : Icons.shopping_cart,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Floating New Badge
              Positioned(
                bottom: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "NEW",
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
      ),
    );
  }
}
