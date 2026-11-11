import 'package:flutter/material.dart';

class TodoTask {
  String title;
  String description;
  String priority;
  DateTime dueDate;
  bool isCompleted;

  TodoTask({
    required this.title,
    required this.description,
    required this.priority,
    required this.dueDate,
    this.isCompleted = false,
  });
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController searchController = TextEditingController();

  List<TodoTask> tasks = [];

  String selectedFilter = "All";
  String searchQuery = "";

  final Color primaryColor = const Color(0xFF6258E8);
  final Color backgroundColor = const Color(0xFFF5F6FC);

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => tasks.where((task) => !task.isCompleted).length;

  double get progress => tasks.isEmpty ? 0 : completedTasks / tasks.length;

  List<TodoTask> get filteredTasks {
    List<TodoTask> result = tasks
        .where((task) {
          if (selectedFilter == "Pending") {
            return !task.isCompleted;
          }

          if (selectedFilter == "Completed") {
            return task.isCompleted;
          }

          return true;
        })
        .where((task) {
          return task.title.toLowerCase().contains(searchQuery.toLowerCase());
        })
        .toList();

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void toggleTask(int index) {
    setState(() {
      filteredTasks[index].isCompleted = !filteredTasks[index].isCompleted;
    });
  }

  void deleteTask(TodoTask task) {
    setState(() {
      tasks.remove(task);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Task deleted successfully"),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void showTaskDialog({TodoTask? task}) {
    final titleController = TextEditingController(text: task?.title ?? "");

    final descriptionController = TextEditingController(
      text: task?.description ?? "",
    );

    String priority = task?.priority ?? "Medium";

    DateTime dueDate =
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                task == null ? "Create New Task" : "Edit Task",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Task Title"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          hintText: "Enter task title",
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text("Description"),
                      const SizedBox(height: 8),
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Enter description",
                          filled: true,
                          fillColor: backgroundColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),

                      const SizedBox(height: 18),

                      const Text("Priority"),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: priority,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: backgroundColor,
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
                          if (value != null) {
                            setDialogState(() {
                              priority = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text("Due Date"),
                      const SizedBox(height: 8),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final selectedDate = await showDatePicker(
                            context: context,
                            initialDate: dueDate,
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2035),
                          );

                          if (selectedDate != null) {
                            setDialogState(() {
                              dueDate = selectedDate;
                            });
                          }
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: Text(
                          "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      if (task == null) {
                        tasks.add(
                          TodoTask(
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            priority: priority,
                            dueDate: dueDate,
                          ),
                        );
                      } else {
                        task.title = titleController.text.trim();
                        task.description = descriptionController.text.trim();
                        task.priority = priority;
                        task.dueDate = dueDate;
                      }
                    });

                    Navigator.pop(dialogContext);

                    titleController.dispose();
                    descriptionController.dispose();
                  },
                  child: Text(task == null ? "Add Task" : "Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Color priorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  Widget buildSummaryCard(String title, int count, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 27),
            const SizedBox(height: 12),
            Text(
              "$count",
              style: const TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskCard(TodoTask task, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              setState(() {
                task.isCompleted = value ?? false;
              });
            },
          ),

          const SizedBox(width: 8),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                  ),
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 5),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 10),

                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: priorityColor(
                          task.priority,
                        ).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        task.priority,
                        style: TextStyle(
                          color: priorityColor(task.priority),
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Text(
                      "${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}",
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == "Edit") {
                showTaskDialog(task: task);
              } else if (value == "Delete") {
                deleteTask(task);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "Edit",
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 10),
                    Text("Edit"),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: "Delete",
                child: Row(
                  children: [
                    Icon(Icons.delete_outline, color: Colors.red),
                    SizedBox(width: 10),
                    Text("Delete"),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildFilterButton(String filter) {
    final isSelected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildEmptyScreen() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.task_alt, size: 75, color: Colors.grey.shade300),
          const SizedBox(height: 15),
          const Text(
            "No Tasks Found!",
            style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            "Add a new task to get started.",
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Task"),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final horizontalPadding = isDesktop ? 60.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Hello, User! 👋",
                                style: TextStyle(
                                  fontSize: isDesktop ? 30 : 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                "Let's organize your day",
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                          CircleAvatar(
                            radius: 23,
                            backgroundColor: primaryColor.withValues(
                              alpha: 0.12,
                            ),
                            child: Icon(Icons.person, color: primaryColor),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // PROGRESS CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [primaryColor, const Color(0xFF9289F5)],
                          ),
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Your Daily Progress",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "$completedTasks of ${tasks.length} tasks completed",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 18),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: LinearProgressIndicator(
                                value: progress,
                                minHeight: 10,
                                backgroundColor: Colors.white30,
                                valueColor: const AlwaysStoppedAnimation(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "${(progress * 100).toInt()}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // SUMMARY
                      Row(
                        children: [
                          buildSummaryCard(
                            "Total Tasks",
                            tasks.length,
                            Icons.assignment_outlined,
                            primaryColor,
                          ),
                          const SizedBox(width: 10),
                          buildSummaryCard(
                            "Pending",
                            pendingTasks,
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                          const SizedBox(width: 10),
                          buildSummaryCard(
                            "Completed",
                            completedTasks,
                            Icons.task_alt,
                            Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      // SEARCH
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search your tasks...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: searchQuery.isNotEmpty
                              ? IconButton(
                                  onPressed: () {
                                    searchController.clear();
                                    setState(() {
                                      searchQuery = "";
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

                      const SizedBox(height: 20),

                      // FILTERS
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            buildFilterButton("All"),
                            const SizedBox(width: 10),
                            buildFilterButton("Pending"),
                            const SizedBox(width: 10),
                            buildFilterButton("Completed"),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "My Tasks",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // TASK LIST
                      if (filteredTasks.isEmpty)
                        SizedBox(height: 250, child: buildEmptyScreen())
                      else if (isDesktop)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 500,
                                mainAxisExtent: 145,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 5,
                              ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return buildTaskCard(filteredTasks[index], index);
                          },
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return buildTaskCard(filteredTasks[index], index);
                          },
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
