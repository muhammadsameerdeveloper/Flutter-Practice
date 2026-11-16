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

  final List<String> priorities = ["Low", "Medium", "High"];
  final List<String> categories = ["General", "Work", "Personal", "Study"];

  // Statistics

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task["completed"] == true).length;

  int get pendingTasks => totalTasks - completedTasks;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  // Add Task

  void addTask() {
    if (controller.text.trim().isEmpty) {
      showMessage("Please enter a task!");
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

    showMessage("Task Added Successfully!");
  }

  // Edit Task

  Future<void> editTask(int index) async {
    final editController = TextEditingController(text: tasks[index]["title"]);

    String editPriority = tasks[index]["priority"];
    String editCategory = tasks[index]["category"];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
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
                      decoration: InputDecoration(
                        hintText: "Task name",
                        prefixIcon: const Icon(Icons.edit),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: editPriority,
                      decoration: const InputDecoration(
                        labelText: "Priority",
                        border: OutlineInputBorder(),
                      ),
                      items: priorities.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            editPriority = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      value: editCategory,
                      decoration: const InputDecoration(
                        labelText: "Category",
                        border: OutlineInputBorder(),
                      ),
                      items: categories.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            editCategory = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
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

                    Navigator.pop(dialogContext);
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
    final deletedTask = tasks[index];

    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task Deleted"),
        behavior: SnackBarBehavior.floating,
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

  // Complete Task

  void toggleTask(int index, bool value) {
    setState(() {
      tasks[index]["completed"] = value;
    });
  }

  // Clear Completed

  void clearCompleted() {
    if (completedTasks == 0) {
      showMessage("No completed tasks!");
      return;
    }

    setState(() {
      tasks.removeWhere((task) => task["completed"] == true);
    });

    showMessage("Completed Tasks Cleared!");
  }

  // Clear All

  void clearAllTasks() {
    if (tasks.isEmpty) return;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text("Delete All Tasks?"),
          content: const Text("Are you sure you want to delete all tasks?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
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

                Navigator.pop(dialogContext);
              },
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );
  }

  // Search, Filter and Sort

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

    if (selectedSort == "Newest") {
      result.sort((a, b) => b["date"].compareTo(a["date"]));
    } else if (selectedSort == "Oldest") {
      result.sort((a, b) => a["date"].compareTo(b["date"]));
    } else {
      result.sort((a, b) {
        int priorityValue(String value) {
          if (value == "High") return 1;
          if (value == "Medium") return 2;
          return 3;
        }

        return priorityValue(
          a["priority"],
        ).compareTo(priorityValue(b["priority"]));
      });
    }

    return result;
  }

  // Priority Color

  Color getPriorityColor(String priority) {
    if (priority == "High") return Colors.red;
    if (priority == "Medium") return Colors.orange;
    return Colors.green;
  }

  // Snackbar

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Dispose

  @override
  void dispose() {
    controller.dispose();
    searchController.dispose();
    super.dispose();
  }

  // Main UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF4F6FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xff2563EB),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Todo App",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "clear") clearAllTasks();
              if (value == "completed") clearCompleted();
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: "completed", child: Text("Clear Completed")),
              PopupMenuItem(value: "clear", child: Text("Delete All Tasks")),
            ],
          ),
        ],
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double screenWidth = constraints.maxWidth;

            final double contentWidth = screenWidth > 900 ? 850 : screenWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    // Dashboard Header
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(screenWidth < 400 ? 16 : 22),
                      decoration: const BoxDecoration(
                        color: Color(0xff2563EB),
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(28),
                          bottomRight: Radius.circular(28),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Manage Your Tasks",
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
                            "Stay organized and productive!",
                            style: TextStyle(color: Colors.white70),
                          ),

                          const SizedBox(height: 20),

                          // Responsive Statistics
                          Row(
                            children: [
                              buildStatCard(
                                "Total",
                                totalTasks.toString(),
                                Icons.list_alt,
                              ),

                              const SizedBox(width: 8),

                              buildStatCard(
                                "Completed",
                                completedTasks.toString(),
                                Icons.check_circle_outline,
                              ),

                              const SizedBox(width: 8),

                              buildStatCard(
                                "Pending",
                                pendingTasks.toString(),
                                Icons.pending_actions,
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

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
                                style: const TextStyle(
                                  color: Colors.white,
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
                              minHeight: 10,
                              backgroundColor: Colors.white30,
                              valueColor: const AlwaysStoppedAnimation(
                                Colors.greenAccent,
                              ),
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
                                  onSubmitted: (_) => addTask(),
                                  decoration: InputDecoration(
                                    hintText: "Enter your task...",
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: const Icon(
                                      Icons.edit_note,
                                      color: Colors.blue,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 10),

                              SizedBox(
                                height: 55,
                                width: 55,
                                child: ElevatedButton(
                                  onPressed: addTask,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xff2563EB),
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

                          // Responsive Dropdowns
                          if (screenWidth < 380)
                            Column(
                              children: [
                                buildDropdown(
                                  "Priority",
                                  selectedPriority,
                                  priorities,
                                  (value) {
                                    setState(() {
                                      selectedPriority = value!;
                                    });
                                  },
                                ),

                                const SizedBox(height: 10),

                                buildDropdown(
                                  "Category",
                                  selectedCategory,
                                  categories,
                                  (value) {
                                    setState(() {
                                      selectedCategory = value!;
                                    });
                                  },
                                ),
                              ],
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child: buildDropdown(
                                    "Priority",
                                    selectedPriority,
                                    priorities,
                                    (value) {
                                      setState(() {
                                        selectedPriority = value!;
                                      });
                                    },
                                  ),
                                ),

                                const SizedBox(width: 10),

                                Expanded(
                                  child: buildDropdown(
                                    "Category",
                                    selectedCategory,
                                    (categories),
                                    (value) {
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

                    // Search
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TextField(
                        controller: searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: "Search your tasks...",
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

                    // Filters
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
                                      ? const Color(0xff2563EB)
                                      : Colors.white,
                                  foregroundColor: selected
                                      ? Colors.white
                                      : Colors.black87,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(filter),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    // Task Heading
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "My Tasks",
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          DropdownButton<String>(
                            value: selectedSort,
                            underline: const SizedBox(),
                            icon: const Icon(Icons.sort),
                            items: ["Newest", "Oldest", "Priority"].map((
                              value,
                            ) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
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
                          ? buildEmptyState()
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 5,
                              ),
                              itemCount: filteredTasks.length,
                              itemBuilder: (context, index) {
                                final task = filteredTasks[index];

                                final int realIndex = tasks.indexOf(task);

                                final bool isCompleted = task["completed"];

                                final String priority = task["priority"];

                                return Dismissible(
                                  key: ValueKey(task["id"]),
                                  direction: DismissDirection.endToStart,

                                  background: Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.only(right: 20),
                                    alignment: Alignment.centerRight,
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: const Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),

                                  onDismissed: (_) {
                                    deleteTask(realIndex);
                                  },

                                  child: buildTaskCard(
                                    task,
                                    realIndex,
                                    isCompleted,
                                    priority,
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // Statistics Card

  Widget buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),

            const SizedBox(height: 5),

            FittedBox(
              child: Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            FittedBox(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dropdown Widget

  Widget buildDropdown(
    String label,
    String selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
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
      items: items.map((value) {
        return DropdownMenuItem(value: value, child: Text(value));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // Task Card

  Widget buildTaskCard(
    Map<String, dynamic> task,
    int realIndex,
    bool isCompleted,
    String priority,
  ) {
    final date = task["date"] as DateTime;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            Checkbox(
              value: isCompleted,
              activeColor: Colors.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              onChanged: (value) {
                toggleTask(realIndex, value ?? false);
              },
            ),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task["title"],
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: isCompleted ? Colors.grey : Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 7),

                  Wrap(
                    spacing: 8,
                    runSpacing: 5,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        task["category"],
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),

                      Text(
                        "${date.day}/${date.month}/${date.year}",
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                      ),

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
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == "edit") {
                  editTask(realIndex);
                }

                if (value == "delete") {
                  deleteTask(realIndex);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: "edit",
                  child: Row(
                    children: [
                      Icon(Icons.edit, color: Colors.blue),
                      SizedBox(width: 10),
                      Text("Edit"),
                    ],
                  ),
                ),

                PopupMenuItem(
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
          ],
        ),
      ),
    );
  }

  // Empty State

  Widget buildEmptyState() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.task_alt, size: 75, color: Colors.grey.shade400),

            const SizedBox(height: 12),

            Text(
              tasks.isEmpty ? "No Tasks Available" : "No Matching Tasks",
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Add a new task to get started!",
              style: TextStyle(color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
