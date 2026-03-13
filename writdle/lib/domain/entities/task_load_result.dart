import 'package:writdle/domain/entities/task_model.dart';

class TaskLoadResult {
  const TaskLoadResult({
    required this.tasks,
    this.isFromCache = false,
  });

  final List<TaskModel> tasks;
  final bool isFromCache;
}
