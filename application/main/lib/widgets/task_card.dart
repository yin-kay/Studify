import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/study_task.dart';
import '../providers/subject_provider.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    required this.task,
    required this.color,
    required this.priorityName,
    required this.onChanged,
    this.onEdit,
    this.onDelete,
    this.onTap,
    super.key,
  });

  final StudyTask task;
  final Color color;
  final String priorityName;
  final ValueChanged<bool?> onChanged;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final subjectName =
        context.watch<SubjectProvider>().findById(task.subjectId)?.name ??
            'None';
    return Material(
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashFactory: InkRipple.splashFactory,
        splashColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: .08),
        highlightColor:
            Theme.of(context).colorScheme.primary.withValues(alpha: .04),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Checkbox(
                  value: task.completed,
                  onChanged: onChanged,
                  activeColor: const Color(0xFF5B5CE2),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 15, 4, 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed
                                ? colors.onSurfaceVariant
                                : colors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$subjectName  \u2022  ${task.category}',
                          style: TextStyle(
                            fontSize: 12,
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 15,
                              color: colors.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                task.due,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: color.withValues(alpha: .11),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                priorityName,
                                style: TextStyle(
                                  color: color,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'edit') onEdit?.call();
                    if (value == 'delete') onDelete?.call();
                  },
                  icon: Icon(
                    Icons.more_vert_rounded,
                    color: colors.onSurfaceVariant,
                  ),
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit task')),
                    PopupMenuItem(value: 'delete', child: Text('Delete task')),
                  ],
                ),
                Container(width: 6, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
