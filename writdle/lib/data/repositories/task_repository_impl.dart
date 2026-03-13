import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:writdle/data/datasources/task_local_cache.dart';
import 'package:writdle/domain/entities/task_load_result.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements ITaskRepository {
  TaskRepositoryImpl({TaskLocalCache? localCache})
      : _localCache = localCache ?? TaskLocalCache();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TaskLocalCache _localCache;

  @override
  Future<TaskLoadResult> getTasks(String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return const TaskLoadResult(tasks: []);
    }

    await _syncPendingOperations(userId);

    try {
      final snapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .where('date', isEqualTo: date)
          .orderBy('createdAt', descending: false)
          .get();

      final tasks = snapshot.docs
          .map((doc) => TaskModel.fromMap(doc.data(), doc.id))
          .toList();
      await _localCache.saveTasks(userId, date, tasks);
      return TaskLoadResult(tasks: tasks);
    } catch (_) {
      final cached = await _localCache.readTasks(userId, date);
      return TaskLoadResult(tasks: cached, isFromCache: true);
    }
  }

  @override
  Future<TaskModel> addTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return task;
    }

    final localId = task.id.isEmpty
        ? 'local_${DateTime.now().microsecondsSinceEpoch}'
        : task.id;
    final localTask = task.copyWith(id: localId);
    final cachedTasks = await _localCache.readTasks(userId, task.date);
    await _localCache.saveTasks(userId, task.date, [...cachedTasks, localTask]);

    try {
      final reference = await _firestore.collection('tasks').add({
        'userId': userId,
        ...task.copyWith(id: '').toMap(),
      });
      final synced = localTask.copyWith(id: reference.id);
      final refreshed = [
        ...cachedTasks,
        synced,
      ];
      await _localCache.saveTasks(userId, task.date, refreshed);
      return synced;
    } catch (_) {
      await _enqueue(userId, {
        'type': 'add',
        'date': task.date,
        'task': localTask.toJson(),
      });
      return localTask;
    }
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return task;
    }

    final cachedTasks = await _localCache.readTasks(userId, task.date);
    final updatedTasks = cachedTasks.map((item) {
      return item.id == task.id ? task : item;
    }).toList();
    await _localCache.saveTasks(userId, task.date, updatedTasks);

    if (task.id.startsWith('local_')) {
      await _replacePendingAdd(userId, task);
      return task;
    }

    try {
      await _firestore.collection('tasks').doc(task.id).update(task.toMap());
      return task;
    } catch (_) {
      await _enqueue(userId, {
        'type': 'update',
        'date': task.date,
        'task': task.toJson(),
      });
      return task;
    }
  }

  @override
  Future<void> deleteTask(String id, String date) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      return;
    }

    final cachedTasks = await _localCache.readTasks(userId, date);
    await _localCache.saveTasks(
      userId,
      date,
      cachedTasks.where((task) => task.id != id).toList(),
    );

    if (id.startsWith('local_')) {
      await _removePendingAdd(userId, id);
      return;
    }

    try {
      await _firestore.collection('tasks').doc(id).delete();
    } catch (_) {
      await _enqueue(userId, {
        'type': 'delete',
        'date': date,
        'id': id,
      });
    }
  }

  Future<void> _enqueue(String userId, Map<String, dynamic> operation) async {
    final queue = await _localCache.readQueue(userId);
    queue.add(operation);
    await _localCache.saveQueue(userId, queue);
  }

  Future<void> _replacePendingAdd(String userId, TaskModel task) async {
    final queue = await _localCache.readQueue(userId);
    final updated = queue.map((item) {
      if (item['type'] == 'add') {
        final current = TaskModel.fromJson(Map<String, dynamic>.from(item['task'] as Map));
        if (current.id == task.id) {
          return {
            'type': 'add',
            'date': task.date,
            'task': task.toJson(),
          };
        }
      }
      return item;
    }).toList();
    await _localCache.saveQueue(userId, updated);
  }

  Future<void> _removePendingAdd(String userId, String localId) async {
    final queue = await _localCache.readQueue(userId);
    queue.removeWhere((item) {
      if (item['type'] != 'add') {
        return false;
      }
      final task = TaskModel.fromJson(Map<String, dynamic>.from(item['task'] as Map));
      return task.id == localId;
    });
    await _localCache.saveQueue(userId, queue);
  }

  Future<void> _syncPendingOperations(String userId) async {
    final queue = await _localCache.readQueue(userId);
    if (queue.isEmpty) {
      return;
    }

    final pending = List<Map<String, dynamic>>.from(queue);
    final failed = <Map<String, dynamic>>[];

    for (var index = 0; index < pending.length; index++) {
      final operation = pending[index];
      try {
        final type = operation['type'] as String? ?? '';
        final date = operation['date'] as String? ?? '';

        if (type == 'add') {
          final task = TaskModel.fromJson(Map<String, dynamic>.from(operation['task'] as Map));
          final reference = await _firestore.collection('tasks').add({
            'userId': userId,
            ...task.copyWith(id: '').toMap(),
          });
          final cachedTasks = await _localCache.readTasks(userId, date);
          final synced = cachedTasks.map((item) {
            return item.id == task.id ? item.copyWith(id: reference.id) : item;
          }).toList();
          await _localCache.saveTasks(userId, date, synced);

          for (var nextIndex = index + 1; nextIndex < pending.length; nextIndex++) {
            final next = pending[nextIndex];
            if (next['task'] != null) {
              final nextTask = TaskModel.fromJson(Map<String, dynamic>.from(next['task'] as Map));
              if (nextTask.id == task.id) {
                pending[nextIndex] = {
                  ...next,
                  'task': nextTask.copyWith(id: reference.id).toJson(),
                };
              }
            }
            if (next['id'] == task.id) {
              pending[nextIndex] = {
                ...next,
                'id': reference.id,
              };
            }
          }
        } else if (type == 'update') {
          final task = TaskModel.fromJson(Map<String, dynamic>.from(operation['task'] as Map));
          await _firestore.collection('tasks').doc(task.id).update(task.toMap());
        } else if (type == 'delete') {
          final id = operation['id'] as String? ?? '';
          await _firestore.collection('tasks').doc(id).delete();
        }
      } catch (_) {
        failed.add(operation);
      }
    }

    await _localCache.saveQueue(userId, failed);
  }
}
