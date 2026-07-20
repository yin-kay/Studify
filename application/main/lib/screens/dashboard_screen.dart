import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../providers/task_provider.dart';
import '../widgets/summary_card.dart';
import '../widgets/task_card.dart';
import 'calendar_screen.dart';
import 'task_form_screen.dart';
import 'task_list_screen.dart';
import 'task_detail_screen.dart';
import 'settings_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    required this.darkMode,
    required this.onDarkModeChanged,
    super.key,
  });

  final bool darkMode;
  final ValueChanged<bool> onDarkModeChanged;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  late final PageController _pageController;
  List<StudyTask> get _tasks => context.read<TaskProvider>().tasks;

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => const Color(0xFFFF5A65),
        TaskPriority.medium => const Color(0xFFFFB648),
        TaskPriority.low => const Color(0xFF45B98C),
      };

  String _priorityName(TaskPriority priority) =>
      '${priority.name[0].toUpperCase()}${priority.name.substring(1)}';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<TaskProvider>();
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: SafeArea(
        child: ClipRect(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            clipBehavior: Clip.hardEdge,
            onPageChanged: (index) {
              if (index != _currentIndex) {
                setState(() => _currentIndex = index);
              }
            },
            children: _buildPages(),
          ),
        ),
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: _currentIndex == 3
          ? null
          : FloatingActionButton(
              onPressed: _showTaskForm,
              backgroundColor: const Color(0xFF5B5CE2),
              foregroundColor: Colors.white,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(Icons.add_rounded, size: 30),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _selectPage,
        animationDuration: const Duration(milliseconds: 320),
        backgroundColor: colors.surface,
        indicatorColor: colors.primaryContainer,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.checklist_outlined),
            selectedIcon: Icon(Icons.checklist_rounded),
            label: 'Tasks',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month_rounded),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPages() {
    return [
      _buildDashboard(),
      TaskListScreen(
        tasks: _tasks,
        onTaskChanged: _setTaskCompleted,
        onEditTask: _showTaskForm,
        onOpenTask: _showTaskDetail,
        onDeleteTask: _confirmDeleteTask,
      ),
      CalendarScreen(
        tasks: _tasks,
        onTaskChanged: _setTaskCompleted,
        onEditTask: _showTaskForm,
        onOpenTask: _showTaskDetail,
        onDeleteTask: _confirmDeleteTask,
      ),
      SettingsScreen(
        darkMode: widget.darkMode,
        onDarkModeChanged: widget.onDarkModeChanged,
      ),
    ];
  }

  void _selectPage(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 360),
      curve: Curves.easeInOutCubic,
    );
  }

  Widget _buildDashboard() {
    final colors = Theme.of(context).colorScheme;
    final provider = context.read<TaskProvider>();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
          sliver: SliverList.list(
            children: [
              Text(
                'Studify',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1.1,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Hello, student! (9:41 AM)',
                      style: TextStyle(
                        color: colors.onSurfaceVariant,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    _formattedDate(),
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              LayoutBuilder(
                builder: (context, constraints) {
                  final gap = constraints.maxWidth < 360 ? 6.0 : 10.0;
                  return IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: SummaryCard(
                            value: '${provider.dueTodayCount}',
                            label: 'Due\nToday',
                            color: const Color(0xFF5B5CE2),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: SummaryCard(
                            value: '${provider.overdueCount}',
                            label: 'Overdue',
                            color: const Color(0xFFFF5A65),
                          ),
                        ),
                        SizedBox(width: gap),
                        Expanded(
                          child: SummaryCard(
                            value: '${provider.completedThisWeekCount}',
                            label: 'Done This\nWeek',
                            color: const Color(0xFF45B98C),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's focus",
                    style: TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                      color: colors.onSurface,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
        if (_tasks.isEmpty)
          const SliverFillRemaining(
            child: Center(child: Text('No tasks yet. Tap + to add one!')),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.separated(
              itemCount: _tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) => TaskCard(
                task: _tasks[index],
                color: _priorityColor(_tasks[index].priority),
                priorityName: _priorityName(_tasks[index].priority),
                onChanged: (value) =>
                    _setTaskCompleted(_tasks[index], value ?? false),
                onEdit: () => _showTaskForm(_tasks[index]),
                onTap: () => _showTaskDetail(_tasks[index]),
                onDelete: () => _confirmDeleteTask(_tasks[index]),
              ),
            ),
          ),
      ],
    );
  }

  String _formattedDate() {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')} '
        '${months[now.month - 1]} ${now.year}';
  }

  Future<StudyTask?> _showTaskForm([StudyTask? existingTask]) async {
    final savedTask = await Navigator.push<StudyTask>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskFormScreen(task: existingTask),
        fullscreenDialog: true,
      ),
    );
    if (savedTask == null || !mounted) return null;

    final provider = context.read<TaskProvider>();
    final success = existingTask == null
        ? await provider.addTask(
            title: savedTask.title,
            subjectId: savedTask.subjectId,
            description: savedTask.description,
            dueDateTime: savedTask.dueDateTime,
            priority: savedTask.priority,
            status: savedTask.status,
            category: savedTask.category)
        : await provider.updateTask(savedTask);
    if (!success || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(provider.errorMessage ?? 'Could not save task.')));
      }
      return null;
    }
    return existingTask == null
        ? provider.tasks.last
        : provider.tasks.firstWhere((t) => t.id == savedTask.id);
  }

  Future<void> _showTaskDetail(StudyTask task) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailScreen(
          task: task,
          onEdit: (currentTask) => _showTaskForm(currentTask),
          onDelete: _deleteTask,
          onCompletedChanged: _setTaskCompleted,
        ),
      ),
    );
  }

  void _deleteTask(StudyTask task) {
    context.read<TaskProvider>().deleteTask(task.id);
  }

  Future<void> _confirmDeleteTask(StudyTask task) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${task.title}” will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A65),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (shouldDelete == true && mounted) _deleteTask(task);
  }

  Future<StudyTask?> _setTaskCompleted(StudyTask task, bool completed) async {
    final provider = context.read<TaskProvider>();
    final success = await provider.updateStatus(
        task.id, completed ? TaskStatus.done : TaskStatus.toDo);
    if (!success || !mounted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(
                provider.errorMessage ?? 'Could not update task status.')));
      }
      return null;
    }
    return provider.tasks.firstWhere((item) => item.id == task.id);
  }
}
