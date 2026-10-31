import 'package:flutter/material.dart';

class CliprrectView extends StatefulWidget {
  const CliprrectView({super.key});

  @override
  State<CliprrectView> createState() => _CliprrectViewState();
}

class _CliprrectViewState extends State<CliprrectView> {
  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Advanced ClipRRect"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: ClipRRect(
            borderRadius: BorderRadius.circular(30),

            child: SizedBox(
              height: 450,
              width: double.infinity,

              child: Stack(
                fit: StackFit.expand,

                children: [
                  // Background Image
                  Image.asset(
                    "assets/images/schwarzwaldandi-cat-5665915.jpg",
                    fit: BoxFit.cover,
                  ),

                  // Gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.4),
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),

                  // Top Location Badge
                  Positioned(
                    top: 20,
                    left: 20,

                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 10,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Row(
                        children: [
                          Icon(Icons.location_on, color: Colors.red, size: 18),

                          SizedBox(width: 5),

                          Text(
                            "Germany",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Favorite Button
                  Positioned(
                    top: 15,
                    right: 15,

                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },

                      child: CircleAvatar(
                        radius: 23,
                        backgroundColor: Colors.white,

                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: Colors.red,
                          size: 25,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Content
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Beautiful Cat",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Discover the beauty of nature "
                          "and amazing forest views.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 15),

                        // Rating Row
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 20,
                            ),

                            const SizedBox(width: 5),

                            const Text(
                              "4.9",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(width: 5),

                            const Text(
                              "(250 Reviews)",
                              style: TextStyle(color: Colors.white70),
                            ),

                            const Spacer(),

                            // Explore Button
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              onPressed: () {},

                              child: const Row(
                                children: [
                                  Text("Explore"),
                                  SizedBox(width: 5),
                                  Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
