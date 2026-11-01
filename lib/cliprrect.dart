import 'package:flutter/material.dart';

class CliprrectView extends StatefulWidget {
  const CliprrectView({super.key});

  @override
  State<CliprrectView> createState() => _CliprrectViewState();
}

class _CliprrectViewState extends State<CliprrectView> {
  int selectedIndex = 0;
  bool isFavorite = false;
  bool showDetails = false;

  final List<Map<String, dynamic>> places = [
    {
      "name": "Beautiful Mountains",
      "location": "Switzerland",
      "rating": "4.9",
      "price": "\$250",
      "reviews": "320 Reviews",
      "image": "assets/images/schwarzwaldandi-cat-5665915.jpg",
    },
    {
      "name": "Amazing Nature",
      "location": "Germany",
      "rating": "4.8",
      "price": "\$180",
      "reviews": "250 Reviews",
      "image": "assets/images/schwarzwaldandi-cat-5665915.jpg",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final place = places[selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xffF2F4F8),

      appBar: AppBar(
        title: const Text(
          "Explore Places",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(20),

        children: [
          // Heading
          const Text(
            "Discover",
            style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 5),

          const Text(
            "Explore beautiful places around the world",
            style: TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 25),

          // Main Card
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: showDetails ? 540 : 490,
            width: double.infinity,

            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),

              child: Stack(
                fit: StackFit.expand,

                children: [
                  // Background Image
                  Image.asset(place["image"], fit: BoxFit.cover),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                          Colors.black.withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),

                  // Top Location
                  Positioned(
                    top: 20,
                    left: 20,

                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                        color: Colors.white.withOpacity(0.8),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 18,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              place["location"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Favorite Animation
                  Positioned(
                    top: 15,
                    right: 15,

                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isFavorite = !isFavorite;
                        });
                      },

                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 48,
                        width: 48,

                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                            ),
                          ],
                        ),

                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_border,
                          color: isFavorite ? Colors.red : Colors.black,
                          size: 25,
                        ),
                      ),
                    ),
                  ),

                  // Bottom Content
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 20,

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        // Rating
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),

                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),

                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 18,
                              ),

                              const SizedBox(width: 5),

                              Text(
                                place["rating"],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(width: 5),

                              Text(
                                place["reviews"],
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Title
                        Text(
                          place["name"],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          "Experience the beauty of nature "
                          "and explore amazing destinations.",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),

                        const SizedBox(height: 15),

                        // Price and Explore
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,

                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Starting from",
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),

                                Text(
                                  place["price"],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  showDetails = !showDetails;
                                });
                              },

                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),

                              child: Row(
                                children: [
                                  Text(showDetails ? "Show Less" : "Explore"),

                                  const SizedBox(width: 5),

                                  const Icon(Icons.arrow_forward, size: 18),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Animated Extra Details
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 400),

                          firstChild: const SizedBox(width: double.infinity),

                          secondChild: Container(
                            margin: const EdgeInsets.only(top: 15),
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(15),
                            ),

                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,

                              children: [
                                Icon(Icons.wifi, color: Colors.white),
                                Icon(Icons.pool, color: Colors.white),
                                Icon(Icons.restaurant, color: Colors.white),
                                Icon(Icons.hotel, color: Colors.white),
                              ],
                            ),
                          ),

                          crossFadeState: showDetails
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          // Choose Destination
          const Text(
            "Popular Destinations",
            style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 15),

          // Destination Selector
          SizedBox(
            height: 55,

            child: Row(
              children: List.generate(places.length, (index) {
                bool isSelected = selectedIndex == index;

                return Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedIndex = index;
                        isFavorite = false;
                        showDetails = false;
                      });
                    },

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 10),

                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,

                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Center(
                        child: Text(
                          places[index]["location"],

                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
