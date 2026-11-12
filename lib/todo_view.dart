import 'package:flutter/material.dart';

class TodoTask {
  String title;
  String description;
  String priority;
  String category;
  DateTime dueDate;
  bool isCompleted;

  TodoTask({
    required this.title,
    required this.description,
    required this.priority,
    required this.category,
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

  final Color primary = const Color(0xFF6258E8);
  final Color background = const Color(0xFFF5F6FC);

  List<TodoTask> tasks = [];

  String selectedFilter = "All";
  String selectedSort = "Due Date";
  String searchQuery = "";

  int get totalTasks => tasks.length;

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => tasks.where((task) => !task.isCompleted).length;

  int get overdueTasks => tasks.where((task) {
    return !task.isCompleted &&
        task.dueDate.isBefore(DateTime.now()) &&
        !DateUtils.isSameDay(task.dueDate, DateTime.now());
  }).length;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  List<TodoTask> get filteredTasks {
    List<TodoTask> result = tasks.where((task) {
      bool matchesFilter = true;

      if (selectedFilter == "Pending") {
        matchesFilter = !task.isCompleted;
      } else if (selectedFilter == "Completed") {
        matchesFilter = task.isCompleted;
      } else if (selectedFilter == "Overdue") {
        matchesFilter =
            !task.isCompleted &&
            task.dueDate.isBefore(DateTime.now()) &&
            !DateUtils.isSameDay(task.dueDate, DateTime.now());
      }

      final matchesSearch =
          task.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(searchQuery.toLowerCase()) ||
          task.category.toLowerCase().contains(searchQuery.toLowerCase());

      return matchesFilter && matchesSearch;
    }).toList();

    if (selectedSort == "Due Date") {
      result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    } else if (selectedSort == "Priority") {
      const order = {"High": 0, "Medium": 1, "Low": 2};

      result.sort((a, b) => order[a.priority]!.compareTo(order[b.priority]!));
    } else if (selectedSort == "Newest") {
      result = result.reversed.toList();
    }

    return result;
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Color getPriorityColor(String priority) {
    switch (priority) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  bool isOverdue(TodoTask task) {
    return !task.isCompleted &&
        task.dueDate.isBefore(DateTime.now()) &&
        !DateUtils.isSameDay(task.dueDate, DateTime.now());
  }

  String formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF29283A),
      ),
    );
  }

  // ADD / EDIT TASK

  Future<void> showTaskDialog({TodoTask? task}) async {
    final titleController = TextEditingController(text: task?.title ?? "");

    final descriptionController = TextEditingController(
      text: task?.description ?? "",
    );

    String priority = task?.priority ?? "Medium";
    String category = task?.category ?? "Personal";

    DateTime dueDate =
        task?.dueDate ?? DateTime.now().add(const Duration(days: 1));

    final result = await showDialog<TodoTask>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                task == null ? "Create New Task" : "Edit Task",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 420,
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
                          fillColor: background,
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
                          fillColor: background,
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
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items: ["High", "Medium", "Low"].map((value) {
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

                      const Text("Category"),
                      const SizedBox(height: 8),

                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        items:
                            [
                              "Personal",
                              "Work",
                              "Study",
                              "Shopping",
                              "Other",
                            ].map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setDialogState(() {
                              category = value;
                            });
                          }
                        },
                      ),

                      const SizedBox(height: 18),

