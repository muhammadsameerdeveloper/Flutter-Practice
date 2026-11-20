import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

// ================= TASK MODEL =================

class TodoTask {
  String id;
  String title;
  String description;
  String category;
  String priority;
  DateTime createdAt;
  DateTime dueDate;
  bool completed;
  bool favorite;
  bool archived;
  List<Map<String, dynamic>> subtasks;

  TodoTask({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.createdAt,
    required this.dueDate,
    this.completed = false,
    this.favorite = false,
    this.archived = false,
    this.subtasks = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'dueDate': dueDate.toIso8601String(),
      'completed': completed,
      'favorite': favorite,
      'archived': archived,
      'subtasks': subtasks,
    };
  }

  factory TodoTask.fromJson(Map<String, dynamic> json) {
    return TodoTask(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      category: json['category'] ?? 'General',
      priority: json['priority'] ?? 'Medium',
      createdAt: DateTime.parse(json['createdAt']),
      dueDate: DateTime.parse(json['dueDate']),
      completed: json['completed'] ?? false,
      favorite: json['favorite'] ?? false,
      archived: json['archived'] ?? false,
      subtasks: List<Map<String, dynamic>>.from(
        (json['subtasks'] ?? []).map((e) => Map<String, dynamic>.from(e)),
      ),
    );
  }
}

// ================= TODO VIEW =================

class TodoView extends StatefulWidget {
  const TodoView({super.key});

  @override
  State<TodoView> createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final searchController = TextEditingController();
  final subtaskController = TextEditingController();

  List<TodoTask> tasks = [];
  List<String> selectedIds = [];

  String priority = 'Medium';
  String category = 'General';
  String filter = 'All';
  String sort = 'Newest';

  DateTime dueDate = DateTime.now().add(const Duration(days: 1));

  bool darkMode = false;
  bool loading = true;
  bool selectionMode = false;
  bool favoritesOnly = false;
  bool archiveMode = false;
  bool gridMode = false;

  final priorities = ['Low', 'Medium', 'High'];

  final categories = [
    'General',
    'Work',
    'Personal',
    'Study',
    'Shopping',
    'Health',
  ];

  final filters = ['All', 'Pending', 'Completed', 'Overdue'];

  // ================= COLORS =================

  Color get primary => const Color(0xff2563EB);

  Color get background =>
      darkMode ? const Color(0xff101827) : const Color(0xffF3F6FC);

  Color get card => darkMode ? const Color(0xff1F2937) : Colors.white;

  Color get text => darkMode ? Colors.white : const Color(0xff1E293B);

  Color get muted => darkMode ? Colors.white60 : Colors.grey.shade600;

  // ================= INITIALIZATION =================

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  Future<void> loadTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedData = prefs.getString('advanced_todo_tasks');

