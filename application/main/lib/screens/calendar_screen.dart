import 'package:flutter/material.dart';

import '../models/study_task.dart';
import '../widgets/task_card.dart';

import 'package:intl/intl.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
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
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  static const _months = [
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

  @override
  void initState() {
    super.initState();
    final today = DateUtils.dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDate = today;
  }

  List<StudyTask> get _selectedTasks => widget.tasks
      .where((task) => DateUtils.isSameDay(task.dueDate, _selectedDate))
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final selectedTasks = _selectedTasks;
    final colors = Theme.of(context).colorScheme;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 12),
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
                'Hello, student! (${DateFormat('h:mm a').format(DateTime.now())})',
                style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
              ),
              const SizedBox(height: 14),
              _buildMonthSelector(),
              const SizedBox(height: 8),
              const _WeekdayHeader(),
              const SizedBox(height: 4),
              _CalendarGrid(
                visibleMonth: _visibleMonth,
                selectedDate: _selectedDate,
                tasks: widget.tasks,
                onDateSelected: (date) => setState(() => _selectedDate = date),
              ),
              const SizedBox(height: 22),
              Text(
                'Tasks due on ${_selectedDate.day} '
                '${_months[_selectedDate.month - 1]}',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        if (selectedTasks.isEmpty)
          const SliverToBoxAdapter(child: _NoTasksDue())
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 110),
            sliver: SliverList.separated(
              itemCount: selectedTasks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final task = selectedTasks[index];
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

  Widget _buildMonthSelector() {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () => _changeMonth(-1),
          icon: const Icon(Icons.chevron_left_rounded),
        ),
        Expanded(
          child: Text(
            '${_months[_visibleMonth.month - 1]} ${_visibleMonth.year}',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: () => _changeMonth(1),
          icon: const Icon(Icons.chevron_right_rounded),
        ),
      ],
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _visibleMonth = DateTime(
        _visibleMonth.year,
        _visibleMonth.month + offset,
      );
      final lastDay = DateUtils.getDaysInMonth(
        _visibleMonth.year,
        _visibleMonth.month,
      );
      _selectedDate = DateTime(
        _visibleMonth.year,
        _visibleMonth.month,
        _selectedDate.day.clamp(1, lastDay).toInt(),
      );
    });
  }

  Color _priorityColor(TaskPriority priority) => switch (priority) {
        TaskPriority.high => const Color(0xFFFF5A65),
        TaskPriority.medium => const Color(0xFFFFB648),
        TaskPriority.low => const Color(0xFF45B98C),
      };

  String _priorityName(TaskPriority priority) =>
      '${priority.name[0].toUpperCase()}${priority.name.substring(1)}';
}

class _WeekdayHeader extends StatelessWidget {
  const _WeekdayHeader();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        _WeekdayLabel('Sun'),
        _WeekdayLabel('Mon'),
        _WeekdayLabel('Tue'),
        _WeekdayLabel('Wed'),
        _WeekdayLabel('Thu'),
        _WeekdayLabel('Fri'),
        _WeekdayLabel('Sat'),
      ],
    );
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: colors.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _CalendarGrid extends StatelessWidget {
  const _CalendarGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.tasks,
    required this.onDateSelected,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final List<StudyTask> tasks;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final firstDay = DateTime(visibleMonth.year, visibleMonth.month);
    final leadingDays = firstDay.weekday % 7;
    final daysInMonth = DateUtils.getDaysInMonth(
      visibleMonth.year,
      visibleMonth.month,
    );
    final cellCount = ((leadingDays + daysInMonth + 6) ~/ 7) * 7;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
        mainAxisSpacing: 3,
        crossAxisSpacing: 3,
      ),
      itemCount: cellCount,
      itemBuilder: (context, index) {
        final day = index - leadingDays + 1;
        if (day < 1 || day > daysInMonth) return const SizedBox.shrink();

        final date = DateTime(visibleMonth.year, visibleMonth.month, day);
        final isSelected = DateUtils.isSameDay(date, selectedDate);
        final isToday = DateUtils.isSameDay(date, DateTime.now());
        final hasTasks = tasks.any(
          (task) => DateUtils.isSameDay(task.dueDate, date),
        );

        return InkWell(
          onTap: () => onDateSelected(date),
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: isSelected ? colors.primary : colors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isToday && !isSelected
                    ? colors.primary
                    : colors.outlineVariant,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected || isToday
                        ? FontWeight.w800
                        : FontWeight.w600,
                    color: isSelected ? colors.onPrimary : colors.onSurface,
                  ),
                ),
                if (hasTasks)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: isSelected ? colors.onPrimary : colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NoTasksDue extends StatelessWidget {
  const _NoTasksDue();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 110),
      child: Column(
        children: [
          Icon(
            Icons.event_available_rounded,
            size: 44,
            color: Color(0xFFB5B5C7),
          ),
          SizedBox(height: 10),
          Text(
            'No tasks due on this day',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(0xFF77778B),
            ),
          ),
        ],
      ),
    );
  }
}
