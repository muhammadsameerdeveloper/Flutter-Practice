import 'package:flutter/material.dart';

class TodoTask {
  final String id;
  String title;
  String notes;
  String category;
  String priority;
  DateTime createdAt;
  DateTime dueDate;
  bool isCompleted;
  bool isFavorite;

  TodoTask({
    required this.id,
    required this.title,
    required this.notes,
    required this.category,
    required this.priority,
    required this.createdAt,
    required this.dueDate,
    this.isCompleted = false,
    this.isFavorite = false,
  });
}

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView>
    with SingleTickerProviderStateMixin {
  final TextEditingController controller = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  final List<TodoTask> tasks = [];

  late AnimationController animationController;

  String selectedFilter = "All";
  String selectedPriority = "Medium";
  String selectedCategory = "General";
  String selectedSort = "Newest";
  String selectedCategoryFilter = "All";

  DateTime selectedDueDate = DateTime.now().add(const Duration(days: 1));

  bool isDarkMode = false;
  bool isGridView = false;
  bool showFavoritesOnly = false;

  final List<String> priorities = ["Low", "Medium", "High"];

  final List<String> categories = [
    "General",
    "Work",
    "Personal",
    "Study",
    "Shopping",
    "Health",
  ];

  final List<String> filters = ["All", "Pending", "Completed", "Overdue"];

  // COLORS

  Color get primaryColor => const Color(0xff2563EB);

  Color get backgroundColor =>
      isDarkMode ? const Color(0xff101827) : const Color(0xffF3F6FC);

  Color get cardColor => isDarkMode ? const Color(0xff1F2937) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xff1E293B);

  Color get secondaryTextColor =>
      isDarkMode ? Colors.white60 : Colors.grey.shade600;

  // STATISTICS

  int get totalTasks => tasks.length;

  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  int get pendingTasks => totalTasks - completedTasks;

  int get overdueTasks => tasks
      .where((task) => !task.isCompleted && isOverdue(task.dueDate))
      .length;

  int get favoriteTasks => tasks.where((task) => task.isFavorite).length;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

  // INITIALIZATION

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    animationController.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    notesController.dispose();
    searchController.dispose();
    animationController.dispose();
    super.dispose();
  }

  // DATE HELPERS

  bool isSameDay(DateTime first, DateTime second) {
    return first.year == second.year &&
        first.month == second.month &&
        first.day == second.day;
  }

  bool isOverdue(DateTime date) {
    final today = DateTime.now();

    return date.isBefore(DateTime(today.year, today.month, today.day));
  }

  String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/"
        "${date.month.toString().padLeft(2, '0')}/"
        "${date.year}";
  }

  String getDueLabel(DateTime date) {
    final today = DateTime.now();

    if (isSameDay(date, today)) return "Today";

    if (isSameDay(date, today.add(const Duration(days: 1)))) {
      return "Tomorrow";
    }

    if (isOverdue(date)) return "Overdue";

    return formatDate(date);
  }

  Future<DateTime?> pickDate(DateTime initialDate) async {
    final today = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate:
          initialDate.isBefore(DateTime(today.year, today.month, today.day))
          ? today
          : initialDate,
      firstDate: DateTime(today.year, today.month, today.day),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(
            context,
          ).copyWith(colorScheme: ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
  }

  // MESSAGE

  void showMessage(String message, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                error ? Icons.error_outline : Icons.check_circle_outline,
                color: Colors.white,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Colors.red : const Color(0xff2563EB),
          duration: const Duration(seconds: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ADD TASK

  void addTask() {
    final title = controller.text.trim();

    if (title.isEmpty) {
      showMessage("Please enter task title!", error: true);
      return;
    }

    final task = TodoTask(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      notes: notesController.text.trim(),
      category: selectedCategory,
      priority: selectedPriority,
      createdAt: DateTime.now(),
      dueDate: selectedDueDate,
    );

    setState(() {
      tasks.insert(0, task);

      controller.clear();
      notesController.clear();

      selectedPriority = "Medium";
      selectedCategory = "General";
      selectedDueDate = DateTime.now().add(const Duration(days: 1));
    });

    FocusScope.of(context).unfocus();
    animationController.forward(from: 0);

    showMessage("Task added successfully!");
  }

  // EDIT TASK

  Future<void> editTask(TodoTask task) async {
    final editController = TextEditingController(text: task.title);

    final editNotesController = TextEditingController(text: task.notes);

    String editPriority = task.priority;
    String editCategory = task.category;
    DateTime editDueDate = task.dueDate;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: cardColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Text(
                "Edit Task",
                style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: editController,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: "Task Title",
                        prefixIcon: Icon(Icons.edit),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    TextField(
                      controller: editNotesController,
                      maxLines: 3,
                      style: TextStyle(color: textColor),
                      decoration: const InputDecoration(
                        labelText: "Description",
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: editPriority,
                      isExpanded: true,
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
                      isExpanded: true,
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
                    const SizedBox(height: 15),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await pickDate(editDueDate);

                        if (date != null) {
                          setDialogState(() {
                            editDueDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text("Due: ${formatDate(editDueDate)}"),
                    ),
                  ],
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
                  onPressed: () {
                    if (editController.text.trim().isEmpty) {
                      showMessage("Title cannot be empty!", error: true);
                      return;
                    }

                    setState(() {
                      task.title = editController.text.trim();
                      task.notes = editNotesController.text.trim();
                      task.priority = editPriority;
                      task.category = editCategory;
                      task.dueDate = editDueDate;
                    });

                    Navigator.pop(dialogContext);
                    showMessage("Task updated successfully!");
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
    editNotesController.dispose();
  }

  // DUPLICATE TASK

  void duplicateTask(TodoTask task) {
    setState(() {
      tasks.insert(
        0,
        TodoTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: "${task.title} (Copy)",
          notes: task.notes,
          category: task.category,
          priority: task.priority,
          createdAt: DateTime.now(),
          dueDate: task.dueDate,
        ),
      );
    });

    showMessage("Task duplicated!");
  }

  // DELETE TASK WITH UNDO

  void deleteTask(TodoTask task) {
    final index = tasks.indexOf(task);

    if (index == -1) return;

    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text("Task deleted!"),
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: "UNDO",
            onPressed: () {
              if (!mounted) return;

              setState(() {
                tasks.insert(index.clamp(0, tasks.length), task);
              });
            },
          ),
        ),
      );
  }

  // COMPLETE TASK

  void toggleTask(TodoTask task, bool value) {
    setState(() {
      task.isCompleted = value;
    });

    showMessage(value ? "Task completed!" : "Task reopened!");
  }

  // FAVORITE TASK

  void toggleFavorite(TodoTask task) {
    setState(() {
      task.isFavorite = !task.isFavorite;
    });

    showMessage(
      task.isFavorite ? "Added to favorites!" : "Removed from favorites!",
    );
  }

  // CLEAR COMPLETED

  void clearCompleted() {
    if (completedTasks == 0) {
      showMessage("No completed tasks!", error: true);
      return;
    }

    setState(() {
      tasks.removeWhere((task) => task.isCompleted);
    });

    showMessage("Completed tasks cleared!");
  }

  // CLEAR ALL

  Future<void> clearAllTasks() async {
    if (tasks.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: cardColor,
          title: Text("Delete All Tasks?", style: TextStyle(color: textColor)),
          content: Text(
            "Are you sure you want to delete all tasks?",
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );

    if (confirm == true && mounted) {
      setState(() {
        tasks.clear();
      });

      showMessage("All tasks deleted!");
    }
  }

  // FILTER AND SORT

  List<TodoTask> get filteredTasks {
    final search = searchController.text.trim().toLowerCase();

    List<TodoTask> result = tasks.where((task) {
      final matchesSearch =
          task.title.toLowerCase().contains(search) ||
          task.notes.toLowerCase().contains(search);

      final matchesFilter =
          selectedFilter == "All" ||
          (selectedFilter == "Pending" && !task.isCompleted) ||
          (selectedFilter == "Completed" && task.isCompleted) ||
          (selectedFilter == "Overdue" &&
              !task.isCompleted &&
              isOverdue(task.dueDate));

      final matchesCategory =
          selectedCategoryFilter == "All" ||
          task.category == selectedCategoryFilter;

      final matchesFavorite = !showFavoritesOnly || task.isFavorite;

      return matchesSearch &&
          matchesFilter &&
          matchesCategory &&
          matchesFavorite;
    }).toList();

    switch (selectedSort) {
      case "Newest":
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case "Oldest":
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case "Priority":
        int priorityValue(String value) {
          switch (value) {
            case "High":
              return 1;
            case "Medium":
              return 2;
            default:
              return 3;
          }
        }

        result.sort(
          (a, b) =>
              priorityValue(a.priority).compareTo(priorityValue(b.priority)),
        );
        break;

      case "A-Z":
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;

      case "Due Date":
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
    }

    return result;
  }

  // PRIORITY COLORS

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

  // CATEGORY ICON

  IconData getCategoryIcon(String category) {
    switch (category) {
      case "Work":
        return Icons.work_outline;
      case "Personal":
        return Icons.person_outline;
      case "Study":
        return Icons.school_outlined;
      case "Shopping":
        return Icons.shopping_bag_outlined;
      case "Health":
        return Icons.favorite_outline;
      default:
        return Icons.category_outlined;
    }
  }

  // BUILD MAIN SCREEN

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "My Todo App",
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            tooltip: "Change Theme",
            onPressed: () {
              setState(() {
                isDarkMode = !isDarkMode;
              });
            },
            icon: Icon(isDarkMode ? Icons.light_mode : Icons.dark_mode),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == "clear") clearAllTasks();
              if (value == "completed") clearCompleted();

              if (value == "favorites") {
                setState(() {
                  showFavoritesOnly = !showFavoritesOnly;
                });
              }

              if (value == "view") {
                setState(() {
                  isGridView = !isGridView;
                });
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: "favorites",
                child: Text("Toggle Favorites"),
              ),
              PopupMenuItem(
                value: "view",
                child: Text(isGridView ? "List View" : "Grid View"),
              ),
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final isSmall = width < 380;
            final contentWidth = width > 1100 ? 1000.0 : width;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 30),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildDashboard(isSmall),
                      const SizedBox(height: 18),
                      buildAddTaskSection(isSmall),
                      const SizedBox(height: 18),
                      buildSearch(isSmall),
                      const SizedBox(height: 15),
                      buildFilters(isSmall),
                      const SizedBox(height: 12),
                      buildCategoryFilter(isSmall),
                      const SizedBox(height: 15),
                      buildTaskHeading(isSmall),
                      buildTaskList(isSmall),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        tooltip: "Scroll to top",
        onPressed: () {
          FocusScope.of(context).unfocus();
          showMessage("Use the task form above to add a task.");
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // DASHBOARD

  Widget buildDashboard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 16 : 23),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withOpacity(0.20),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Manage Your Tasks",
            style: TextStyle(
              fontSize: 26,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            "Stay organized and productive!",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 22),

          // RESPONSIVE STATISTICS
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = (constraints.maxWidth - 12) / 2;

              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  buildStatCard("Total", totalTasks, Icons.list_alt, itemWidth),
                  buildStatCard(
                    "Completed",
                    completedTasks,
                    Icons.task_alt,
                    itemWidth,
                  ),
                  buildStatCard(
                    "Pending",
                    pendingTasks,
                    Icons.pending_actions,
                    itemWidth,
                  ),
                  buildStatCard(
                    "Overdue",
                    overdueTasks,
                    Icons.warning_amber,
                    itemWidth,
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 23),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Overall Progress",
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
                  fontSize: 18,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 12,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                );
              },
            ),
          ),

          const SizedBox(height: 9),

          Text(
            "$completedTasks out of $totalTasks tasks completed",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.favorite, color: Colors.pinkAccent, size: 17),
              const SizedBox(width: 6),
              Text(
                "$favoriteTasks Favorite Tasks",
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // STATISTICS CARD

  Widget buildStatCard(String title, int value, IconData icon, double width) {
    return SizedBox(
      width: width,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.17),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 9),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "$value",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADD TASK SECTION

  Widget buildAddTaskSection(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.add_task, color: primaryColor),
                const SizedBox(width: 9),
                Text(
                  "Create New Task",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller,
              onSubmitted: (_) => addTask(),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter your task...",
                prefixIcon: const Icon(Icons.edit_note),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 11),

            TextField(
              controller: notesController,
              maxLines: 2,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Description (optional)...",
                prefixIcon: const Icon(Icons.notes),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 13),

            LayoutBuilder(
              builder: (context, constraints) {
                final stacked = constraints.maxWidth < 450;

                final priorityField = buildDropdown(
                  "Priority",
                  selectedPriority,
                  priorities,
                  (value) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  },
                );

                final categoryField = buildDropdown(
                  "Category",
                  selectedCategory,
                  categories,
                  (value) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                );

                if (stacked) {
                  return Column(
                    children: [
                      priorityField,
                      const SizedBox(height: 10),
                      categoryField,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: priorityField),
                    const SizedBox(width: 10),
                    Expanded(child: categoryField),
                  ],
                );
              },
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final date = await pickDate(selectedDueDate);

                  if (date != null) {
                    setState(() {
                      selectedDueDate = date;
                    });
                  }
                },
                icon: const Icon(Icons.calendar_month),
                label: Text("Due Date: ${formatDate(selectedDueDate)}"),
              ),
            ),

            const SizedBox(height: 13),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: addTask,
                icon: const Icon(Icons.add),
                label: const Text(
                  "Add New Task",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // DROPDOWN

  Widget buildDropdown(
    String label,
    String selectedValue,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: selectedValue,
      isExpanded: true,
      dropdownColor: cardColor,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
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

  // SEARCH

  Widget buildSearch(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          hintText: "Search tasks or descriptions...",
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
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // FILTERS

  Widget buildFilters(bool isSmall) {
    return SizedBox(
      height: 45,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = filters[index];
          final selected = selectedFilter == filter;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              setState(() {
                selectedFilter = filter;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? primaryColor : cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  filter,
                  style: TextStyle(
                    color: selected ? Colors.white : textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // CATEGORY FILTER

  Widget buildCategoryFilter(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
      child: DropdownButtonFormField<String>(
        value: selectedCategoryFilter,
        isExpanded: true,
        dropdownColor: cardColor,
        style: TextStyle(color: textColor),
        decoration: InputDecoration(
          labelText: "Filter by Category",
          prefixIcon: const Icon(Icons.category_outlined),
          filled: true,
          fillColor: cardColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(13),
            borderSide: BorderSide.none,
          ),
        ),
        items: ["All", ...categories].map((category) {
          return DropdownMenuItem(value: category, child: Text(category));
        }).toList(),
        onChanged: (value) {
          if (value != null) {
            setState(() {
              selectedCategoryFilter = value;
            });
          }
        },
      ),
    );
  }

  // TASK HEADING

  Widget buildTaskHeading(bool isSmall) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 14 : 18,
        vertical: 10,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  showFavoritesOnly ? "Favorite Tasks" : "My Tasks",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                Text(
                  "${filteredTasks.length} tasks found",
                  style: TextStyle(fontSize: 11, color: secondaryTextColor),
                ),
              ],
            ),
          ),
          DropdownButton<String>(
            value: selectedSort,
            underline: const SizedBox(),
            icon: Icon(Icons.sort, color: textColor),
            dropdownColor: cardColor,
            style: TextStyle(color: textColor, fontSize: 12),
            items: ["Newest", "Oldest", "Priority", "A-Z", "Due Date"].map((
              value,
            ) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  selectedSort = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  // TASK LIST

  Widget buildTaskList(bool isSmall) {
    final result = filteredTasks;

    if (result.isEmpty) {
      return SizedBox(height: 270, child: buildEmptyState());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16),
      child: isGridView
          ? LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth > 650 ? 2 : 1;

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: result.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 5,
                    mainAxisExtent: 205,
                  ),
                  itemBuilder: (context, index) {
                    final task = result[index];

                    return buildTaskCard(task);
                  },
                );
              },
            )
          : ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.length,
              itemBuilder: (context, index) {
                final task = result[index];

                return Dismissible(
                  key: ValueKey(task.id),
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
                    deleteTask(task);
                  },
                  child: buildTaskCard(task),
                );
              },
            ),
    );
  }

  // TASK CARD

  Widget buildTaskCard(TodoTask task) {
    final completed = task.isCompleted;
    final overdue = !completed && isOverdue(task.dueDate);
    final priorityColor = getPriorityColor(task.priority);

    return Card(
      elevation: 2,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Checkbox(
                  value: completed,
                  activeColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  onChanged: (value) {
                    toggleTask(task, value ?? false);
                  },
                ),

                Expanded(
                  child: Text(
                    task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: completed ? Colors.grey : textColor,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                ),

                IconButton(
                  tooltip: "Favorite",
                  onPressed: () => toggleFavorite(task),
                  icon: Icon(
                    task.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: task.isFavorite ? Colors.pink : secondaryTextColor,
                  ),
                ),

                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: textColor),
                  onSelected: (value) {
                    switch (value) {
                      case "edit":
                        editTask(task);
                        break;
                      case "delete":
                        deleteTask(task);
                        break;
                      case "duplicate":
                        duplicateTask(task);
                        break;
                      case "complete":
                        toggleTask(task, !completed);
                        break;
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
                      value: "duplicate",
                      child: Row(
                        children: [
                          Icon(Icons.copy, color: Colors.purple),
                          SizedBox(width: 10),
                          Text("Duplicate"),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: "complete",
                      child: Row(
                        children: [
                          Icon(
                            completed ? Icons.refresh : Icons.check_circle,
                            color: Colors.green,
                          ),
                          const SizedBox(width: 10),
                          Text(completed ? "Reopen" : "Complete"),
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
              ],
            ),

            if (task.notes.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(left: 12),
                child: Text(
                  task.notes,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: secondaryTextColor, fontSize: 12),
                ),
              ),
            ],

            const SizedBox(height: 11),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                buildTag(
                  task.category,
                  Colors.blue,
                  getCategoryIcon(task.category),
                ),
                buildTag(
                  "${task.priority} Priority",
                  priorityColor,
                  Icons.flag_outlined,
                ),
                buildTag(
                  getDueLabel(task.dueDate),
                  overdue ? Colors.red : Colors.purple,
                  Icons.calendar_today,
                ),
              ],
            ),

            const SizedBox(height: 11),

            Row(
              children: [
                Icon(Icons.access_time, size: 13, color: secondaryTextColor),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    "Created: ${formatDate(task.createdAt)}",
                    style: TextStyle(color: secondaryTextColor, fontSize: 10),
                  ),
                ),
                if (completed)
                  const Text(
                    "✓ Completed",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // TAG WIDGET

  Widget buildTag(String title, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // EMPTY STATE

  Widget buildEmptyState() {
    final bool noTasks = tasks.isEmpty;

    final String message = noTasks
        ? "Add a new task to get started!"
        : "Try another search or filter.";

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            noTasks ? Icons.task_alt : Icons.search_off,
            size: 75,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 12),
          Text(
            noTasks ? "No Tasks Available" : "No Matching Tasks",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: TextStyle(color: secondaryTextColor)),
          if (showFavoritesOnly && favoriteTasks == 0) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() {
                  showFavoritesOnly = false;
                });
              },
              child: const Text("Show All Tasks"),
            ),
          ],
        ],
      ),
    );
  }
}