      if (savedData != null) {
        final decoded = jsonDecode(savedData) as List;

        tasks = decoded.map((item) {
          return TodoTask.fromJson(Map<String, dynamic>.from(item));
        }).toList();
      }
    } catch (e) {
      debugPrint('Loading error: $e');
    }

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> saveTasks() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final encoded = jsonEncode(tasks.map((task) => task.toJson()).toList());

      await prefs.setString('advanced_todo_tasks', encoded);
    } catch (e) {
      debugPrint('Saving error: $e');
      if (mounted) {
        message('Unable to save tasks!', error: true);
      }
    }
  }

  // ================= STATISTICS =================

  List<TodoTask> get activeTasks =>
      tasks.where((task) => !task.archived).toList();

  int get total => activeTasks.length;

  int get completed => activeTasks.where((task) => task.completed).length;

  int get pending => activeTasks.where((task) => !task.completed).length;

  int get overdue => activeTasks
      .where((task) => !task.completed && isOverdue(task.dueDate))
      .length;

  int get favorites => activeTasks.where((task) => task.favorite).length;

  int get archived => tasks.where((task) => task.archived).length;

  double get progress => total == 0 ? 0 : completed / total;

  int get subtaskTotal =>
      activeTasks.fold(0, (sum, task) => sum + task.subtasks.length);

  int get subtaskCompleted => activeTasks.fold(
    0,
    (sum, task) =>
        sum + task.subtasks.where((subtask) => subtask['done'] == true).length,
  );

  // ================= DATE HELPERS =================

  bool isOverdue(DateTime date) {
    final now = DateTime.now();

    return date.isBefore(DateTime(now.year, now.month, now.day));
  }

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String dueLabel(DateTime date) {
    final today = DateTime.now();

    if (sameDay(date, today)) return 'Today';

    if (sameDay(date, today.add(const Duration(days: 1)))) {
      return 'Tomorrow';
    }

    if (isOverdue(date)) return 'Overdue';

    return formatDate(date);
  }

  Future<DateTime?> chooseDate(DateTime initial) {
    final now = DateTime.now();

    return showDatePicker(
      context: context,
      initialDate: initial.isBefore(DateTime(now.year, now.month, now.day))
          ? DateTime(now.year, now.month, now.day)
          : initial,
      firstDate: DateTime(now.year, now.month, now.day),
      lastDate: DateTime(2100),
    );
  }

  // ================= MESSAGES =================

  void message(String value, {bool error = false}) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(value),
          behavior: SnackBarBehavior.floating,
          backgroundColor: error ? Colors.red : primary,
        ),
      );
  }

  // ================= ADD TASK =================

  void addTask() {
    if (titleController.text.trim().isEmpty) {
      message('Please enter a task title!', error: true);
      return;
    }

    setState(() {
      tasks.insert(
        0,
        TodoTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          category: category,
          priority: priority,
          createdAt: DateTime.now(),
          dueDate: dueDate,
        ),
      );

      titleController.clear();
      descriptionController.clear();

      priority = 'Medium';
      category = 'General';
      dueDate = DateTime.now().add(const Duration(days: 1));
    });

    saveTasks();
    FocusScope.of(context).unfocus();
    message('Task created successfully!');
  }

  // ================= SUBTASKS =================

  void addSubtask(TodoTask task) {
    final subController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: card,
          title: Text('Add Subtask', style: TextStyle(color: text)),
          content: TextField(
            controller: subController,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'Enter subtask...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (subController.text.trim().isEmpty) return;

                setState(() {
                  task.subtasks.add({
                    'title': subController.text.trim(),
                    'done': false,
                  });
                });

                saveTasks();
                Navigator.pop(dialogContext);
                message('Subtask added!');
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    ).then((_) => subController.dispose());
  }

  void toggleSubtask(TodoTask task, int index, bool value) {
    setState(() {
      task.subtasks[index]['done'] = value;

      if (task.subtasks.isNotEmpty &&
          task.subtasks.every((s) => s['done'] == true)) {
        task.completed = true;
      } else {
        task.completed = false;
      }
    });

    saveTasks();
  }

  void deleteSubtask(TodoTask task, int index) {
    setState(() {
      task.subtasks.removeAt(index);
    });

    saveTasks();
  }

  // ================= EDIT TASK =================

  Future<void> editTask(TodoTask task) async {
    final title = TextEditingController(text: task.title);
    final description = TextEditingController(text: task.description);

    String newPriority = task.priority;
    String newCategory = task.category;
    DateTime newDate = task.dueDate;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              backgroundColor: card,
              title: Text('Edit Task', style: TextStyle(color: text)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: title,
                      decoration: const InputDecoration(
                        labelText: 'Task title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: description,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: newPriority,
                      decoration: const InputDecoration(labelText: 'Priority'),
                      items: priorities.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            newPriority = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: newCategory,
                      decoration: const InputDecoration(labelText: 'Category'),
                      items: categories.map((value) {
                        return DropdownMenuItem(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          dialogSetState(() {
                            newCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final date = await chooseDate(newDate);

                        if (date != null) {
                          dialogSetState(() {
                            newDate = date;
                          });
                        }
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(formatDate(newDate)),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (title.text.trim().isEmpty) return;

                    setState(() {
                      task.title = title.text.trim();
                      task.description = description.text.trim();
                      task.priority = newPriority;
                      task.category = newCategory;
                      task.dueDate = newDate;
                    });

                    saveTasks();
                    Navigator.pop(dialogContext);
                    message('Task updated!');
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        );
      },
    );

    title.dispose();
    description.dispose();
  }

  // ================= TASK ACTIONS =================

  void toggleTask(TodoTask task) {
    setState(() {
      task.completed = !task.completed;

      if (task.completed) {
        for (final subtask in task.subtasks) {
          subtask['done'] = true;
        }
      }
    });

    saveTasks();
    message(task.completed ? 'Task completed!' : 'Task reopened!');
  }

  void toggleFavorite(TodoTask task) {
    setState(() {
      task.favorite = !task.favorite;
    });

    saveTasks();
  }

  void duplicateTask(TodoTask task) {
    setState(() {
      tasks.insert(
        0,
        TodoTask(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          title: '${task.title} Copy',
          description: task.description,
          category: task.category,
          priority: task.priority,
          createdAt: DateTime.now(),
          dueDate: task.dueDate,
          subtasks: task.subtasks.map((s) {
            return {'title': s['title'], 'done': false};
          }).toList(),
        ),
      );
    });

    saveTasks();
    message('Task duplicated!');
  }

  void archiveTask(TodoTask task) {
    setState(() {
      task.archived = !task.archived;
    });

    saveTasks();
    message(task.archived ? 'Task archived!' : 'Task restored!');
  }

  void deleteTask(TodoTask task) {
    final index = tasks.indexOf(task);
    if (index == -1) return;

    setState(() {
      tasks.remove(task);
    });

    saveTasks();

    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: const Text('Task deleted!'),
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () {
              setState(() {
                tasks.insert(index.clamp(0, tasks.length).toInt(), task);
              });

              saveTasks();
            },
          ),
        ),
      );
  }

  // ================= BULK ACTIONS =================

  void selectTask(TodoTask task) {
    setState(() {
      if (selectedIds.contains(task.id)) {
        selectedIds.remove(task.id);
      } else {
        selectedIds.add(task.id);
      }

      selectionMode = selectedIds.isNotEmpty;
    });
  }

  void selectAll() {
    setState(() {
      if (selectedIds.length == filteredTasks.length) {
        selectedIds.clear();
        selectionMode = false;
      } else {
        selectedIds = filteredTasks.map((e) => e.id).toList();
        selectionMode = true;
      }
    });
  }

  void bulkComplete() {
    setState(() {
      for (final task in tasks) {
        if (selectedIds.contains(task.id)) {
          task.completed = true;

          for (final subtask in task.subtasks) {
            subtask['done'] = true;
          }
        }
      }

      selectedIds.clear();
      selectionMode = false;
    });

    saveTasks();
    message('Selected tasks completed!');
  }

  void bulkDelete() {
    if (selectedIds.isEmpty) return;

    setState(() {
      tasks.removeWhere((task) => selectedIds.contains(task.id));

      selectedIds.clear();
      selectionMode = false;
    });

    saveTasks();
    message('Selected tasks deleted!');
  }

  // ================= EXPORT BACKUP =================

  Future<void> exportTasks() async {
    final data = jsonEncode(tasks.map((task) => task.toJson()).toList());

    await Clipboard.setData(ClipboardData(text: data));

    message('JSON backup copied to clipboard!');
  }

  // ================= IMPORT BACKUP =================

  Future<void> importTasks() async {
    final clipboard = await Clipboard.getData('text/plain');

    if (clipboard?.text == null) {
      message('No backup found!', error: true);
      return;
    }

    try {
      final decoded = jsonDecode(clipboard!.text!) as List;

      final imported = decoded.map((item) {
        return TodoTask.fromJson(Map<String, dynamic>.from(item));
      }).toList();

      setState(() {
        tasks = imported;
      });

      await saveTasks();
      message('Backup restored successfully!');
    } catch (e) {
      message('Invalid backup data!', error: true);
    }
  }

  // ================= FILTER & SORT =================

  List<TodoTask> get filteredTasks {
    final search = searchController.text.toLowerCase();

    final result = tasks.where((task) {
      final isCorrectPage = archiveMode ? task.archived : !task.archived;

      final matchesSearch =
          task.title.toLowerCase().contains(search) ||
          task.description.toLowerCase().contains(search) ||
          task.category.toLowerCase().contains(search);

      final matchesFilter =
          filter == 'All' ||
          (filter == 'Pending' && !task.completed) ||
          (filter == 'Completed' && task.completed) ||
          (filter == 'Overdue' && !task.completed && isOverdue(task.dueDate));

      final matchesFavorite = !favoritesOnly || task.favorite;

      return isCorrectPage &&
          matchesSearch &&
          matchesFilter &&
          matchesFavorite &&
          (selectionMode || true);
    }).toList();

    switch (sort) {
      case 'Newest':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;

      case 'Oldest':
        result.sort((a, b) => a.createdAt.compareTo(b.createdAt));
        break;

      case 'Priority':
        int rank(String value) {
          return value == 'High'
              ? 1
              : value == 'Medium'
              ? 2
              : 3;
        }

        result.sort((a, b) => rank(a.priority).compareTo(rank(b.priority)));
        break;

      case 'A-Z':
        result.sort((a, b) => a.title.compareTo(b.title));
        break;

      case 'Due Date':
        result.sort((a, b) => a.dueDate.compareTo(b.dueDate));
        break;
    }

    return result;
  }

  // ================= PRIORITY COLOR =================

  Color priorityColor(String value) {
    switch (value) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      default:
        return Colors.green;
    }
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          selectionMode
              ? '${selectedIds.length} Selected'
              : archiveMode
              ? 'Archived Tasks'
              : 'Pro Todo Manager',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (selectionMode) ...[
            IconButton(
              onPressed: selectAll,
              icon: const Icon(Icons.select_all),
              tooltip: 'Select All',
            ),
            IconButton(
              onPressed: bulkComplete,
              icon: const Icon(Icons.done_all),
              tooltip: 'Complete Selected',
            ),
            IconButton(
              onPressed: bulkDelete,
              icon: const Icon(Icons.delete),
              tooltip: 'Delete Selected',
            ),
          ] else ...[
            IconButton(
              onPressed: () {
                setState(() {
                  darkMode = !darkMode;
                });
              },
              icon: Icon(darkMode ? Icons.light_mode : Icons.dark_mode),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'archive') {
                  setState(() {
                    archiveMode = !archiveMode;
                  });
                }

                if (value == 'export') exportTasks();
                if (value == 'import') importTasks();

                if (value == 'favorites') {
                  setState(() {
                    favoritesOnly = !favoritesOnly;
                  });
                }

                if (value == 'grid') {
                  setState(() {
                    gridMode = !gridMode;
                  });
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'archive',
                  child: Text('Toggle Archive'),
                ),
                const PopupMenuItem(
                  value: 'favorites',
                  child: Text('Toggle Favorites'),
                ),
                const PopupMenuItem(
                  value: 'grid',
                  child: Text('Toggle Grid/List'),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: Text('Export JSON Backup'),
                ),
                const PopupMenuItem(
                  value: 'import',
                  child: Text('Import JSON Backup'),
                ),
              ],
            ),
          ],
        ],
      ),

      body: loading
          ? Center(child: CircularProgressIndicator(color: primary))
          : SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final contentWidth = width > 1100 ? 1000.0 : width;

                  return Center(
                    child: SizedBox(
                      width: contentWidth,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 30),
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (!archiveMode) ...[
                              dashboard(),
                              const SizedBox(height: 18),
                              addTaskSection(),
                            ] else
                              archiveHeader(),

                            const SizedBox(height: 18),
                            searchSection(),
                            const SizedBox(height: 14),
                            filterSection(),
                            const SizedBox(height: 12),
                            headingSection(),
                            taskList(),
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

  // ================= DASHBOARD =================

  Widget dashboard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Productivity',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Plan smart. Work better. Achieve more.',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 20),

          Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              statCard('Total', total, Icons.list_alt),
              statCard('Done', completed, Icons.check_circle),
              statCard('Pending', pending, Icons.pending_actions),
              statCard('Overdue', overdue, Icons.warning),
              statCard('Favorites', favorites, Icons.favorite),
              statCard('Archived', archived, Icons.archive),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Completion Progress',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toInt()}%',
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
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: progress),
              duration: const Duration(milliseconds: 700),
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 11,
                  backgroundColor: Colors.white30,
                  valueColor: const AlwaysStoppedAnimation(Colors.greenAccent),
                );
              },
            ),
          ),

          const SizedBox(height: 9),

          Text(
            '$completed of $total tasks completed',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),

          const Divider(color: Colors.white30, height: 25),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtask Progress',
                style: TextStyle(color: Colors.white),
              ),
              Text(
                '$subtaskCompleted / $subtaskTotal',
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ================= STAT CARD =================

  Widget statCard(String title, int value, IconData icon) {
    return SizedBox(
      width: 105,
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 6),
            Text(
              '$value',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 21,
              ),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  // ================= ADD TASK FORM =================

  Widget addTaskSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: card,
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
            Text(
              'Create New Task',
              style: TextStyle(
                color: text,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: titleController,
              onSubmitted: (_) => addTask(),
              style: TextStyle(color: text),
              decoration: const InputDecoration(
                hintText: 'Task title...',
                prefixIcon: Icon(Icons.edit_note),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descriptionController,
              maxLines: 2,
              style: TextStyle(color: text),
              decoration: const InputDecoration(
                hintText: 'Task description...',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            LayoutBuilder(
              builder: (context, constraints) {
                final isSmall = constraints.maxWidth < 420;

                Widget priorityDropdown = dropdown(
                  'Priority',
                  priority,
                  priorities,
                  (value) {
                    setState(() => priority = value!);
                  },
                );

                Widget categoryDropdown = dropdown(
                  'Category',
                  category,
                  categories,
                  (value) {
                    setState(() => category = value!);
                  },
                );

                if (isSmall) {
                  return Column(
                    children: [
                      priorityDropdown,
                      const SizedBox(height: 10),
                      categoryDropdown,
                    ],
                  );
                }

                return Row(
                  children: [
                    Expanded(child: priorityDropdown),
                    const SizedBox(width: 10),
                    Expanded(child: categoryDropdown),
                  ],
                );
              },
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: () async {
                final date = await chooseDate(dueDate);

                if (date != null) {
                  setState(() => dueDate = date);
                }
              },
              icon: const Icon(Icons.calendar_month),
              label: Text('Due: ${formatDate(dueDate)}'),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 49,
              child: ElevatedButton.icon(
                onPressed: addTask,
                icon: const Icon(Icons.add),
                label: const Text(
                  'Create Task',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primary,
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

  // ================= DROPDOWN =================

  Widget dropdown(
    String label,
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      dropdownColor: card,
      style: TextStyle(color: text),
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: background,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }

  // ================= ARCHIVE HEADER =================

  Widget archiveHeader() {
    return Container(
      padding: const EdgeInsets.all(22),
      color: primary,
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.archive, color: Colors.white, size: 35),
          SizedBox(height: 10),
          Text(
            'Archived Tasks',
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Manage your previously archived tasks.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // ================= SEARCH =================

  Widget searchSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        controller: searchController,
        onChanged: (_) => setState(() {}),
        style: TextStyle(color: text),
        decoration: InputDecoration(
          hintText: 'Search title, description, category...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchController.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() => searchController.clear());
                  },
                  icon: const Icon(Icons.close),
                )
              : null,
          filled: true,
          fillColor: card,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  // ================= FILTER =================

  Widget filterSection() {
    return SizedBox(
      height: 43,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 14),
        scrollDirection: Axis.horizontal,
        children: filters.map((value) {
          final active = filter == value;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(value),
              selected: active,
              onSelected: (_) {
                setState(() => filter = value);
              },
              selectedColor: primary,
              backgroundColor: card,
              labelStyle: TextStyle(
                color: active ? Colors.white : text,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ================= TASK HEADING =================

  Widget headingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '${archiveMode ? "Archived" : "My Tasks"} '
              '(${filteredTasks.length})',
              style: TextStyle(
                color: text,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          DropdownButton<String>(
            value: sort,
            dropdownColor: card,
            underline: const SizedBox(),
            style: TextStyle(color: text, fontSize: 12),
            items: ['Newest', 'Oldest', 'Priority', 'A-Z', 'Due Date'].map((
              value,
            ) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() => sort = value);
              }
            },
          ),
        ],
      ),
    );
  }

  // ================= TASK LIST =================

  Widget taskList() {
    final result = filteredTasks;

    if (result.isEmpty) {
      return SizedBox(
        height: 270,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 70, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No Tasks Found',
                style: TextStyle(
                  color: text,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Add a task or change your filters.',
                style: TextStyle(color: muted),
              ),
            ],
          ),
        ),
      );
    }

    if (gridMode) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final columns = constraints.maxWidth > 650 ? 2 : 1;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: result.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 10,
                mainAxisSpacing: 8,
                mainAxisExtent: 260,
              ),
              itemBuilder: (context, index) {
                return taskCard(result[index]);
              },
            );
          },
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: result.length,
        itemBuilder: (context, index) {
          final task = result[index];

          return Dismissible(
            key: ValueKey(task.id),
            direction: archiveMode
                ? DismissDirection.none
                : DismissDirection.endToStart,
            background: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.only(right: 20),
              alignment: Alignment.centerRight,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Icon(Icons.delete, color: Colors.white, size: 28),
            ),
            onDismissed: (_) => deleteTask(task),
            child: taskCard(task),
          );
        },
      ),
    );
  }

  // ================= TASK CARD =================

  Widget taskCard(TodoTask task) {
    final selected = selectedIds.contains(task.id);

    final subTotal = task.subtasks.length;

    final subDone = task.subtasks.where((s) => s['done'] == true).length;

    final subProgress = subTotal == 0 ? 0.0 : subDone / subTotal;

    return Card(
      color: selected ? primary.withOpacity(0.10) : card,
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(17),
        side: BorderSide(color: selected ? primary : Colors.transparent),
      ),
      child: Padding(
        padding: const EdgeInsets.all(13),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (selectionMode)
                  Checkbox(value: selected, onChanged: (_) => selectTask(task))
                else
                  Checkbox(
                    value: task.completed,
                    activeColor: Colors.green,
                    onChanged: (_) => toggleTask(task),
                  ),

                Expanded(
                  child: GestureDetector(
                    onLongPress: () => selectTask(task),
                    child: Text(
                      task.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: task.completed ? Colors.grey : text,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ),

                IconButton(
                  onPressed: () => toggleFavorite(task),
                  icon: Icon(
                    task.favorite ? Icons.favorite : Icons.favorite_border,
                    color: task.favorite ? Colors.pink : muted,
                  ),
                ),

                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') editTask(task);
                    if (value == 'delete') deleteTask(task);
                    if (value == 'duplicate') duplicateTask(task);
                    if (value == 'subtask') addSubtask(task);
                    if (value == 'archive') archiveTask(task);
                    if (value == 'select') selectTask(task);
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit Task'),
                    ),
                    const PopupMenuItem(
                      value: 'subtask',
                      child: Text('Add Subtask'),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Text('Duplicate'),
                    ),
                    PopupMenuItem(
                      value: 'archive',
                      child: Text(task.archived ? 'Restore' : 'Archive'),
                    ),
                    const PopupMenuItem(
                      value: 'select',
                      child: Text('Select Task'),
                    ),
                    const PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),

            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 48),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                tag(task.category, Colors.blue),
                tag('${task.priority} Priority', priorityColor(task.priority)),
                tag(
                  dueLabel(task.dueDate),
                  isOverdue(task.dueDate) && !task.completed
                      ? Colors.red
                      : Colors.purple,
                ),
              ],
            ),

            if (subTotal > 0) ...[
              const SizedBox(height: 12),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtasks',
                    style: TextStyle(
                      color: text,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '$subDone / $subTotal',
                    style: TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              LinearProgressIndicator(
                value: subProgress,
                backgroundColor: background,
                color: Colors.green,
                minHeight: 6,
                borderRadius: BorderRadius.circular(10),
              ),

              const SizedBox(height: 6),

              ...List.generate(task.subtasks.length, (index) {
                final subtask = task.subtasks[index];

                return Row(
                  children: [
                    SizedBox(
                      height: 32,
                      width: 32,
                      child: Checkbox(
                        value: subtask['done'] == true,
                        onChanged: (value) {
                          toggleSubtask(task, index, value ?? false);
                        },
                      ),
                    ),
                    Expanded(
                      child: Text(
                        subtask['title'],
                        style: TextStyle(
                          color: muted,
                          fontSize: 12,
                          decoration: subtask['done'] == true
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      onPressed: () => deleteSubtask(task, index),
                      icon: const Icon(
                        Icons.close,
                        size: 17,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              }),
            ],

            const SizedBox(height: 10),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: muted),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    'Created ${formatDate(task.createdAt)}',
                    style: TextStyle(color: muted, fontSize: 10),
                  ),
                ),
                if (task.completed)
                  const Text(
                    'COMPLETED',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ================= TAG =================

  Widget tag(String title, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
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

  // ================= DISPOSE =================

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    searchController.dispose();
    subtaskController.dispose();
    super.dispose();
  }
}
