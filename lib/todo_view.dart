import 'package:flutter/material.dart';

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final TextEditingController controller = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> tasks = [];

  String selectedFilter = "All";
  String selectedPriority = "Medium";
  String selectedCategory = "General";
  String selectedSort = "Newest";

  DateTime selectedDueDate = DateTime.now().add(const Duration(days: 1));

  bool isDarkMode = false;

  final List<String> priorities = ["Low", "Medium", "High"];

  final List<String> categories = [
    "General",
    "Work",
    "Personal",
    "Study",
    "Shopping",
    "Health",
  ];

  // COLORS

  Color get primaryColor => const Color(0xff2563EB);

  Color get backgroundColor =>
      isDarkMode ? const Color(0xff111827) : const Color(0xffF3F6FC);

  Color get cardColor => isDarkMode ? const Color(0xff1F2937) : Colors.white;

  Color get textColor => isDarkMode ? Colors.white : const Color(0xff1E293B);

  // STATISTICS

  int get totalTasks => tasks.length;

  int get completedTasks =>
      tasks.where((task) => task["completed"] == true).length;

  int get pendingTasks => totalTasks - completedTasks;

  int get overdueTasks => tasks.where((task) {
    return task["completed"] == false && isOverdue(task["dueDate"]);
  }).length;

  double get progress => totalTasks == 0 ? 0 : completedTasks / totalTasks;

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
    return "${date.day}/${date.month}/${date.year}";
  }

  String getDueLabel(DateTime date) {
    final today = DateTime.now();

    if (isSameDay(date, today)) {
      return "Today";
    }

    if (isSameDay(date, today.add(const Duration(days: 1)))) {
      return "Tomorrow";
    }

    if (isOverdue(date)) {
      return "Overdue";
    }

    return formatDate(date);
  }

  // ADD TASK

  void addTask() {
    if (controller.text.trim().isEmpty) {
      showMessage("Please enter task name!");
      return;
    }

    setState(() {
      tasks.add({
        "id": DateTime.now().microsecondsSinceEpoch,
        "title": controller.text.trim(),
        "notes": notesController.text.trim(),
        "completed": false,
        "date": DateTime.now(),
        "dueDate": selectedDueDate,
        "priority": selectedPriority,
        "category": selectedCategory,
      });

      controller.clear();
      notesController.clear();

      selectedPriority = "Medium";
      selectedCategory = "General";
      selectedDueDate = DateTime.now().add(const Duration(days: 1));
    });

    FocusScope.of(context).unfocus();

    showMessage("Task added successfully!");
  }

  // SELECT DUE DATE

  Future<DateTime?> pickDate(DateTime initialDate) async {
    return await showDatePicker(
      context: context,
      initialDate: initialDate.isBefore(DateTime.now())
          ? DateTime.now()
          : initialDate,
      firstDate: DateTime.now(),
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

  // EDIT TASK

  Future<void> editTask(int index) async {
    final task = tasks[index];

    final editController = TextEditingController(text: task["title"]);

    final editNotesController = TextEditingController(text: task["notes"]);

    String editPriority = task["priority"];
    String editCategory = task["category"];
    DateTime editDueDate = task["dueDate"];

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
                      return;
                    }

                    setState(() {
                      tasks[index]["title"] = editController.text.trim();

                      tasks[index]["notes"] = editNotesController.text.trim();

                      tasks[index]["priority"] = editPriority;
                      tasks[index]["category"] = editCategory;
                      tasks[index]["dueDate"] = editDueDate;
                    });

                    Navigator.pop(dialogContext);
                    showMessage("Task updated!");
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

  // DELETE TASK WITH UNDO

  void deleteTask(int index) {
    final deletedTask = tasks[index];

    setState(() {
      tasks.removeAt(index);
    });

    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Task deleted!"),
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

  // COMPLETE TASK

  void toggleTask(int index, bool value) {
    setState(() {
      tasks[index]["completed"] = value;
    });

    showMessage(value ? "Task completed!" : "Task reopened!");
  }

  // CLEAR COMPLETED

  void clearCompleted() {
    if (completedTasks == 0) {
      showMessage("No completed tasks!");
      return;
    }

    setState(() {
      tasks.removeWhere((task) => task["completed"] == true);
    });

    showMessage("Completed tasks cleared!");
  }

  // CLEAR ALL

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
              onPressed: () {
                Navigator.pop(dialogContext);
              },
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
                showMessage("All tasks deleted!");
              },
              child: const Text("Delete All"),
            ),
          ],
        );
      },
    );
  }

  // SEARCH, FILTER AND SORT

  List<Map<String, dynamic>> get filteredTasks {
    final search = searchController.text.toLowerCase();

    List<Map<String, dynamic>> result = tasks.where((task) {
      final title = task["title"].toString().toLowerCase();
      final notes = task["notes"].toString().toLowerCase();

      final matchesSearch = title.contains(search) || notes.contains(search);

      final matchesFilter =
          selectedFilter == "All" ||
          (selectedFilter == "Pending" && task["completed"] == false) ||
          (selectedFilter == "Completed" && task["completed"] == true) ||
          (selectedFilter == "Overdue" &&
              task["completed"] == false &&
              isOverdue(task["dueDate"]));

      return matchesSearch && matchesFilter;
    }).toList();

    if (selectedSort == "Newest") {
      result.sort((a, b) => b["date"].compareTo(a["date"]));
    } else if (selectedSort == "Oldest") {
      result.sort((a, b) => a["date"].compareTo(b["date"]));
    } else if (selectedSort == "Priority") {
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
    } else if (selectedSort == "A-Z") {
      result.sort(
        (a, b) => a["title"].toString().toLowerCase().compareTo(
          b["title"].toString().toLowerCase(),
        ),
      );
    }

    return result;
  }

  // PRIORITY COLOR

  Color getPriorityColor(String priority) {
    if (priority == "High") return Colors.red;
    if (priority == "Medium") return Colors.orange;
    return Colors.green;
  }

  // MESSAGE

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // DISPOSE

  @override
  void dispose() {
    controller.dispose();
    notesController.dispose();
    searchController.dispose();
    super.dispose();
  }

  // MAIN UI

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
            final width = constraints.maxWidth;

            final contentWidth = width > 1000 ? 900.0 : width;

            final isSmall = width < 380;
            final isMobile = width < 600;

            return Center(
              child: SizedBox(
                width: contentWidth,

                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 25),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      buildDashboard(isSmall),

                      const SizedBox(height: 18),

                      buildAddTaskSection(isSmall, isMobile),

                      const SizedBox(height: 15),

                      buildSearch(isSmall),

                      const SizedBox(height: 15),

                      buildFilters(isSmall),

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
    );
  }

  // DASHBOARD

  Widget buildDashboard(bool isSmall) {
    return Container(
      padding: EdgeInsets.all(isSmall ? 15 : 22),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Manage Your Tasks",
            style: TextStyle(
              fontSize: isSmall ? 22 : 27,
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

          Row(
            children: [
              buildStatCard("Total", totalTasks, Icons.list_alt),
              const SizedBox(width: 8),
              buildStatCard("Completed", completedTasks, Icons.task_alt),
              const SizedBox(width: 8),
              buildStatCard("Pending", pendingTasks, Icons.pending_actions),
              const SizedBox(width: 8),
              buildStatCard("Overdue", overdueTasks, Icons.warning_amber),
            ],
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
                  fontSize: 17,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 11,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "$completedTasks out of $totalTasks tasks completed",
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // STATISTICS CARD

  Widget buildStatCard(String title, int value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 2),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.17),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 21),

            const SizedBox(height: 6),

            FittedBox(
              child: Text(
                "$value",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),

            FittedBox(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ADD TASK SECTION

  Widget buildAddTaskSection(bool isSmall, bool isMobile) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 12 : 16),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Create New Task",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: controller,
              onSubmitted: (_) => addTask(),
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Enter your task...",
                prefixIcon: const Icon(Icons.edit_note, color: Colors.blue),
                filled: true,
                fillColor: backgroundColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(13),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 10),

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

            const SizedBox(height: 12),

            if (isMobile)
              Column(
                children: [
                  buildDropdown("Priority", selectedPriority, priorities, (
                    value,
                  ) {
                    setState(() {
                      selectedPriority = value!;
                    });
                  }),

                  const SizedBox(height: 10),

                  buildDropdown("Category", selectedCategory, categories, (
                    value,
                  ) {
                    setState(() {
                      selectedCategory = value!;
                    });
                  }),
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
                      categories,
                      (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 12),

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

            const SizedBox(height: 12),

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

  // FILTER BUTTONS

  Widget buildFilters(bool isSmall) {
    final filters = ["All", "Pending", "Completed", "Overdue"];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 8 : 14),
      child: Row(
        children: filters.map((filter) {
          final selected = selectedFilter == filter;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  setState(() {
                    selectedFilter = filter;
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 2,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? primaryColor : cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: FittedBox(
                      child: Text(
                        filter,
                        style: TextStyle(
                          color: selected ? Colors.white : textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
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
            child: Text(
              "My Tasks (${filteredTasks.length})",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),

          DropdownButton<String>(
            value: selectedSort,
            underline: const SizedBox(),
            icon: Icon(Icons.sort, color: textColor),
            dropdownColor: cardColor,
            style: TextStyle(color: textColor, fontSize: 12),
            items: ["Newest", "Oldest", "Priority", "A-Z"].map((value) {
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
      return SizedBox(height: 250, child: buildEmptyState());
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final task = result[index];

          final realIndex = tasks.indexOf(task);

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
              child: const Icon(Icons.delete, color: Colors.white, size: 30),
            ),
            onDismissed: (_) {
              deleteTask(realIndex);
            },
            child: buildTaskCard(task, realIndex),
          );
        },
      ),
    );
  }

  // TASK CARD

  Widget buildTaskCard(Map<String, dynamic> task, int realIndex) {
    final bool completed = task["completed"];

    final String priority = task["priority"];

    final DateTime date = task["date"];

    final DateTime dueDate = task["dueDate"];

    final Color priorityColor = getPriorityColor(priority);

    final bool overdue = !completed && isOverdue(dueDate);

    return Card(
      elevation: 2,
      color: cardColor,
      margin: const EdgeInsets.only(bottom: 13),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            Checkbox(
              value: completed,
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
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: completed ? Colors.grey : textColor,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  if (task["notes"].toString().isNotEmpty) ...[
                    const SizedBox(height: 5),

                    Text(
                      task["notes"],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isDarkMode
                            ? Colors.white60
                            : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],

                  const SizedBox(height: 9),

                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      buildTag(task["category"], Colors.blue),

                      buildTag("$priority Priority", priorityColor),

                      buildTag(
                        getDueLabel(dueDate),
                        overdue ? Colors.red : Colors.purple,
                      ),
                    ],
                  ),

                  const SizedBox(height: 7),

                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey.shade500,
                      ),

                      const SizedBox(width: 4),

                      Flexible(
                        child: Text(
                          "Created: ${formatDate(date)}",
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (completed) ...[
                    const SizedBox(height: 5),

                    const Text(
                      "✓ Task Completed",
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
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

                if (value == "complete") {
                  toggleTask(realIndex, !completed);
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
      ),
    );
  }

  // TAG WIDGET

  Widget buildTag(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // EMPTY STATE

  Widget buildEmptyState() {
    final bool noTasks = tasks.isEmpty;

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

          Text(
            noTasks
                ? "Add a new task to get started!"
                : "Try another search or filter.",
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
}
