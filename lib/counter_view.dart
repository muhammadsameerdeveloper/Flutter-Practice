import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CounterView extends StatefulWidget {
  const CounterView({super.key});

  @override
  State<CounterView> createState() => _CounterViewState();
}

class _CounterViewState extends State<CounterView>
    with SingleTickerProviderStateMixin {
  // COUNTER VARIABLES

  int counter = 0;
  int stepValue = 1;
  int totalClicks = 0;
  int maxLimit = 500;

  bool isDarkMode = false;
  bool isAutoRunning = false;

  Timer? autoTimer;

  // UNDO REDO

  List<int> undoStack = [];
  List<int> redoStack = [];

  // HISTORY

  List<Map<String, dynamic>> history = [];

  // ANIMATION

  late AnimationController animationController;
  late Animation<double> scaleAnimation;

  // COLORS

  Color get primaryColor => const Color(0xff536DFE);

  Color get backgroundColor =>
      isDarkMode ? const Color(0xff101827) : const Color(0xffF3F5FA);

  Color get cardColor => isDarkMode ? const Color(0xff1E293B) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xff172033);

  Color get counterColor {
    if (counter == 0) return Colors.grey;
    if (counter >= maxLimit * 0.8) return Colors.green;
    if (counter >= maxLimit * 0.4) return Colors.orange;
    return primaryColor;
  }

  double get progress => counter / maxLimit;

  // INITIALIZATION

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
      lowerBound: 0.0,
      upperBound: 0.15,
    );

    scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: animationController, curve: Curves.easeOut),
    );
  }

  // DISPOSE

  @override
  void dispose() {
    autoTimer?.cancel();
    animationController.dispose();
    super.dispose();
  }

  // SNACKBAR

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 1),
      ),
    );
  }

  // ADD HISTORY

  void addHistory(String action) {
    history.insert(0, {
      "action": action,
      "value": counter,
      "time": TimeOfDay.now().format(context),
    });

    if (history.length > 30) {
      history.removeLast();
    }
  }

  // MAIN COUNTER FUNCTION

  void changeCounter(int newValue, String action) {
    if (newValue < 0 || newValue > maxLimit) {
      showMessage("Counter limit reached!");
      return;
    }

    setState(() {
      undoStack.add(counter);

      if (undoStack.length > 50) {
        undoStack.removeAt(0);
      }

      redoStack.clear();

      counter = newValue;
      totalClicks++;

      addHistory(action);
    });

    animationController.forward().then((_) {
      if (mounted) {
        animationController.reverse();
      }
    });

    HapticFeedback.lightImpact();
  }

  // INCREMENT

  void increment() {
    changeCounter(counter + stepValue, "Increment +$stepValue");
  }

  // DECREMENT

  void decrement() {
    changeCounter(counter - stepValue, "Decrement -$stepValue");
  }

  // UNDO

  void undo() {
    if (undoStack.isEmpty) {
      showMessage("Nothing to undo!");
      return;
    }

    setState(() {
      redoStack.add(counter);

      counter = undoStack.removeLast();

      addHistory("Undo Operation");
    });

    HapticFeedback.mediumImpact();
  }

  // REDO

  void redo() {
    if (redoStack.isEmpty) {
      showMessage("Nothing to redo!");
      return;
    }

    setState(() {
      undoStack.add(counter);

      counter = redoStack.removeLast();

      addHistory("Redo Operation");
    });

    HapticFeedback.mediumImpact();
  }

  // AUTO COUNTER START

  void startAutoCounter() {
    if (counter >= maxLimit) {
      showMessage("Maximum limit reached!");
      return;
    }

    if (isAutoRunning) return;

    setState(() {
      isAutoRunning = true;
    });

    autoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (counter + stepValue > maxLimit) {
        stopAutoCounter();
        showMessage("Maximum limit reached!");
        return;
      }

      changeCounter(counter + stepValue, "Auto Increment");
    });
  }

  // STOP AUTO COUNTER

  void stopAutoCounter() {
    autoTimer?.cancel();

    setState(() {
      isAutoRunning = false;
    });
  }

  // RESET

  void resetCounter() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,

          title: Text("Reset Counter?", style: TextStyle(color: textColor)),

          content: Text(
            "Do you want to reset all counter progress?",
            style: TextStyle(color: textColor),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                stopAutoCounter();

                if (counter != 0) {
                  changeCounter(0, "Counter Reset");
                }

                setState(() {
                  redoStack.clear();
                });
              },
              child: const Text("Reset"),
            ),
          ],
        );
      },
    );
  }

  // CUSTOM VALUE

  void customValue() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,

          title: Text("Set Custom Value", style: TextStyle(color: textColor)),

          content: TextField(
            controller: controller,

            keyboardType: TextInputType.number,

            autofocus: true,

            decoration: const InputDecoration(
              hintText: "Enter value (0 - 500)",
              border: OutlineInputBorder(),
            ),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.dispose();
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);

                if (value == null || value < 0 || value > maxLimit) {
                  showMessage("Enter a valid number!");
                  return;
                }

                Navigator.pop(dialogContext);

                controller.dispose();

                stopAutoCounter();

                changeCounter(value, "Custom Value");
              },
              child: const Text("Set Value"),
            ),
          ],
        );
      },
    );
  }

  // CHANGE TARGET

  void changeTarget() {
    final controller = TextEditingController(text: "$maxLimit");

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Change Target"),

          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter target"),
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                controller.dispose();
              },
              child: const Text("Cancel"),
            ),

            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);

                if (value == null || value <= 0 || value < counter) {
                  showMessage("Target must be greater than current value!");
                  return;
                }

                setState(() {
                  maxLimit = value;
                });

                Navigator.pop(dialogContext);

                controller.dispose();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  // COPY VALUE

  void copyValue() {
    Clipboard.setData(ClipboardData(text: "$counter"));

    showMessage("Counter value copied!");
  }

  // STATISTICS CARD

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
        ),

        child: Column(
          children: [
            Icon(icon, color: color, size: 28),

            const SizedBox(height: 10),

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
      ),
    );
  }

  // ACTION BUTTON

  Widget actionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: SizedBox(
        height: 55,

        child: ElevatedButton.icon(
          onPressed: onTap,

          icon: Icon(icon),

          label: Text(title),

          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
          ),
        ),
      ),
    );
  }

  // BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode ? ThemeData.dark() : ThemeData.light(),

      child: Scaffold(
        backgroundColor: backgroundColor,

        appBar: AppBar(
          title: const Text(
            "PRO COUNTER",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          centerTitle: true,

          backgroundColor: primaryColor,

          foregroundColor: Colors.white,

          actions: [
            IconButton(onPressed: copyValue, icon: const Icon(Icons.copy)),

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
                const Icon(
                  Icons.speed_rounded,
                  size: 55,
                  color: Color(0xff536DFE),
                ),

                const SizedBox(height: 8),

                Text(
                  "Advanced Counter System",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  "Manage your counting professionally",
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
                        color: Colors.black.withOpacity(0.07),
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
                                value: progress.clamp(0.0, 1.0),

                                strokeWidth: 14,

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
                                ScaleTransition(
                                  scale: scaleAnimation,

                                  child: Text(
                                    "$counter",
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
                            : counter >= maxLimit
                            ? "Target Completed!"
                            : "Counter is Active",

                        style: TextStyle(
                          color: counterColor,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        "${(progress * 100).toStringAsFixed(1)}% Completed",
                        style: TextStyle(color: textColor.withOpacity(0.6)),
                      ),

                      const SizedBox(height: 15),

                      // TARGET BUTTON
                      TextButton.icon(
                        onPressed: changeTarget,
                        icon: const Icon(Icons.flag),
                        label: const Text("Change Target"),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // STATISTICS
                Row(
                  children: [
                    statCard(
                      "Total Clicks",
                      "$totalClicks",
                      Icons.touch_app,
                      Colors.blue,
                    ),

                    const SizedBox(width: 12),

                    statCard(
                      "Remaining",
                      "${maxLimit - counter}",
                      Icons.hourglass_bottom,
                      Colors.orange,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    statCard(
                      "Undo Steps",
                      "${undoStack.length}",
                      Icons.undo,
                      Colors.purple,
                    ),

                    const SizedBox(width: 12),

                    statCard(
                      "Redo Steps",
                      "${redoStack.length}",
                      Icons.redo,
                      Colors.green,
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // STEP VALUE
                Text(
                  "Select Step Value",
                  style: TextStyle(
                    color: textColor,
                    fontSize: 19,
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

                // INCREMENT / DECREMENT
                Row(
                  children: [
                    actionButton(
                      "Decrease",
                      Icons.remove,
                      Colors.redAccent,
                      decrement,
                    ),

                    const SizedBox(width: 12),

                    actionButton(
                      "Increase",
                      Icons.add,
                      primaryColor,
                      increment,
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // UNDO / REDO
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

                const SizedBox(height: 15),

                // AUTO COUNTER
                Container(
                  padding: const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(18),
                  ),

                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(Icons.autorenew, color: primaryColor, size: 28),

                          const SizedBox(width: 10),

                          Expanded(
                            child: Text(
                              "Auto Counter",
                              style: TextStyle(
                                color: textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          if (isAutoRunning)
                            const Icon(
                              Icons.circle,
                              color: Colors.green,
                              size: 12,
                            ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      SizedBox(
                        width: double.infinity,
                        height: 48,

                        child: ElevatedButton.icon(
                          onPressed: isAutoRunning
                              ? stopAutoCounter
                              : startAutoCounter,

                          icon: Icon(
                            isAutoRunning ? Icons.pause : Icons.play_arrow,
                          ),

                          label: Text(
                            isAutoRunning
                                ? "Pause Counter"
                                : "Start Auto Counter",
                          ),

                          style: ElevatedButton.styleFrom(
                            backgroundColor: isAutoRunning
                                ? Colors.orange
                                : Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

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
                      onPressed: () {
                        setState(() {
                          history.clear();
                        });
                      },
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
                  ...history.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),

                      padding: const EdgeInsets.all(15),

                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(15),
                      ),

                      child: Row(
                        children: [
                          Icon(Icons.history, color: primaryColor),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  item["action"],
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  item["time"],
                                  style: TextStyle(
                                    color: textColor.withOpacity(0.5),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Text(
                            "${item["value"]}",
                            style: TextStyle(
                              color: primaryColor,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),

                const SizedBox(height: 25),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
