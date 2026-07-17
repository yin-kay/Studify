import '../models/study_task.dart';

bool isSameDate(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
DateTime startOfWeek(DateTime date) => DateTime(date.year, date.month, date.day)
    .subtract(Duration(days: date.weekday - 1));
int priorityWeight(TaskPriority value) => switch (value) {
      TaskPriority.high => 3,
      TaskPriority.medium => 2,
      TaskPriority.low => 1
    };
