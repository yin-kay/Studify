import 'package:flutter/material.dart';

import '../models/study_task.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onCompletedChanged,
    super.key,
  });

  final StudyTask task;
  final Future<StudyTask?> Function(StudyTask task) onEdit;
  final ValueChanged<StudyTask> onDelete;
  final void Function(StudyTask task, bool completed) onCompletedChanged;

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  late StudyTask _task;

  @override
  void initState() {
    super.initState();
    _task = widget.task;
  }

  Color get _priorityColor => switch (_task.priority) {
        TaskPriority.high => const Color(0xFFFF5A65),
        TaskPriority.medium => const Color(0xFFFFB648),
        TaskPriority.low => const Color(0xFF45B98C),
      };

  String get _priorityLabel => '${_task.priority.name[0].toUpperCase()}'
      '${_task.priority.name.substring(1)} priority';

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      appBar: AppBar(
        backgroundColor: colors.surface,
        surfaceTintColor: colors.surface,
        title: const Text(
          'Task Detail',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: 'Edit task',
            onPressed: _editTask,
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            tooltip: 'Delete task',
            onPressed: _confirmDelete,
            icon: const Icon(Icons.delete_outline_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: colors.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _task.title,
                    style: TextStyle(
                      fontSize: 28,
                      height: 1.12,
                      fontWeight: FontWeight.w900,
                      color: _task.completed
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                      decoration:
                          _task.completed ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Badge(
                        label: _task.course,
                        color: const Color(0xFF5B5CE2),
                      ),
                      _Badge(label: _priorityLabel, color: _priorityColor),
                      _Badge(
                        label: _statusLabel(_task.status),
                        color: const Color(0xFF77778B),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),
                  const _SectionLabel(
                    icon: Icons.event_rounded,
                    label: 'Deadline',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formattedDeadline(_task.dueDate),
                    style: TextStyle(
                      fontSize: 17,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: colors.onSurface,
                    ),
                  ),
                  const SizedBox(height: 26),
                  const _SectionLabel(
                    icon: Icons.notes_rounded,
                    label: 'Description',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _task.description.isEmpty
                        ? 'No description was added for this task.'
                        : _task.description,
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: _task.description.isEmpty
                          ? colors.onSurfaceVariant
                          : colors.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _toggleCompleted,
              style: FilledButton.styleFrom(
                backgroundColor: _task.completed
                    ? const Color(0xFF45B98C)
                    : const Color(0xFF5B5CE2),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              icon: Icon(
                _task.completed ? Icons.undo_rounded : Icons.task_alt_rounded,
              ),
              label: Text(
                _task.completed ? 'Mark as To Do' : 'Mark as Completed',
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _editTask() async {
    final savedTask = await widget.onEdit(_task);
    if (savedTask != null && mounted) setState(() => _task = savedTask);
  }

  void _toggleCompleted() {
    final completed = !_task.completed;
    widget.onCompletedChanged(_task, completed);
    setState(() {});
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete task?'),
        content: Text('“${_task.title}” will be permanently removed.'),
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
    if (shouldDelete == true && mounted) {
      widget.onDelete(_task);
      Navigator.pop(context);
    }
  }

  String _formattedDeadline(DateTime date) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final time = TimeOfDay.fromDateTime(date).format(context);
    return '${weekdays[date.weekday - 1]}, ${date.day} '
        '${months[date.month - 1]} ${date.year}\n$time';
  }

  String _statusLabel(TaskStatus status) => switch (status) {
        TaskStatus.toDo => 'Not started',
        TaskStatus.inProgress => 'In progress',
        TaskStatus.done => 'Done',
      };
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(.11),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF77778B)),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: Color(0xFF77778B),
          ),
        ),
      ],
    );
  }
}
