import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      home: const TodoView(),
    );
  }
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];

  String selectedFilter = "All";

  void addTask() {
    if (controller.text.trim().isEmpty) return;

    setState(() {
      tasks.add({
        "title": controller.text.trim(),
        "completed": false,
        "date": DateTime.now(),
      });

      controller.clear();
    });
  }

  void editTask(int index) {
    TextEditingController editController = TextEditingController(
      text: tasks[index]["title"],
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: TextField(
            controller: editController,
            decoration: const InputDecoration(
              hintText: "Enter new task",
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
                if (editController.text.trim().isNotEmpty) {
                  setState(() {
                    tasks[index]["title"] = editController.text.trim();
                  });
                }

                Navigator.pop(context);
                editController.dispose();
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Task Deleted Successfully")));
  }

  void toggleTask(int index, bool value) {
    setState(() {
      tasks[index]["completed"] = value;
    });
  }

  void clearCompleted() {
    setState(() {
      tasks.removeWhere((task) => task["completed"] == true);
    });
  }

  List<Map<String, dynamic>> get filteredTasks {
    String search = searchController.text.toLowerCase();

    return tasks.where((task) {
      bool matchesSearch = task["title"].toString().toLowerCase().contains(
        search,
      );

      bool matchesFilter =
          selectedFilter == "All" ||
          (selectedFilter == "Pending" && task["completed"] == false) ||
          (selectedFilter == "Completed" && task["completed"] == true);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task["completed"] == true).length;

  int get pendingTasks => totalTasks - completedTasks;

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = totalTasks == 0 ? 0 : completedTasks / totalTasks;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      appBar: AppBar(
        title: const Text(
          "My Todo App",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Manage Your Tasks",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text(
                    "Stay organized and productive!",
                    style: TextStyle(color: Colors.white70, fontSize: 15),
                  ),

                  const SizedBox(height: 20),

                  // Statistics
                  Row(
                    children: [
                      buildStatCard(
                        "Total",
                        totalTasks.toString(),
                        Icons.list_alt,
                      ),

                      const SizedBox(width: 10),

                      buildStatCard(
                        "Done",
                        completedTasks.toString(),
                        Icons.check_circle,
                      ),

                      const SizedBox(width: 10),

                      buildStatCard(
                        "Pending",
                        pendingTasks.toString(),
                        Icons.pending_actions,
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Progress
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Your Progress",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "${(progress * 100).toInt()}%",
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(20),
                    backgroundColor: Colors.white30,
                    valueColor: const AlwaysStoppedAnimation(
                      Colors.greenAccent,
                    ),
                  ),
                ],
              ),
            ),

            // Add Task Section
            Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller,

                      decoration: InputDecoration(
                        hintText: "Enter your task...",
                        filled: true,
                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),

                      onSubmitted: (value) => addTask(),
                    ),
                  ),

                  const SizedBox(width: 10),

                  SizedBox(
                    height: 55,
                    width: 55,

                    child: ElevatedButton(
                      onPressed: addTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),

                      child: const Icon(Icons.add, size: 30),
                    ),
                  ),
                ],
              ),
            ),

            // Search Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: TextField(
                controller: searchController,

                onChanged: (value) {
                  setState(() {});
                },

                decoration: InputDecoration(
                  hintText: "Search tasks...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,

                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                children: ["All", "Pending", "Completed"].map((filter) {
                  bool selected = selectedFilter == filter;

                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),

                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            selectedFilter = filter;
                          });
                        },

                        style: ElevatedButton.styleFrom(
                          backgroundColor: selected
                              ? Colors.blue
                              : Colors.white,

                          foregroundColor: selected
                              ? Colors.white
                              : Colors.black,

                          elevation: 0,
                        ),

                        child: Text(filter),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 10),

            // Task Heading
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: [
                  const Text(
                    "My Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  TextButton(
                    onPressed: completedTasks == 0 ? null : clearCompleted,

                    child: const Text("Clear Completed"),
                  ),
                ],
              ),
            ),

            // Task List
            Expanded(
              child: filteredTasks.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.task_alt,
                            size: 70,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 10),

                          Text(
                            tasks.isEmpty
                                ? "No Tasks Available"
                                : "No Matching Tasks",

                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),

                      itemCount: filteredTasks.length,

                      itemBuilder: (context, index) {
                        var task = filteredTasks[index];

                        int realIndex = tasks.indexOf(task);

                        bool isCompleted = task["completed"];

                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),

                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),

                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),

                            leading: Checkbox(
                              value: isCompleted,

                              activeColor: Colors.green,

                              onChanged: (value) {
                                toggleTask(realIndex, value ?? false);
                              },
                            ),

                            title: Text(
                              task["title"],

                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,

                                decoration: isCompleted
                                    ? TextDecoration.lineThrough
                                    : TextDecoration.none,

                                color: isCompleted ? Colors.grey : Colors.black,
                              ),
                            ),

                            subtitle: Text(
                              "${task["date"].hour}:${task["date"].minute.toString().padLeft(2, '0')}",
                              style: const TextStyle(color: Colors.grey),
                            ),

                            trailing: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == "edit") {
                                  editTask(realIndex);
                                }

                                if (value == "delete") {
                                  deleteTask(realIndex);
                                }
                              },

                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: "edit",
                                  child: Row(
                                    children: [
                                      Icon(Icons.edit, color: Colors.blue),
                                      SizedBox(width: 10),
                                      Text("Edit"),
                                    ],
                                  ),
                                ),

                                const PopupMenuItem(
                                  value: "delete",
                                  child: Row(
                                    children: [
                                      Icon(Icons.delete, color: Colors.red),
                                      SizedBox(width: 10),
                                      Text("Delete"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Statistics Card

  Widget buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 5),

        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(15),
        ),

        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 25),

            const SizedBox(height: 5),

            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
