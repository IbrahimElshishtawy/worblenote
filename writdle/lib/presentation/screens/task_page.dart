import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/utils/date_formatter.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/widgets/task_card.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.selectedDay});

  final DateTime selectedDay;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String get _dayKey => DateFormatter.toDayKey(widget.selectedDay);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksCubit>().fetchTasks(_dayKey);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _showAddEditDialog([TaskModel? task]) async {
    _titleController.text = task?.title ?? '';
    _descController.text = task?.description ?? '';

    await showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(task == null ? 'Add Task' : 'Edit Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Description (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final title = _titleController.text.trim();
              if (title.isEmpty) {
                return;
              }

              await context.read<TasksCubit>().saveTask(
                id: task?.id,
                title: title,
                description: _descController.text.trim(),
                date: _dayKey,
                completed: task?.completed ?? false,
                createdAt: task?.createdAt,
              );
              if (!mounted) {
                return;
              }
              context.read<AppNotificationCubit>().show(
                task == null ? 'Task added' : 'Task updated',
                type: AppNotificationType.success,
                localTitle: 'Task Update',
                showLocalNotification: true,
              );
              Navigator.pop(context);
            },
            child: Text(task == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final todo = state.tasks.where((task) => !task.completed).toList();
          final done = state.tasks.where((task) => task.completed).toList();

          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 80),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (todo.isNotEmpty) ...[
                  const Text(
                    'Current Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...todo.map(
                    (task) => TaskCard(
                      task: task,
                      onToggle: () async {
                        await context.read<TasksCubit>().toggleTaskCompletion(
                          task,
                          _dayKey,
                        );
                        if (!mounted) {
                          return;
                        }
                        context.read<AppNotificationCubit>().show(
                          task.completed ? 'Task reopened' : 'Task completed',
                          type: AppNotificationType.success,
                          localTitle: 'Task Progress',
                          showLocalNotification: true,
                        );
                      },
                      onEdit: () => _showAddEditDialog(task),
                      onDelete: () async {
                        await context.read<TasksCubit>().deleteTask(task.id, _dayKey);
                        if (!mounted) {
                          return;
                        }
                        context.read<AppNotificationCubit>().show(
                          'Task deleted',
                          type: AppNotificationType.info,
                        );
                      },
                    ),
                  ),
                ],
                if (done.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Completed Tasks',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...done.map(
                    (task) => TaskCard(
                      task: task,
                      onToggle: () async {
                        await context.read<TasksCubit>().toggleTaskCompletion(
                          task,
                          _dayKey,
                        );
                      },
                      onEdit: () => _showAddEditDialog(task),
                      onDelete: () async {
                        await context.read<TasksCubit>().deleteTask(task.id, _dayKey);
                      },
                    ),
                  ),
                ],
                if (todo.isEmpty && done.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No tasks yet for this day.'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
