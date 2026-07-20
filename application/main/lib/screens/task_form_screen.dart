import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../providers/subject_provider.dart';

class TaskFormScreen extends StatefulWidget {
  const TaskFormScreen({this.task, super.key});

  final StudyTask? task;

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  static const _noSubjectValue = '__none__';
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  String? _subjectId;
  late DateTime _dueDate;
  late TimeOfDay _dueTime;
  late TaskPriority _priority;
  late TaskStatus _status;
  late final String _initialTitle;
  late final String _initialDescription;
  String? _initialSubjectId;
  late final DateTime _initialDueDate;
  late final TimeOfDay _initialDueTime;
  late final TaskPriority _initialPriority;
  late final TaskStatus _initialStatus;
  bool _allowPop = false;
  bool _discardDialogOpen = false;

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    final task = widget.task;
    _titleController = TextEditingController(text: task?.title ?? '');
    _descriptionController = TextEditingController(
      text: task?.description ?? '',
    );
    _subjectId = task?.subjectId;
    _dueDate = DateUtils.dateOnly(task?.dueDate ?? DateTime.now());
    _dueTime = task == null
        ? const TimeOfDay(hour: 23, minute: 59)
        : TimeOfDay.fromDateTime(task.dueDate);
    _priority = task?.priority ?? TaskPriority.medium;
    _status = task?.status ?? TaskStatus.toDo;
    _initialTitle = _titleController.text;
    _initialDescription = _descriptionController.text;
    _initialSubjectId = _subjectId;
    _initialDueDate = _dueDate;
    _initialDueTime = _dueTime;
    _initialPriority = _priority;
    _initialStatus = _status;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final subjects = context.read<SubjectProvider>().subjects;
    final current = _subjectId;
    if (current != null && !subjects.any((subject) => subject.id == current)) {
      final legacyMatch = subjects.where(
        (subject) => subject.name.toLowerCase() == current.toLowerCase(),
      );
      _subjectId = legacyMatch.isEmpty ? null : legacyMatch.first.id;
      _initialSubjectId = _subjectId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subjects = context.watch<SubjectProvider>().subjects;
    return PopScope<StudyTask>(
      canPop: _allowPop,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _requestClose();
      },
      child: Scaffold(
        backgroundColor: colors.surface,
        appBar: AppBar(
          backgroundColor: colors.surface,
          surfaceTintColor: colors.surface,
          leading: IconButton(
            tooltip: 'Close',
            onPressed: _requestClose,
            icon: const Icon(Icons.close_rounded),
          ),
          title: Text(
            _isEditing ? 'Edit Task' : 'Add New Task',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
          centerTitle: true,
          actions: [
            TextButton(
              onPressed: _save,
              child: const Text(
                'Save',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            children: [
              const _FieldLabel('Task Title (Required)'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _titleController,
                autofocus: !_isEditing,
                textInputAction: TextInputAction.next,
                decoration: _inputDecoration('Enter task title'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Please enter a task title'
                    : null,
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Subject/Course'),
              const SizedBox(height: 7),
              DropdownButtonFormField<String>(
                initialValue: _subjectId ?? _noSubjectValue,
                decoration: _inputDecoration('Select subject'),
                items: [
                  const DropdownMenuItem<String>(
                    value: _noSubjectValue,
                    child: Text('None'),
                  ),
                  ...subjects.map(
                    (subject) => DropdownMenuItem(
                      value: subject.id,
                      child: Text(subject.name),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() =>
                      _subjectId = value == _noSubjectValue ? null : value);
                },
              ),
              const SizedBox(height: 18),
              const _FieldLabel('Description (Optional)'),
              const SizedBox(height: 7),
              TextFormField(
                controller: _descriptionController,
                minLines: 4,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                decoration: _inputDecoration('Add notes or details'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.calendar_today_rounded,
                      label: _formatDate(_dueDate),
                      onPressed: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _PickerButton(
                      icon: Icons.schedule_rounded,
                      label: _dueTime.format(context),
                      onPressed: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Priority'),
              const SizedBox(height: 8),
              _PrioritySelector(
                selected: _priority,
                onSelected: (priority) => setState(() => _priority = priority),
              ),
              const SizedBox(height: 20),
              const _FieldLabel('Status'),
              const SizedBox(height: 8),
              _StatusSelector(
                selected: _status,
                onSelected: (status) => setState(() => _status = status),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded),
                label: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Text(_isEditing ? 'Save changes' : 'Add task'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    final colors = Theme.of(context).colorScheme;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: colors.surfaceContainerLow,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colors.outlineVariant),
      ),
    );
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _dueDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(context: context, initialTime: _dueTime);
    if (time != null) setState(() => _dueTime = time);
  }

  String _formatDate(DateTime date) {
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final dueDateTime = DateTime(
      _dueDate.year,
      _dueDate.month,
      _dueDate.day,
      _dueTime.hour,
      _dueTime.minute,
    );

    _finishPop(
      (widget.task ??
              StudyTask(title: _titleController.text, dueDateTime: dueDateTime))
          .copyWith(
        title: _titleController.text.trim(),
        subjectId: _subjectId,
        clearSubject: _subjectId == null,
        dueLabel: _formatDueLabel(dueDateTime),
        category: widget.task?.category ?? 'Assignment',
        priority: _priority,
        dueDateTime: dueDateTime,
        description: _descriptionController.text.trim(),
        status: _status,
        completed: _status == TaskStatus.done,
      ),
    );
  }

  bool get _hasUnsavedChanges {
    return _titleController.text != _initialTitle ||
        _descriptionController.text != _initialDescription ||
        _subjectId != _initialSubjectId ||
        !DateUtils.isSameDay(_dueDate, _initialDueDate) ||
        _dueTime.hour != _initialDueTime.hour ||
        _dueTime.minute != _initialDueTime.minute ||
        _priority != _initialPriority ||
        _status != _initialStatus;
  }

  Future<void> _requestClose() async {
    if (_discardDialogOpen) return;
    if (!_hasUnsavedChanges) {
      _finishPop();
      return;
    }

    _discardDialogOpen = true;
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discard unsaved changes?'),
        content: const Text(
          'Your changes have not been saved and will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Keep editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF5A65),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    _discardDialogOpen = false;
    if (shouldDiscard == true && mounted) _finishPop();
  }

  void _finishPop([StudyTask? result]) {
    if (!mounted) return;
    setState(() => _allowPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  String _formatDueLabel(DateTime due) {
    final today = DateUtils.dateOnly(DateTime.now());
    final date = DateUtils.dateOnly(due);
    final dayLabel = DateUtils.isSameDay(date, today)
        ? 'Today'
        : DateUtils.isSameDay(date, today.add(const Duration(days: 1)))
            ? 'Tomorrow'
            : _formatDate(date);
    return '$dayLabel, ${TimeOfDay.fromDateTime(due).format(context)}';
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: colors.onSurface,
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  const _PickerButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13),
        child: Text(label, overflow: TextOverflow.ellipsis),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: colors.onSurface,
        backgroundColor: colors.surfaceContainerLow,
        side: BorderSide(color: colors.outlineVariant),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  const _PrioritySelector({required this.selected, required this.onSelected});

  final TaskPriority selected;
  final ValueChanged<TaskPriority> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: TaskPriority.values.map((priority) {
        final color = switch (priority) {
          TaskPriority.low => const Color(0xFF45B98C),
          TaskPriority.medium => const Color(0xFFFFB648),
          TaskPriority.high => const Color(0xFFFF5A65),
        };
        return Expanded(
          child: _ChoiceButton(
            label: _capitalized(priority.name),
            selected: priority == selected,
            color: color,
            onTap: () => onSelected(priority),
          ),
        );
      }).toList(),
    );
  }
}

class _StatusSelector extends StatelessWidget {
  const _StatusSelector({required this.selected, required this.onSelected});

  final TaskStatus selected;
  final ValueChanged<TaskStatus> onSelected;

  @override
  Widget build(BuildContext context) {
    const labels = {
      TaskStatus.toDo: 'Not Started',
      TaskStatus.inProgress: 'In Progress',
      TaskStatus.done: 'Done',
    };
    return Row(
      children: TaskStatus.values
          .map(
            (status) => Expanded(
              child: _ChoiceButton(
                label: labels[status]!,
                selected: status == selected,
                color: const Color(0xFF5B5CE2),
                onTap: () => onSelected(status),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ChoiceButton extends StatelessWidget {
  const _ChoiceButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(.14) : colors.surfaceContainerLow,
          border: Border.all(color: selected ? color : colors.outlineVariant),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? color : colors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

String _capitalized(String value) =>
    '${value[0].toUpperCase()}${value.substring(1)}';
