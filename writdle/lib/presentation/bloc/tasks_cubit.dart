import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/local_notification_service.dart';
import 'package:writdle/domain/entities/task_load_result.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDate,
    this.isOfflineData = false,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedDate;
  final bool isOfflineData;

  int get completedTasks => tasks.where((task) => task.completed).length;

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
    String? selectedDate,
    bool? isOfflineData,
    bool clearError = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
      isOfflineData: isOfflineData ?? this.isOfflineData,
    );
  }
}

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._repository, this._profileRepository)
      : super(const TasksState());

  final ITaskRepository _repository;
  final IProfileRepository _profileRepository;

  Future<void> fetchTasks(String date) async {
    emit(state.copyWith(isLoading: true, selectedDate: date, clearError: true));
    try {
      final TaskLoadResult result = await _repository.getTasks(date);
      emit(
        state.copyWith(
          tasks: result.tasks,
          isLoading: false,
          selectedDate: date,
          isOfflineData: result.isFromCache,
        ),
      );
      await _syncCompletedStats(result.tasks);
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load tasks',
          selectedDate: date,
          isOfflineData: false,
        ),
      );
    }
  }

  Future<void> saveTask({
    required String? id,
    required String title,
    required String description,
    required String date,
    required String category,
    required TaskPriority priority,
    DateTime? reminderAt,
    bool completed = false,
    DateTime? createdAt,
    int? notificationId,
  }) async {
    final generatedNotificationId = reminderAt != null
        ? (notificationId ?? DateTime.now().millisecondsSinceEpoch.remainder(1000000000))
        : notificationId;

    final task = TaskModel(
      id: id ?? '',
      title: title,
      description: description,
      completed: completed,
      date: date,
      createdAt: createdAt ?? DateTime.now(),
      reminderAt: reminderAt,
      priority: priority,
      category: category,
      notificationId: generatedNotificationId,
    );

    final savedTask = (id == null || id.isEmpty)
        ? await _repository.addTask(task)
        : await _repository.updateTask(task);

    await _syncTaskReminder(savedTask);
    await fetchTasks(date);
  }

  Future<void> toggleTaskCompletion(TaskModel task, String date) async {
    final updatedTask = task.copyWith(completed: !task.completed);
    final savedTask = await _repository.updateTask(updatedTask);
    if (savedTask.completed && savedTask.notificationId != null) {
      await LocalNotificationService.instance.cancel(savedTask.notificationId!);
    } else {
      await _syncTaskReminder(savedTask);
    }
    await fetchTasks(date);
  }

  Future<void> deleteTask(TaskModel task, String date) async {
    if (task.notificationId != null) {
      await LocalNotificationService.instance.cancel(task.notificationId!);
    }
    await _repository.deleteTask(task.id, date);
    await fetchTasks(date);
  }

  Future<void> _syncTaskReminder(TaskModel task) async {
    if (task.notificationId == null) {
      return;
    }

    await LocalNotificationService.instance.cancel(task.notificationId!);

    if (task.completed || task.reminderAt == null) {
      return;
    }

    await LocalNotificationService.instance.schedule(
      id: task.notificationId!,
      title: 'Task Reminder',
      body: task.title,
      scheduledAt: task.reminderAt!,
    );
  }

  Future<void> _syncCompletedStats(List<TaskModel> tasks) async {
    final completed = tasks.where((task) => task.completed).toList();
    final currentStats = await _profileRepository.getStats();
    await _profileRepository.saveStats(
      currentStats.copyWith(
        completedTasks: completed.length,
        completedTaskTitles: completed.map((task) => task.title).toList(),
      ),
    );
  }
}
