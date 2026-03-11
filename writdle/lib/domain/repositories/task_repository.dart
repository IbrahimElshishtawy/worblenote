import 'package:writdle/domain/entities/task_model.dart';

abstract class ITaskRepository {
  Future<List<TaskModel>> getTasks(String date);
  Future<void> addTask(TaskModel task);
  Future<void> updateTask(TaskModel task);
  Future<void> deleteTask(String id, String date);
}
