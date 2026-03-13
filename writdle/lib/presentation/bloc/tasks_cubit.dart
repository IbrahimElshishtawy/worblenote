import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/domain/repositories/profile_repository.dart';
import 'package:writdle/domain/repositories/task_repository.dart';

class TasksState {
  const TasksState({
    this.tasks = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedDate,
  });

  final List<TaskModel> tasks;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedDate;

  int get completedTasks => tasks.where((task) => task.completed).length;

  TasksState copyWith({
    List<TaskModel>? tasks,
    bool? isLoading,
    String? errorMessage,
    String? selectedDate,
    bool clearError = false,
  }) {
    return TasksState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      selectedDate: selectedDate ?? this.selectedDate,
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
      final tasks = await _repository.getTasks(date);
      emit(state.copyWith(tasks: tasks, isLoading: false, selectedDate: date));
      await _syncCompletedStats(tasks);
    } catch (_) {
      emit(
        state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load tasks',
          selectedDate: date,
        ),
      );
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

  Future<void> saveTask({
    required String? id,
    required String title,
    required String description,
    required String date,
    bool completed = false,
    DateTime? createdAt,
  }) async {
    final task = TaskModel(
      id: id ?? '',
      title: title,
      description: description,
      completed: completed,
      date: date,
      createdAt: createdAt ?? DateTime.now(),
    );

    if (id == null || id.isEmpty) {
      await _repository.addTask(task);
    } else {
      await _repository.updateTask(task);
    }
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
