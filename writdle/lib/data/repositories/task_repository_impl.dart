import 'package:writdle/core/auth/local_auth_store.dart';
import 'package:writdle/data/datasources/task_local_cache.dart';
import 'package:writdle/domain/entities/task_load_result.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  TaskRepositoryImpl({TaskLocalCache? localCache})
      : _localCache = localCache ?? TaskLocalCache();

  final TaskLocalCache _localCache;

  @override
  Future<TaskLoadResult> getTasks(String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return const TaskLoadResult(tasks: []);
    }

    final tasks = await _localCache.readTasks(userId, date);
    return TaskLoadResult(tasks: tasks, isFromCache: true);
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return task;
    }

    final localId = task.id.isEmpty
        ? 'local_${DateTime.now().microsecondsSinceEpoch}'
        : task.id;
    final localTask = task.copyWith(id: localId);
    final cachedTasks = await _localCache.readTasks(userId, task.date);
    await _localCache.saveTasks(userId, task.date, [...cachedTasks, localTask]);
    return localTask;
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return task;
    }

    final cachedTasks = await _localCache.readTasks(userId, task.date);
    final updatedTasks = cachedTasks.map((item) {
      return item.id == task.id ? task : item;
    }).toList();
    await _localCache.saveTasks(userId, task.date, updatedTasks);
    return task;
  }

  @override
  Future<void> deleteTask(String id, String date) async {
    final userId = await LocalAuthStore.getCurrentUserId();
    if (userId == null) {
      return;
    }

    final cachedTasks = await _localCache.readTasks(userId, date);
    await _localCache.saveTasks(
      userId,
      date,
      cachedTasks.where((task) => task.id != id).toList(),
    );
  }
}
