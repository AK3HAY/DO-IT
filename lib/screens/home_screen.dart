// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/screens/add_edit_task_screen.dart';
import 'package:todo_app/screens/settings_screen.dart';
import 'package:todo_app/services/hive_service.dart';
import 'package:todo_app/widgets/task_card.dart';

// ... (enum SortOption and HomeScreen StatefulWidget are unchanged) ...
enum SortOption { priority, dueDate }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}


class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final HiveService _hiveService = HiveService();
  SortOption _sortOption = SortOption.priority;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _sortTasks(List<Task> tasks) {
    tasks.sort((a, b) {
      if (_sortOption == SortOption.priority) {
        final priorityMap = {'High': 3, 'Medium': 2, 'Low': 1};
        return (priorityMap[b.priority] ?? 0)
            .compareTo(priorityMap[a.priority] ?? 0);
      } else {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      }
    });
  }

  // --- NEW CENTRALIZED DELETE METHOD ---
  void _deleteTaskAndShowSnackBar(Task task) {
    // Save a copy of the task for the "Undo" action
    final deletedTask = Task.from(task);
    _hiveService.deleteTask(task);

    // Now, use the HomeScreen's context, which is safe
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"${deletedTask.title}" deleted.'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () => _hiveService.addTask(deletedTask),
        ),
      ),
    );
  }

  Widget _buildDismissibleBackground({
    required Color color,
    required IconData icon,
    required AlignmentGeometry alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Align(
          alignment: alignment,
          child: Icon(icon, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task) {
    if (task.isCompleted) {
      return Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          // Use the centralized method
          _deleteTaskAndShowSnackBar(task);
        },
        background: _buildDismissibleBackground(
          color: Colors.red.shade400,
          icon: Icons.delete_outline_rounded,
          alignment: Alignment.centerRight,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          // Pass the callback to the TaskCard
          child: TaskCard(
            task: task,
            onDelete: () => _deleteTaskAndShowSnackBar(task),
          ),
        ),
      );
    } else {
      return Dismissible(
        key: ValueKey(task.id),
        direction: DismissDirection.startToEnd,
        confirmDismiss: (direction) async {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEditTaskScreen(task: task),
            ),
          );
          return false;
        },
        background: _buildDismissibleBackground(
          color: Theme.of(context).primaryColor,
          icon: Icons.edit_rounded,
          alignment: Alignment.centerLeft,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: TaskCard(task: task), // No onDelete needed for pending tasks
        ),
      );
    }
  }

  // ... (the rest of the HomeScreen build method is unchanged) ...
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: _hiveService.getTasksBox().listenable(),
        builder: (context, box, _) {
          List<Task> allTasks = box.values.toList();
          List<Task> pendingTasks =
              allTasks.where((task) => !task.isCompleted).toList();
          List<Task> completedTasks =
              allTasks.where((task) => task.isCompleted).toList();

          _sortTasks(pendingTasks);
          _sortTasks(completedTasks);

          return NestedScrollView(
            headerSliverBuilder:
                (BuildContext context, bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(
                  title: const Text('My Tasks'),
                  titleTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 26,
                    color: theme.textTheme.titleLarge?.color,
                  ),
                  pinned: true,
                  floating: true,
                  snap: true,
                  forceElevated: innerBoxIsScrolled,
                  backgroundColor: isDarkMode
                      ? theme.scaffoldBackgroundColor.withAlpha(240)
                      : theme.scaffoldBackgroundColor.withAlpha(230),
                  surfaceTintColor: Colors.transparent,
                  systemOverlayStyle: SystemUiOverlayStyle(
                    statusBarColor: Colors.transparent,
                    statusBarIconBrightness:
                        isDarkMode ? Brightness.light : Brightness.dark,
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.search_rounded),
                      tooltip: 'Search Tasks',
                      onPressed: () {
                        showSearch(
                            context: context, delegate: TaskSearchDelegate());
                      },
                    ),
                    PopupMenuButton<SortOption>(
                      icon: const Icon(Icons.sort_rounded),
                      tooltip: 'Sort Tasks',
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      onSelected: (option) {
                        setState(() {
                          _sortOption = option;
                        });
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: SortOption.priority,
                          child: Row(
                            children: [
                              if (_sortOption == SortOption.priority)
                                Icon(Icons.check, color: theme.primaryColor)
                              else
                                const SizedBox(width: 24),
                              const SizedBox(width: 8),
                              const Text('Sort by Priority'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: SortOption.dueDate,
                          child: Row(
                            children: [
                              if (_sortOption == SortOption.dueDate)
                                Icon(Icons.check, color: theme.primaryColor)
                              else
                                const SizedBox(width: 24),
                              const SizedBox(width: 8),
                              const Text('Sort by Due Date'),
                            ],
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const SettingsScreen()));
                      },
                    ),
                  ],
                  bottom: TabBar(
                    controller: _tabController,
                    indicatorColor: theme.primaryColor,
                    indicatorWeight: 3.0,
                    indicatorSize: TabBarIndicatorSize.label,
                    labelColor: theme.primaryColor,
                    unselectedLabelColor: Colors.grey.shade500,
                    labelStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                    unselectedLabelStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.normal),
                    tabs: [
                      Tab(text: 'Pending (${pendingTasks.length})'),
                      Tab(text: 'Completed (${completedTasks.length})'),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList(
                  tasks: pendingTasks,
                  emptyMessage: 'No pending tasks. Great job!',
                  emptyIcon: Icons.check_circle_outline_rounded,
                ),
                _buildTaskList(
                  tasks: completedTasks,
                  emptyMessage: 'No tasks completed yet.',
                  emptyIcon: Icons.history_rounded,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'add-edit-fab',
        onPressed: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddEditTaskScreen()),
          );
        },
        tooltip: 'Add New Task',
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Task'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildTaskList({
    required List<Task> tasks,
    required String emptyMessage,
    required IconData emptyIcon,
  }) {
    if (tasks.isEmpty) {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: EmptyStateWidget(
          key: ValueKey(emptyMessage),
          message: emptyMessage,
          icon: emptyIcon,
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return AnimatedListItem(
          index: index,
          child: _buildTaskItem(task),
        );
      },
    );
  }
}

