import 'package:flutter/material.dart';

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
  String selectedPriority = "Medium";
  String selectedCategory = "General";
  String selectedSort = "Newest";

  // Add Task
  void addTask() {
    if (controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please enter a task!")));
      return;
    }

    setState(() {
      tasks.add({
        "id": DateTime.now().microsecondsSinceEpoch,
        "title": controller.text.trim(),
        "completed": false,
        "date": DateTime.now(),
        "priority": selectedPriority,
        "category": selectedCategory,
      });

      controller.clear();
    });

    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Task Added Successfully"),
        duration: Duration(seconds: 1),
      ),
    );
  }

  // Edit Task
  Future<void> editTask(int index) async {
    TextEditingController editController = TextEditingController(
      text: tasks[index]["title"],
    );

    String editPriority = tasks[index]["priority"];
    String editCategory = tasks[index]["category"];

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Edit Task",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editController,
                      decoration: const InputDecoration(
                        hintText: "Enter task name",
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: editPriority,
                      decoration: const InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(),
                      ),
                      items: ["Low", "Medium", "High"].map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          editPriority = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: editCategory,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: ["General", "Work", "Personal", "Study"].map((
                        value,
                      ) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          editCategory = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (editController.text.trim().isEmpty) return;

                    setState(() {
                      tasks[index]["title"] = editController.text.trim();
                      tasks[index]["priority"] = editPriority;
                      tasks[index]["category"] = editCategory;
                    });

                    Navigator.pop(context);
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );

    editController.dispose();
  }

  // Delete Task with Undo
  void deleteTask(int index) {
    Map<String, dynamic> deletedTask = tasks[index];

    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task Deleted"),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            setState(() {
              tasks.insert(index.clamp(0, tasks.length), deletedTask);
            });
          },
        ),
      ),
    );
  }

  // Complete / Incomplete Task
  void toggleTask(int index, bool value) {
    setState(() {
      tasks[index]["completed"] = value;
    });
  }

  // Clear Completed Tasks
  void clearCompleted() {
    setState(() {
      tasks.removeWhere((task) => task["completed"] == true);
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Completed Tasks Cleared")));
  }

  // Clear All Tasks
  void clearAllTasks() {
    if (tasks.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Delete All Tasks?"),
          content: const Text("Are you sure you want to delete all tasks?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  tasks.clear();
                });

                Navigator.pop(context);
              },
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );
  }

  // Filter and Search Tasks
  List<Map<String, dynamic>> get filteredTasks {
    String search = searchController.text.toLowerCase();

    List<Map<String, dynamic>> result = tasks.where((task) {
      bool matchesSearch = task["title"].toString().toLowerCase().contains(
        search,
      );

      bool matchesFilter =
          selectedFilter == "All" ||
          (selectedFilter == "Pending" && task["completed"] == false) ||
          (selectedFilter == "Completed" && task["completed"] == true);

      return matchesSearch && matchesFilter;
    }).toList();

    // Sorting
    if (selectedSort == "Newest") {
      result.sort((a, b) => b["date"].compareTo(a["date"]));
    } else if (selectedSort == "Oldest") {
      result.sort((a, b) => a["date"].compareTo(b["date"]));
    } else if (selectedSort == "Priority") {
      result.sort((a, b) {
        int getPriority(String value) {
          if (value == "High") return 1;
          if (value == "Medium") return 2;
          return 3;
        }

        return getPriority(a["priority"]).compareTo(getPriority(b["priority"]));
      });
    }

    return result;
  }

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task["completed"] == true).length;

  int get pendingTasks => totalTasks - completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  // Priority Color
  Color getPriorityColor(String priority) {
    if (priority == "High") return Colors.red;
    if (priority == "Medium") return Colors.orange;
    return Colors.green;
  }

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "clear") {
                clearAllTasks();
              }

              if (value == "completed") {
                clearCompleted();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "completed",
                child: Text("Clear Completed"),
              ),
              const PopupMenuItem(
                value: "clear",
                child: Text("Delete All Tasks"),
              ),
            ],
          ),
        ],
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
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller,
                          decoration: InputDecoration(
                            hintText: "Enter your task...",
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(Icons.edit_note),
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

                  const SizedBox(height: 12),

                  // Priority and Category
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedPriority,
                          decoration: InputDecoration(
                            labelText: "Priority",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ["Low", "Medium", "High"].map((value) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedPriority = value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: DropdownButtonFormField<String>(
                          value: selectedCategory,
                          decoration: InputDecoration(
                            labelText: "Category",
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: ["General", "Work", "Personal", "Study"].map((
                            value,
                          ) {
                            return DropdownMenuItem(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value!;
                            });
                          },
                        ),
                      ),
                    ],
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
                  suffixIcon: searchController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            setState(() {
                              searchController.clear();
                            });
                          },
                          icon: const Icon(Icons.close),
                        )
                      : null,
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

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

            // Task Heading and Sorting
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "My Tasks",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

                  DropdownButton<String>(
                    value: selectedSort,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.sort),
                    items: ["Newest", "Oldest", "Priority"].map((value) {
                      return DropdownMenuItem(value: value, child: Text(value));
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSort = value!;
                      });
                    },
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

                          const SizedBox(height: 5),

                          Text(
                            "Add a new task to get started!",
                            style: TextStyle(color: Colors.grey.shade500),
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

                        String priority = task["priority"];

                        return Dismissible(
                          key: ValueKey(task["id"]),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                          onDismissed: (direction) {
                            deleteTask(realIndex);
                          },
                          child: Card(
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
                                  color: isCompleted
                                      ? Colors.grey
                                      : Colors.black,
                                ),
                              ),

                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${task["category"]}  •  ${task["date"].hour}:${task["date"].minute.toString().padLeft(2, '0')}",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),

                                    const SizedBox(height: 5),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: getPriorityColor(
                                          priority,
                                        ).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        "$priority Priority",
                                        style: TextStyle(
                                          color: getPriorityColor(priority),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
