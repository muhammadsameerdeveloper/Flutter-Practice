import 'package:flutter/material.dart';

class ExpandedView extends StatelessWidget {
  const ExpandedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text("Advanced Dashboard"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: Padding(
        padding: const EdgeInsets.all(15),

        child: Column(
          children: [
            // Top Dashboard
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 40,
                          ),
                          SizedBox(height: 10),
                          Text(
                            "Total Balance",
                            style: TextStyle(color: Colors.white),
                          ),
                          SizedBox(height: 5),
                          Text(
                            "\$12,500",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            color: Colors.white,
                            size: 35,
                          ),
                          SizedBox(height: 10),
                          Text("Orders", style: TextStyle(color: Colors.white)),
                          Text(
                            "25",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Middle Section
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  // Left Side
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Completed",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "18",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        Expanded(
                          child: Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.pending_actions,
                                  color: Colors.white,
                                  size: 35,
                                ),
                                SizedBox(height: 8),
                                Text(
                                  "Pending",
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  "07",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Side
                  Expanded(
                    flex: 2,
                    child: Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Weekly Progress",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text("Monday"),
                          const SizedBox(height: 5),
                          const LinearProgressIndicator(
                            value: 0.8,
                            minHeight: 8,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.blue,
                          ),

                          const SizedBox(height: 20),

                          const Text("Tuesday"),
                          const SizedBox(height: 5),
                          const LinearProgressIndicator(
                            value: 0.5,
                            minHeight: 8,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.orange,
                          ),

                          const SizedBox(height: 20),

                          const Text("Wednesday"),
                          const SizedBox(height: 5),
                          const LinearProgressIndicator(
                            value: 0.9,
                            minHeight: 8,
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            color: Colors.green,
                          ),

                          const Spacer(),

                          const Center(
                            child: Icon(
                              Icons.bar_chart,
                              size: 45,
                              color: Colors.blue,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 15),

            // Bottom Section
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.person, color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Text(
                            "Profile",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.settings, color: Colors.white, size: 30),
                          SizedBox(width: 10),
                          Text(
                            "Settings",
                            style: TextStyle(color: Colors.white, fontSize: 18),
                          ),
                        ],
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
