import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/utils/date_formatter.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/widgets/tasks/task_item_card.dart';
import 'package:writdle/presentation/widgets/tasks/task_editor_sheet.dart';
import 'package:writdle/presentation/widgets/tasks/task_management_header.dart';
import 'package:writdle/presentation/widgets/tasks/task_overview_cards.dart';
import 'package:writdle/presentation/widgets/tasks/task_tasks_section.dart';

class TasksPage extends StatefulWidget {
  const TasksPage({super.key, required this.selectedDay});

  final DateTime selectedDay;

  @override
  State<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends State<TasksPage> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'General';
  TaskPriority _selectedPriority = TaskPriority.medium;
  DateTime? _selectedReminder;

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

  Future<void> _pickReminder() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedReminder ?? widget.selectedDay,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime(2035),
    );
    if (pickedDate == null || !mounted) {
      return;
    }

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(
        _selectedReminder ?? DateTime.now().add(const Duration(minutes: 30)),
      ),
    );
    if (pickedTime == null) {
      return;
    }

    setState(() {
      _selectedReminder = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _openEditor([TaskModel? task]) async {
    _titleController.text = task?.title ?? '';
    _descController.text = task?.description ?? '';
    _selectedCategory = task?.category ?? 'General';
    _selectedPriority = task?.priority ?? TaskPriority.medium;
    _selectedReminder = task?.reminderAt;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) {
          return TaskEditorSheet(
            titleController: _titleController,
            descriptionController: _descController,
            selectedCategory: _selectedCategory,
            selectedPriority: _selectedPriority,
            reminderAt: _selectedReminder,
            isEditing: task != null,
            onCategoryChanged: (value) {
              setModalState(() => _selectedCategory = value);
            },
            onPriorityChanged: (value) {
              setModalState(() => _selectedPriority = value);
            },
            onPickReminder: () async {
              await _pickReminder();
              if (mounted) {
                setModalState(() {});
              }
            },
            onClearReminder: () {
              setModalState(() => _selectedReminder = null);
            },
            onSave: () async {
              final title = _titleController.text.trim();
              if (title.isEmpty) {
                context.read<AppNotificationCubit>().show(
                  'Task title is required.',
                  type: AppNotificationType.error,
                );
                return;
              }
              if (_selectedReminder != null && _selectedReminder!.isBefore(DateTime.now())) {
                context.read<AppNotificationCubit>().show(
                  'Reminder time must be in the future.',
                  type: AppNotificationType.error,
                );
                return;
              }

              await context.read<TasksCubit>().saveTask(
                    id: task?.id,
                    title: title,
                    description: _descController.text.trim(),
                    date: _dayKey,
                    completed: task?.completed ?? false,
                    createdAt: task?.createdAt,
                    reminderAt: _selectedReminder,
                    priority: _selectedPriority,
                    category: _selectedCategory,
                    notificationId: task?.notificationId,
                  );
              if (!mounted) {
                return;
              }
              context.read<AppNotificationCubit>().show(
                    _selectedReminder != null
                        ? 'Task saved and reminder scheduled.'
                        : (task == null ? 'Task added.' : 'Task updated.'),
                    type: AppNotificationType.success,
                    localTitle: 'Task Update',
                    showLocalNotification: task == null,
                  );
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          tooltip: 'Back to activity',
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              scheme.primary.withValues(alpha: 0.06),
              scheme.surface,
              scheme.secondary.withValues(alpha: 0.04),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: BlocBuilder<TasksCubit, TasksState>(
            builder: (context, state) {
              final todo = state.tasks.where((task) => !task.completed).toList();
              final done = state.tasks.where((task) => task.completed).toList();

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                    children: [
                      TaskManagementHeader(selectedDay: widget.selectedDay),
                      const SizedBox(height: 18),
                      TaskOverviewCards(tasks: state.tasks),
                      const SizedBox(height: 22),
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        TaskTasksSection(
                          title: 'Current Tasks',
                          count: todo.length,
                          emptyMessage:
                              'No active tasks. Add one and schedule a reminder if you want.',
                          children: todo
                              .map(
                                (task) => TaskItemCard(
                                  task: task,
                                  onToggle: () async {
                                    await context
                                        .read<TasksCubit>()
                                        .toggleTaskCompletion(task, _dayKey);
                                    if (!mounted) {
                                      return;
                                    }
                                    context.read<AppNotificationCubit>().show(
                                      task.completed ? 'Task reopened.' : 'Task completed.',
                                      type: AppNotificationType.success,
                                    );
                                  },
                                  onEdit: () => _openEditor(task),
                                  onDelete: () async {
                                    await context.read<TasksCubit>().deleteTask(task, _dayKey);
                                    if (!mounted) {
                                      return;
                                    }
                                    context.read<AppNotificationCubit>().show(
                                      'Task deleted.',
                                      type: AppNotificationType.info,
                                    );
                                  },
                                ),
                              )
                              .toList(),
                        ),
                        const SizedBox(height: 18),
                        TaskTasksSection(
                          title: 'Completed Tasks',
                          count: done.length,
                          emptyMessage: 'Completed tasks will appear here as you make progress.',
                          children: done
                              .map(
                                (task) => TaskItemCard(
                                  task: task,
                                  onToggle: () async {
                                    await context
                                        .read<TasksCubit>()
                                        .toggleTaskCompletion(task, _dayKey);
                                  },
                                  onEdit: () => _openEditor(task),
                                  onDelete: () async {
                                    await context.read<TasksCubit>().deleteTask(task, _dayKey);
                                  },
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ],
                  ),
                  Positioned(
                    right: 20,
                    bottom: 24,
                    child: FloatingActionButton.extended(
                      onPressed: () => _openEditor(),
                      icon: const Icon(Icons.add_task_rounded),
                      label: const Text('New Task'),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