// The rest of the file (TaskSearchDelegate, EmptyStateWidget, AnimatedListItem) is unchanged
class TaskSearchDelegate extends SearchDelegate<Task> {
  final HiveService _hiveService = HiveService();

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: theme.primaryIconTheme,
        titleTextStyle: theme.textTheme.titleLarge,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: InputBorder.none,
        hintStyle: TextStyle(
          fontWeight: FontWeight.normal,
          color: theme.hintColor,
        ),
      ),
    );
  }

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear_rounded),
          tooltip: 'Clear',
          onPressed: () => query = '',
        )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_rounded),
      tooltip: 'Back',
      onPressed: () =>
          close(context, Task(id: '', title: '', createdAt: DateTime.now())),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    return ValueListenableBuilder<Box<Task>>(
      valueListenable: _hiveService.getTasksBox().listenable(),
      builder: (context, box, _) {
        final results = query.isEmpty
            ? <Task>[]
            : box.values
                .where((task) =>
                    task.title.toLowerCase().contains(query.toLowerCase()))
                .toList();

        if (query.isEmpty) {
          return const EmptyStateWidget(
            message: 'Search for your tasks by title',
            icon: Icons.search,
          );
        }

        if (results.isEmpty) {
          return const EmptyStateWidget(
            message: 'No tasks found matching your search',
            icon: Icons.search_off_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final task = results[index];
            final homeScreenState =
                context.findAncestorStateOfType<_HomeScreenState>();

            return AnimatedListItem(
              index: index,
              child: homeScreenState?._buildTaskItem(task) ??
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: TaskCard(task: task),
                  ),
            );
          },
        );
      },
    );
  }
}

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final IconData icon;

  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 80, color: theme.disabledColor),
            const SizedBox(height: 24),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: theme.textTheme.bodyMedium?.color
                    ?.withAlpha((255 * 0.7).round()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedListItem extends StatefulWidget {
  final int index;
  final Widget child;

  const AnimatedListItem({
    super.key,
    required this.index,
    required this.child,
  });

  @override
  State<AnimatedListItem> createState() => _AnimatedListItemState();
}

class _AnimatedListItemState extends State<AnimatedListItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    Future.delayed(Duration(milliseconds: widget.index * 75), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}