                      const Text("Due Date"),
                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: dueDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2035),
                            );

                            if (date != null) {
                              setDialogState(() {
                                dueDate = date;
                              });
                            }
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: Text(formatDate(dueDate)),
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
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (titleController.text.trim().isEmpty) {
                      showMessage("Please enter task title");
                      return;
                    }

                    final newTask = TodoTask(
                      title: titleController.text.trim(),
                      description: descriptionController.text.trim(),
                      priority: priority,
                      category: category,
                      dueDate: dueDate,
                      isCompleted: task?.isCompleted ?? false,
                    );

                    Navigator.pop(dialogContext, newTask);
                  },
                  child: Text(task == null ? "Add Task" : "Update Task"),
                ),
              ],
            );
          },
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();

    if (result != null && mounted) {
      setState(() {
        if (task == null) {
          tasks.add(result);
        } else {
          task.title = result.title;
          task.description = result.description;
          task.priority = result.priority;
          task.category = result.category;
          task.dueDate = result.dueDate;
        }
      });

      showMessage(task == null ? "Task added successfully" : "Task updated");
    }
  }

  // COMPLETE TASK

  void toggleTask(TodoTask task, bool value) {
    setState(() {
      task.isCompleted = value;
    });

    showMessage(value ? "Task completed!" : "Task marked pending");
  }

  // DELETE WITH UNDO

  void deleteTask(TodoTask task) {
    final index = tasks.indexOf(task);

    setState(() {
      tasks.remove(task);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task deleted"),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: "UNDO",
          textColor: Colors.white,
          onPressed: () {
            setState(() {
              tasks.insert(index.clamp(0, tasks.length), task);
            });
          },
        ),
      ),
    );
  }

  // CLEAR COMPLETED

  Future<void> clearCompleted() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Clear Completed Tasks?"),
          content: const Text("All completed tasks will be deleted."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() {
        tasks.removeWhere((task) => task.isCompleted);
      });

      showMessage("Completed tasks cleared");
    }
  }

  // SUMMARY CARD

  Widget summaryCard(String title, int count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 25),
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
    );
  }

  // FILTER BUTTON

  Widget filterButton(String filter) {
    final selected = selectedFilter == filter;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedFilter = filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Text(
          filter,
          style: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // TASK CARD

  Widget taskCard(TodoTask task) {
    final color = getPriorityColor(task.priority);

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: task.isCompleted,
            activeColor: primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            onChanged: (value) {
              toggleTask(task, value ?? false);
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
                    color: task.isCompleted ? Colors.grey : Colors.black87,
                    decoration: task.isCompleted
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                  ),
                ),

                if (task.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    task.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],

                const SizedBox(height: 12),

                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    taskBadge(task.priority, color),
                    taskBadge(task.category, Colors.blue),
                    taskBadge(
                      isOverdue(task)
                          ? "Overdue"
                          : task.isCompleted
                          ? "Completed"
                          : "Due: ${formatDate(task.dueDate)}",
                      isOverdue(task) ? Colors.red : Colors.grey,
                    ),
                  ],
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
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

  Widget taskBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // EMPTY SCREEN

  Widget emptyScreen() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      child: Column(
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

  // PROGRESS CARD

  Widget progressCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primary, const Color(0xFF9289F5)]),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Your Daily Progress",
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$completedTasks of $totalTasks tasks completed",
            style: const TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 20),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.white),
            ),
          ),

          const SizedBox(height: 10),

          Align(
            alignment: Alignment.centerRight,
            child: Text(
              "${(progress * 100).toInt()}%",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MAIN UI

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showTaskDialog(),
        backgroundColor: primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("New Task"),
      ),

      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 900;
            final isTablet = constraints.maxWidth >= 600;

            final padding = isDesktop ? 55.0 : 18.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1250),
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: padding,
                    vertical: 20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // HEADER
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Hello, User! 👋",
                                  style: TextStyle(
                                    fontSize: isDesktop ? 32 : 25,
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
                          ),
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: primary.withValues(alpha: 0.12),
                            child: Icon(Icons.person, color: primary, size: 28),
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // PROGRESS
                      progressCard(),

                      const SizedBox(height: 20),

                      // STATISTICS
                      GridView.count(
                        crossAxisCount: isDesktop
                            ? 4
                            : isTablet
                            ? 4
                            : 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: isDesktop ? 1.8 : 1.65,
                        children: [
                          summaryCard(
                            "Total Tasks",
                            totalTasks,
                            Icons.assignment_outlined,
                            primary,
                          ),
                          summaryCard(
                            "Pending",
                            pendingTasks,
                            Icons.pending_actions,
                            Colors.orange,
                          ),
                          summaryCard(
                            "Completed",
                            completedTasks,
                            Icons.task_alt,
                            Colors.green,
                          ),
                          summaryCard(
                            "Overdue",
                            overdueTasks,
                            Icons.warning_amber_rounded,
                            Colors.red,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      // SEARCH
                      TextField(
                        controller: searchController,
                        onChanged: (value) {
                          setState(() {
                            searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
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

                      const SizedBox(height: 22),

                      // FILTERS
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            for (final filter in [
                              "All",
                              "Pending",
                              "Completed",
                              "Overdue",
                            ]) ...[
                              filterButton(filter),
                              const SizedBox(width: 9),
                            ],
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // TASK HEADER
                      Row(
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
                            items: ["Due Date", "Priority", "Newest"].map((
                              value,
                            ) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  selectedSort = value;
                                });
                              }
                            },
                          ),

                          IconButton(
                            tooltip: "Clear completed tasks",
                            onPressed: completedTasks == 0
                                ? null
                                : clearCompleted,
                            icon: const Icon(Icons.cleaning_services_outlined),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // TASK LIST
                      if (filteredTasks.isEmpty)
                        emptyScreen()
                      else if (isDesktop)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 520,
                                mainAxisExtent: 165,
                                crossAxisSpacing: 15,
                                mainAxisSpacing: 5,
                              ),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return taskCard(filteredTasks[index]);
                          },
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredTasks.length,
                          itemBuilder: (context, index) {
                            return taskCard(filteredTasks[index]);
                          },
                        ),

                      const SizedBox(height: 90),
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
