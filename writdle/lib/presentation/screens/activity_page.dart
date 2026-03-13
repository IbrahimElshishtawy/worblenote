import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:writdle/core/utils/date_formatter.dart';
import 'package:writdle/presentation/bloc/profile_cubit.dart';
import 'package:writdle/presentation/bloc/tasks_cubit.dart';
import 'package:writdle/presentation/screens/task_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksCubit>().fetchTasks(DateFormatter.toDayKey(_selectedDay));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Your Daily Activity')),
      body: BlocBuilder<TasksCubit, TasksState>(
        builder: (context, state) {
          final totalTasks = state.tasks.length;
          final completedTasks = state.completedTasks;
          final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
          final uncompletedTasks =
              state.tasks.where((task) => !task.completed).toList();

          return RefreshIndicator(
            onRefresh: () {
              return context.read<TasksCubit>().fetchTasks(
                DateFormatter.toDayKey(_selectedDay),
              );
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                TableCalendar(
                  firstDay: DateTime.utc(2020),
                  lastDay: DateTime.utc(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    context.read<TasksCubit>().fetchTasks(
                      DateFormatter.toDayKey(selectedDay),
                    );
                  },
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Daily Progress: $completedTasks / $totalTasks',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        LinearProgressIndicator(value: progress, minHeight: 10),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TasksPage(selectedDay: _selectedDay),
                          ),
                        );
                        if (!mounted) {
                          return;
                        }
                        await context.read<TasksCubit>().fetchTasks(
                          DateFormatter.toDayKey(_selectedDay),
                        );
                        await context.read<ProfileCubit>().loadProfile();
                      },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 48),
                      ),
                      icon: const Icon(Icons.add_task),
                      label: const Text('Manage Tasks'),
                    ),
                    Text('Remaining: ${totalTasks - completedTasks}'),
                  ],
                ),
                const SizedBox(height: 24),
                if (state.isLoading)
                  const Center(child: CircularProgressIndicator())
                else if (uncompletedTasks.isEmpty && totalTasks == 0)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('No tasks for this day. Add some!'),
                    ),
                  )
                else if (uncompletedTasks.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text('All caught up for today!'),
                    ),
                  )
                else
                  ...uncompletedTasks.map(
                    (task) => Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(task.title),
                        subtitle: task.description.isEmpty
                            ? null
                            : Text(task.description),
                        trailing: IconButton(
                          onPressed: () async {
                            await context.read<TasksCubit>().toggleTaskCompletion(
                              task,
                              DateFormatter.toDayKey(_selectedDay),
                            );
                            if (!mounted) {
                              return;
                            }
                            await context.read<ProfileCubit>().loadProfile();
                          },
                          icon: const Icon(Icons.check_circle_outline),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
