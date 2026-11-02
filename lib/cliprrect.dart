import 'package:flutter/material.dart';

class CliprrectView extends StatefulWidget {
  const CliprrectView({super.key});

  @override
  State<CliprrectView> createState() => _CliprrectViewState();
}

class _CliprrectViewState extends State<CliprrectView> {
  late PageController pageController;

  int selectedIndex = 0;

  final Set<int> favoritePlaces = {};

  final List<Map<String, dynamic>> places = [
    {
      "name": "Beautiful Mountains",
      "location": "Switzerland",
      "rating": "4.9",
      "price": "\$250",
      "reviews": "320 Reviews",
      "image": "assets/images/schwarzwaldandi-cat-5665915.jpg",
      "description":
          "Explore the beautiful mountains and enjoy "
          "the peaceful environment.",
      "days": "5 Days",
      "people": "2 Persons",
      "facilities": ["WiFi", "Hotel", "Food", "Pool"],
    },
    {
      "name": "Amazing Nature",
      "location": "Germany",
      "rating": "4.8",
      "price": "\$180",
      "reviews": "250 Reviews",
      "image": "assets/images/schwarzwaldandi-cat-5665915.jpg",
      "description":
          "Discover amazing nature and enjoy "
          "an unforgettable experience.",
      "days": "3 Days",
      "people": "2 Persons",
      "facilities": ["WiFi", "Hotel", "Food", "Pool"],
    },
  ];

  @override
  void initState() {
    super.initState();

    pageController = PageController(viewportFraction: 0.88);
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void changePage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOutCubic,
    );
  }

  void toggleFavorite(int index) {
    setState(() {
      if (favoritePlaces.contains(index)) {
        favoritePlaces.remove(index);
      } else {
        favoritePlaces.add(index);
      }
    });
  }

  void showPlaceDetails(Map<String, dynamic> place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          minChildSize: 0.35,
          maxChildSize: 0.9,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: ListView(
                controller: scrollController,
                padding: const EdgeInsets.all(22),
                children: [
                  Center(
                    child: Container(
                      height: 5,
                      width: 45,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text(
                    place["name"],
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    place["description"],
                    style: const TextStyle(color: Colors.grey, height: 1.6),
                  ),

                  const SizedBox(height: 25),

                  const Text(
                    "Available Facilities",
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 15),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: place["facilities"].length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 2.5,
                        ),
                    itemBuilder: (context, index) {
                      final facility = place["facilities"][index];

                      final icons = [
                        Icons.wifi,
                        Icons.hotel,
                        Icons.restaurant,
                        Icons.pool,
                      ];

                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icons[index], color: Colors.blue),
                            const SizedBox(width: 8),
                            Text(facility),
                          ],
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 25),

                  Row(
                    children: [
                      const Icon(Icons.calendar_month, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(place["days"]),
                      const Spacer(),
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 10),
                      Text(place["people"]),
                    ],
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);

                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text("Your trip is selected!"),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        "Book This Trip",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Advanced Sliver App Bar
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,

            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                "Explore World",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              centerTitle: true,
            ),

            actions: [
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notifications")),
                  );
                },
                icon: const Icon(Icons.notifications_none),
              ),
            ],
          ),

          // Main Heading
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 25, 20, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Discover",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 7),

                  Text(
                    "Explore beautiful places around the world",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),

          // Advanced PageView
          SliverToBoxAdapter(
            child: SizedBox(
              height: 510,

              child: PageView.builder(
                controller: pageController,
                itemCount: places.length,

                onPageChanged: (index) {
                  setState(() {
                    selectedIndex = index;
                  });
                },

                itemBuilder: (context, index) {
                  return AnimatedBuilder(
                    animation: pageController,

                    builder: (context, child) {
                      double page = 0;

                      if (pageController.hasClients &&
                          pageController.position.hasContentDimensions) {
                        page =
                            pageController.page ??
                            pageController.initialPage.toDouble();
                      }

                      double difference = (page - index).abs();

                      double scale = (1 - difference * 0.08)
                          .clamp(0.90, 1.0)
                          .toDouble();

                      return Transform.scale(scale: scale, child: child);
                    },

                    child: buildDestinationCard(index),
                  );
                },
              ),
            ),
          ),

          // Page Indicator
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,

                children: List.generate(places.length, (index) {
                  bool isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => changePage(index),

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 350),

                      margin: const EdgeInsets.symmetric(horizontal: 4),

                      height: 8,
                      width: isSelected ? 30 : 8,

                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          // Popular Destinations Heading
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Popular Destinations",
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
                  ),

                  Text(
                    "${places.length} Places",
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Destination List
          SliverToBoxAdapter(
            child: SizedBox(
              height: 65,

              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                scrollDirection: Axis.horizontal,
                itemCount: places.length,

                itemBuilder: (context, index) {
                  bool isSelected = selectedIndex == index;

                  return GestureDetector(
                    onTap: () => changePage(index),

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),

                      margin: const EdgeInsets.symmetric(horizontal: 5),

                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),

                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(18),

                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 10,
                          ),
                        ],
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
                  );
                },
              ),
            ),
          ),

          // Favorite Counter
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.favorite, color: Colors.red, size: 28),

                    const SizedBox(width: 12),

                    const Expanded(
                      child: Text(
                        "Your Favorite Places",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ),

                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),

                      child: Text(
                        "${favoritePlaces.length}",
                        key: ValueKey(favoritePlaces.length),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 25)),
        ],
      ),
    );
  }

  // Destination Card Widget

  Widget buildDestinationCard(int index) {
    final place = places[index];

    bool isFavorite = favoritePlaces.contains(index);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),

      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),

        child: Stack(
          fit: StackFit.expand,

          children: [
            // Hero Image
            Hero(
              tag: "destination_$index",

              child: Image.asset(place["image"], fit: BoxFit.cover),
            ),

            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,

                  colors: [
                    Colors.black.withOpacity(0.35),
                    Colors.transparent,
                    Colors.black.withOpacity(0.9),
                  ],
                ),
              ),
            ),

            // Location Badge
            Positioned(
              top: 20,
              left: 18,

              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),

                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),

                  color: Colors.white.withOpacity(0.85),

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
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Animated Favorite Button
            Positioned(
              top: 15,
              right: 15,

              child: GestureDetector(
                onTap: () => toggleFavorite(index),

                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),

                  height: 50,
                  width: 50,

                  decoration: BoxDecoration(
                    color: isFavorite ? Colors.red : Colors.white,
                    shape: BoxShape.circle,
                  ),

                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),

                    transitionBuilder: (child, animation) {
                      return ScaleTransition(scale: animation, child: child);
                    },

                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(isFavorite),
                      color: isFavorite ? Colors.white : Colors.red,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Card Content
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
                        const Icon(Icons.star, color: Colors.amber, size: 18),

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
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Destination Name
                  Text(
                    place["name"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    place["description"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 18),

                  // Price and Details Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          const Text(
                            "Starting From",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),

                          Text(
                            place["price"],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      ElevatedButton(
                        onPressed: () {
                          showPlaceDetails(place);
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,

                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 13,
                          ),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),

                        child: const Row(
                          children: [
                            Text(
                              "Explore",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),

                            SizedBox(width: 5),

                            Icon(Icons.arrow_forward, size: 17),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Booking Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),

                    child: const LinearProgressIndicator(
                      value: 0.7,
                      minHeight: 5,
                      backgroundColor: Colors.white30,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blueAccent,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
