import 'package:writdle/domain/entities/task_load_result.dart';
import 'package:writdle/domain/entities/task_model.dart';

abstract class ITaskRepository {
  Future<TaskLoadResult> getTasks(String date);
  Future<List<TaskModel>> getAllTasks();
  Future<TaskModel> addTask(TaskModel task);
  Future<TaskModel> updateTask(TaskModel task);
  Future<void> deleteTask(String id, String date);
}
