import 'package:flutter/material.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TasksProvider with ChangeNotifier {
  final ITaskRepository _repository;
  List<TaskModel> _tasks = [];
  bool _isLoading = false;

  TasksProvider(this._repository);

  List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;

  Future<void> fetchTasks(String date) async {
    _isLoading = true;
    notifyListeners();

    try {
      _tasks = await _repository.getTasks(date);
    } catch (e) {
      print('Error fetching tasks: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTask(String title, String description, String date) async {
    final task = TaskModel(
      id: '',
      title: title,
      description: description,
      completed: false,
      date: date,
      createdAt: DateTime.now(),
    );
    await _repository.addTask(task);
    await fetchTasks(date);
  }

  Future<void> toggleTaskCompletion(TaskModel task, String date) async {
    final updatedTask = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      completed: !task.completed,
      date: task.date,
      createdAt: task.createdAt,
    );
    await _repository.updateTask(updatedTask);
    await fetchTasks(date);
  }

  Future<void> deleteTask(String id, String date) async {
    await _repository.deleteTask(id, date);
    await fetchTasks(date);
  }
}
