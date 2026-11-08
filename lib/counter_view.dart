import 'package:flutter/material.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  int counter = 0;
  int stepValue = 1;

  final int maxLimit = 100;
  final int minLimit = 0;

  List<String> history = [];

  double get progress => counter / maxLimit;

  void increment() {
    if (counter + stepValue <= maxLimit) {
      setState(() {
        counter += stepValue;
        history.insert(0, "+ $stepValue  =  $counter");
      });
    } else {
      showMessage("Maximum limit reached!");
    }
  }

  void decrement() {
    if (counter - stepValue >= minLimit) {
      setState(() {
        counter -= stepValue;
        history.insert(0, "- $stepValue  =  $counter");
      });
    } else {
      showMessage("Minimum limit reached!");
    }
  }

  void reset() {
    setState(() {
      counter = 0;
      history.insert(0, "Counter Reset");
    });
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  Color get counterColor {
    if (counter == 0) return Colors.grey;
    if (counter >= 75) return Colors.green;
    if (counter >= 40) return Colors.orange;
    return Colors.blue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF3F5F9),

      appBar: AppBar(
        title: const Text(
          "Pro Counter",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xff2457D6),
        elevation: 0,
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxHeight < 650;
            final horizontalPadding = constraints.maxWidth < 400 ? 16.0 : 28.0;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 20,
              ),

              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - 40,
                ),

                child: Column(
                  children: [
                    const Icon(
                      Icons.analytics_rounded,
                      size: 55,
                      color: Color(0xff2457D6),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      "Smart Counter",
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const Text(
                      "Manage your numbers easily",
                      style: TextStyle(color: Colors.black54, fontSize: 14),
                    ),

                    SizedBox(height: isSmall ? 15 : 25),

                    // Counter Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(22),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.12),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),

                      child: Column(
                        children: [
                          const Text(
                            "CURRENT VALUE",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black45,
                              letterSpacing: 2,
                            ),
                          ),

                          const SizedBox(height: 15),

                          // Animated Number
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 350),
                            transitionBuilder: (child, animation) {
                              return ScaleTransition(
                                scale: animation,
                                child: FadeTransition(
                                  opacity: animation,
                                  child: child,
                                ),
                              );
                            },
                            child: Text(
                              "$counter",
                              key: ValueKey(counter),
                              style: TextStyle(
                                fontSize: constraints.maxWidth < 350 ? 65 : 85,
                                fontWeight: FontWeight.bold,
                                color: counterColor,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          Text(
                            counter == 0
                                ? "Waiting to Start"
                                : counter == maxLimit
                                ? "Maximum Reached"
                                : "Counter is Active",
                            style: TextStyle(
                              color: counterColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Progress Indicator
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Progress",
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 12,
                              backgroundColor: Colors.grey.shade200,
                              color: counterColor,
                            ),
                          ),

                          const SizedBox(height: 12),

                          Text(
                            "$counter / $maxLimit",
                            style: const TextStyle(color: Colors.black45),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmall ? 18 : 25),

                    // Step Selection
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Select Step Value",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 10,
                      children: [1, 2, 5, 10].map((value) {
                        final selected = stepValue == value;

                        return ChoiceChip(
                          label: Text("+/- $value"),
                          selected: selected,
                          onSelected: (selectedValue) {
                            setState(() {
                              stepValue = value;
                            });
                          },
                          selectedColor: const Color(0xff2457D6),
                          labelStyle: TextStyle(
                            color: selected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: isSmall ? 20 : 30),

                    // Increment / Decrement
                    Row(
                      children: [
                        Expanded(
                          child: actionButton(
                            title: "Decrease",
                            icon: Icons.remove,
                            color: Colors.redAccent,
                            onTap: decrement,
                          ),
                        ),

                        const SizedBox(width: 15),

                        Expanded(
                          child: actionButton(
                            title: "Increase",
                            icon: Icons.add,
                            color: const Color(0xff2457D6),
                            onTap: increment,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Reset Button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton.icon(
                        onPressed: reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text(
                          "Reset Counter",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xff2457D6),
                          side: const BorderSide(color: Color(0xff2457D6)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // History Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Recent Activity",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        TextButton(
                          onPressed: () {
                            setState(() {
                              history.clear();
                            });
                          },
                          child: const Text("Clear"),
                        ),
                      ],
                    ),

                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text(
                          "No activity yet",
                          style: TextStyle(color: Colors.black45),
                        ),
                      )
                    else
                      ...history
                          .take(5)
                          .map(
                            (item) => Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.history,
                                    color: Color(0xff2457D6),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    item,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                    const SizedBox(height: 15),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Custom Button
  Widget actionButton({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      height: 65,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 25),
        label: Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
