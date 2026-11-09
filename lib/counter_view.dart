import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView> {
  int counter = 0;
  int stepValue = 1;
  int totalClicks = 0;

  final int minLimit = 0;
  final int maxLimit = 500;

  bool isDarkMode = false;

  List<int> undoStack = [];
  List<int> redoStack = [];
  List<String> history = [];

  double get progress => counter / maxLimit;

  Color get primaryColor => const Color(0xff536DFE);

  Color get counterColor {
    if (counter == 0) return Colors.grey;
    if (counter >= 400) return Colors.green;
    if (counter >= 200) return Colors.orange;
    return primaryColor;
  }

  Color get backgroundColor =>
      isDarkMode ? const Color(0xff101827) : const Color(0xffF3F5FA);

  Color get cardColor => isDarkMode ? const Color(0xff1E293B) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xff172033);

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // Main Counter Function
  void changeCounter(int value, String action) {
    if (value < minLimit || value > maxLimit) {
      showMessage("Counter limit reached!");
      return;
    }

    setState(() {
      undoStack.add(counter);
      redoStack.clear();

      counter = value;
      totalClicks++;

      history.insert(0, "$action  |  $counter");
    });

    HapticFeedback.lightImpact();
  }

  // Increase
  void increment() {
    changeCounter(counter + stepValue, "Increased +$stepValue");
  }

  // Decrease
  void decrement() {
    changeCounter(counter - stepValue, "Decreased -$stepValue");
  }

  // Undo
  void undo() {
    if (undoStack.isEmpty) {
      showMessage("Nothing to undo!");
      return;
    }

    setState(() {
      redoStack.add(counter);
      counter = undoStack.removeLast();

      history.insert(0, "Undo  |  $counter");
    });

    HapticFeedback.lightImpact();
  }

  // Redo
  void redo() {
    if (redoStack.isEmpty) {
      showMessage("Nothing to redo!");
      return;
    }

    setState(() {
      undoStack.add(counter);
      counter = redoStack.removeLast();

      history.insert(0, "Redo  |  $counter");
    });

    HapticFeedback.lightImpact();
  }

  // Reset Confirmation
  void resetCounter() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Reset Counter?", style: TextStyle(color: textColor)),
          content: Text(
            "Are you sure you want to reset the counter?",
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                if (counter != 0) {
                  changeCounter(0, "Counter Reset");
                } else {
                  showMessage("Counter is already zero!");
                }
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  // Custom Value Dialog
  Future<void> customValue() async {
    final controller = TextEditingController();

    final value = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Set Custom Value", style: TextStyle(color: textColor)),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: "Enter number (0 - 500)",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final number = int.tryParse(controller.text);

                if (number == null) return;

                Navigator.pop(context, number);
              },
              child: const Text("Set Value"),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (value != null) {
      changeCounter(value, "Custom Value");
    }
  }

  // Clear History
  void clearHistory() {
    setState(() {
      history.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),
      child: Scaffold(
        backgroundColor: backgroundColor,

        // APP BAR
        appBar: AppBar(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          title: const Text(
            "Ultra Counter",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: () {
                setState(() {
                  isDarkMode = !isDarkMode;
                });
              },
              icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
            ),
          ],
        ),

        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // HEADER
                Icon(Icons.speed_rounded, size: 55, color: primaryColor),

                const SizedBox(height: 8),

                Text(
                  "Smart Counter System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 23,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Advanced Counter Management",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textColor.withOpacity(0.6)),
                ),

                const SizedBox(height: 25),

                // MAIN COUNTER CARD
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      Text(
                        "CURRENT VALUE",
                        style: TextStyle(
                          color: textColor.withOpacity(0.5),
                          letterSpacing: 2,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 25),

                      // CIRCULAR PROGRESS
                      SizedBox(
                        height: 210,
                        width: 210,

                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox.expand(
                              child: CircularProgressIndicator(
                                value: progress,
                                strokeWidth: 13,
                                backgroundColor: Colors.grey.shade300,
                                valueColor: AlwaysStoppedAnimation(
                                  counterColor,
                                ),
                                strokeCap: StrokeCap.round,
                              ),
                            ),

                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 400),
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
                                      color: counterColor,
                                      fontSize: 65,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),

                                Text(
                                  "OUT OF $maxLimit",
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        counter == 0
                            ? "Waiting to Start"
                            : counter == maxLimit
                            ? "Maximum Reached!"
                            : "Counter is Active",
                        style: TextStyle(
                          color: counterColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "${(progress * 100).toStringAsFixed(1)}% Completed",
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // STATISTICS
                Row(
                  children: [
                    Expanded(
                      child: statCard(
                        "Total Clicks",
                        "$totalClicks",
                        Icons.touch_app,
                        Colors.blue,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: statCard(
                        "Remaining",
                        "${maxLimit - counter}",
                        Icons.hourglass_bottom,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // STEP VALUE
                Text(
                  "Select Step Value",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [1, 2, 5, 10, 20, 50].map((value) {
                    final selected = stepValue == value;

                    return ChoiceChip(
                      label: Text("$value"),
                      selected: selected,

                      selectedColor: primaryColor,

                      labelStyle: TextStyle(
                        color: selected ? Colors.white : textColor,
                        fontWeight: FontWeight.bold,
                      ),

                      onSelected: (_) {
                        setState(() {
                          stepValue = value;
                        });
                      },
                    );
                  }).toList(),
                ),

                const SizedBox(height: 25),

                // INCREASE AND DECREASE
                Row(
                  children: [
                    Expanded(
                      child: actionButton(
                        "Decrease",
                        Icons.remove,
                        Colors.redAccent,
                        decrement,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: actionButton(
                        "Increase",
                        Icons.add,
                        primaryColor,
                        increment,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // UNDO AND REDO
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: undo,
                        icon: const Icon(Icons.undo),
                        label: const Text("Undo"),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: redo,
                        icon: const Icon(Icons.redo),
                        label: const Text("Redo"),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // CUSTOM VALUE
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: customValue,
                    icon: const Icon(Icons.edit),
                    label: const Text("Set Custom Value"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // RESET
                SizedBox(
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: resetCounter,
                    icon: const Icon(Icons.refresh),
                    label: const Text("Reset Counter"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 28),

                // HISTORY HEADER
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Activity History",
                      style: TextStyle(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    TextButton(
                      onPressed: clearHistory,
                      child: const Text("Clear All"),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // HISTORY LIST
                if (history.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(25),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      "No Activity Yet",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: textColor),
                    ),
                  )
                else
                  ...history.take(10).map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.history, color: primaryColor),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Text(
                              item,
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // STATISTICS CARD
  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              color: textColor,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          Text(
            title,
            style: TextStyle(color: textColor.withOpacity(0.6), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // CUSTOM ACTION BUTTON
  Widget actionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return SizedBox(
      height: 58,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}
