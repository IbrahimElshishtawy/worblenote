import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:writdle/core/notifications/app_notification.dart';
import 'package:writdle/core/notifications/app_notification_cubit.dart';
import 'package:writdle/core/utils/date_formatter.dart';
import 'package:writdle/domain/entities/task_model.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/widgets/task_card.dart';
import 'package:writdle/presentation/widgets/tasks/task_editor_sheet.dart';

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
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          gradient: LinearGradient(
                            colors: [scheme.primary, scheme.secondary],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Task Planner',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    color: scheme.onPrimary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Plan, track, remind, and complete your day with smart local notifications.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: scheme.onPrimary.withValues(alpha: 0.86),
                                    height: 1.45,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      if (state.isOfflineData) ...[
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDE68A),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.cloud_off_rounded, color: Color(0xFF92400E)),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  'You are viewing offline tasks. Reminders still work locally on the device.',
                                  style: TextStyle(
                                    color: Color(0xFF92400E),
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: _OverviewCard(
                              label: 'Open',
                              value: '${todo.length}',
                              color: const Color(0xFFEA580C),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OverviewCard(
                              label: 'Done',
                              value: '${done.length}',
                              color: const Color(0xFF15803D),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _OverviewCard(
                              label: 'Alerts',
                              value: '${state.tasks.where((task) => task.hasReminder).length}',
                              color: const Color(0xFF7C3AED),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      if (state.isLoading)
                        const Padding(
                          padding: EdgeInsets.all(24),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      else ...[
                        _SectionHeader(title: 'Current Tasks', count: todo.length),
                        const SizedBox(height: 12),
                        if (todo.isEmpty)
                          const _EmptyTasksCard(
                            message: 'No active tasks. Add one and schedule a reminder if you want.',
                          )
                        else
                          ...todo.map(
                            (task) => TaskCard(
                              task: task,
                              onToggle: () async {
                                await context.read<TasksCubit>().toggleTaskCompletion(task, _dayKey);
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
                          ),
                        const SizedBox(height: 18),
                        _SectionHeader(title: 'Completed Tasks', count: done.length),
                        const SizedBox(height: 12),
                        if (done.isEmpty)
                          const _EmptyTasksCard(
                            message: 'Completed tasks will appear here as you make progress.',
                          )
                        else
                          ...done.map(
                            (task) => TaskCard(
                              task: task,
                              onToggle: () async {
                                await context.read<TasksCubit>().toggleTaskCompletion(task, _dayKey);
                              },
                              onEdit: () => _openEditor(task),
                              onDelete: () async {
                                await context.read<TasksCubit>().deleteTask(task, _dayKey);
                              },
                            ),
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

class _OverviewCard extends StatelessWidget {
  const _OverviewCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 4),
          Text(label),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const Spacer(),
        Text(
          '$count',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Text(
        message,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}
