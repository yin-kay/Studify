import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../widgets/task_card.dart';

enum _TaskSortOption { dueDate, priority }

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({
    required this.tasks,
    required this.onTaskChanged,
    required this.onEditTask,
    required this.onOpenTask,
    required this.onDeleteTask,
    super.key,
  });

  final List<StudyTask> tasks;
  final void Function(StudyTask task, bool completed) onTaskChanged;
  final ValueChanged<StudyTask> onEditTask;
  final ValueChanged<StudyTask> onOpenTask;
  final ValueChanged<StudyTask> onDeleteTask;

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  TaskStatus _selectedStatus = TaskStatus.toDo;
  _TaskSortOption _sortOption = _TaskSortOption.dueDate;

  List<StudyTask> get _filteredTasks {
    final indexedTasks = widget.tasks
        .where((task) => task.status == _selectedStatus)
        .toList(growable: false)
        .indexed
        .toList();

    indexedTasks.sort((first, second) {
      final comparison = switch (_sortOption) {
        _TaskSortOption.dueDate =>
          first.$2.dueDate.compareTo(second.$2.dueDate),
        _TaskSortOption.priority =>
          first.$2.priority.index.compareTo(second.$2.priority.index),
      };

      // Keep the original order when two tasks have the same sort value.
      return comparison != 0 ? comparison : first.$1.compareTo(second.$1);
    });

    return indexedTasks.map((entry) => entry.$2).toList(growable: false);
  }

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => const Color(0xFFFF5A65),
        TaskPriority.medium => const Color(0xFFFFB648),
        TaskPriority.low => const Color(0xFF45B98C),
      };

  String _priorityName(TaskPriority priority) =>
      '${priority.name[0].toUpperCase()}${priority.name.substring(1)}';

  @override
  Widget build(BuildContext context) {
    final tasks = _filteredTasks;
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
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
              Text(
                'Hello, student! (9:41 AM)',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 18),
              _StatusFilter(
                selectedStatus: _selectedStatus,
                onSelected: (status) =>
                    setState(() => _selectedStatus = status),
              ),
              const SizedBox(height: 12),
              _SortDropdown(
                value: _sortOption,
                onChanged: (option) => setState(() => _sortOption = option),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
        if (tasks.isEmpty)
          SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyTaskList(status: _selectedStatus),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.separated(
              itemCount: tasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = tasks[index];
                return TaskCard(
                  task: task,
                  color: _priorityColor(task.priority),
                  priorityName: _priorityName(task.priority),
                  onChanged: (value) =>
                      widget.onTaskChanged(task, value ?? false),
                  onEdit: () => widget.onEditTask(task),
                  onTap: () => widget.onOpenTask(task),
                  onDelete: () => widget.onDeleteTask(task),
                );
              },
            ),
          ),
      ],
    );
  }
}

class _SortDropdown extends StatelessWidget {
  const _SortDropdown({required this.value, required this.onChanged});

  final _TaskSortOption value;
  final ValueChanged<_TaskSortOption> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          'Sort by',
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: colors.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<_TaskSortOption>(
              key: const ValueKey('task-sort-dropdown'),
              value: value,
              borderRadius: BorderRadius.circular(12),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
              style: TextStyle(
                color: colors.onSurface,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
              onChanged: (option) {
                if (option != null) onChanged(option);
              },
              items: const [
                DropdownMenuItem(
                  value: _TaskSortOption.dueDate,
                  child: Text('Due Date'),
                ),
                DropdownMenuItem(
                  value: _TaskSortOption.priority,
                  child: Text('Priority'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({
    required this.selectedStatus,
    required this.onSelected,
  });

  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _FilterTab(
            label: 'To Do',
            status: TaskStatus.toDo,
            selectedStatus: selectedStatus,
            onSelected: onSelected,
          ),
          _FilterTab(
            label: 'In Progress',
            status: TaskStatus.inProgress,
            selectedStatus: selectedStatus,
            onSelected: onSelected,
          ),
          _FilterTab(
            label: 'Done',
            status: TaskStatus.done,
            selectedStatus: selectedStatus,
            onSelected: onSelected,
          ),
        ],
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({
    required this.label,
    required this.status,
    required this.selectedStatus,
    required this.onSelected,
  });

  final String label;
  final TaskStatus status;
  final TaskStatus selectedStatus;
  final ValueChanged<TaskStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    final isSelected = status == selectedStatus;
    final colors = Theme.of(context).colorScheme;

    return Expanded(
      child: InkWell(
        onTap: () => onSelected(status),
        borderRadius: BorderRadius.circular(11),
        child: AnimatedScale(
          scale: isSelected ? 1 : .97,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(vertical: 11),
            decoration: BoxDecoration(
              color: isSelected ? colors.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(11),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x14000000),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyTaskList extends StatelessWidget {
  const _EmptyTaskList({required this.status});

  final TaskStatus status;

  @override
  Widget build(BuildContext context) {
    final label = switch (status) {
      TaskStatus.toDo => 'to-do',
      TaskStatus.inProgress => 'in-progress',
      TaskStatus.done => 'completed',
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 100),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.task_alt_rounded,
              size: 52,
              color: Color(0xFFB5B5C7),
            ),
            const SizedBox(height: 12),
            Text(
              'No $label tasks',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF77778B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
