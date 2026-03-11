import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import 'package:writdle/providers/tasks_provider.dart';
import 'package:writdle/providers/user_stats_provider.dart';
import 'task_page.dart';

class ActivityPage extends StatefulWidget {
  const ActivityPage({super.key});

  @override
  State<ActivityPage> createState() => _ActivityPageState();
}

class _ActivityPageState extends State<ActivityPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TasksProvider>().fetchTasks(_formatDate(_selectedDay!));
    });
  }

  String _formatDate(DateTime date) =>
      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Daily Activity'),
        centerTitle: true,
      ),
      body: Consumer<TasksProvider>(
        builder: (context, tasksProvider, child) {
          final totalTasks = tasksProvider.tasks.length;
          final completedTasks = tasksProvider.tasks.where((t) => t.completed).length;
          final progress = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;
          final uncompletedTasks = tasksProvider.tasks.where((t) => !t.completed).toList();

          return RefreshIndicator(
            onRefresh: () => tasksProvider.fetchTasks(_formatDate(_selectedDay!)),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
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
                      tasksProvider.fetchTasks(_formatDate(selectedDay));
                    },
                    headerStyle: const HeaderStyle(
                      formatButtonVisible: false,
                      titleCentered: true,
                    ),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      selectedDecoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Progress: $completedTasks / $totalTasks',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_task),
                        label: const Text('Manage Tasks'),
                        onPressed: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TasksPage(selectedDay: _selectedDay!),
                            ),
                          );
                          if (mounted) {
                            tasksProvider.fetchTasks(_formatDate(_selectedDay!));
                            context.read<UserStatsProvider>().loadFromFirestore();
                          }
                        },
                      ),
                      Text('Remaining: ${totalTasks - completedTasks}'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (uncompletedTasks.isNotEmpty) ...[
                    const Text(
                      '📌 Tasks to complete:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    ...uncompletedTasks.map((task) => Card(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: task.description.isNotEmpty ? Text(task.description) : null,
                            trailing: IconButton(
                              icon: const Icon(Icons.check_circle_outline),
                              onPressed: () async {
                                await tasksProvider.toggleTaskCompletion(task, _formatDate(_selectedDay!));
                                if (mounted) {
                                  context.read<UserStatsProvider>().loadFromFirestore();
                                }
                              },
                            ),
                          ),
                        )),
                  ] else if (totalTasks > 0)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('🎉 All caught up for today!', style: TextStyle(fontSize: 16)),
                      ),
                    )
                  else
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No tasks for today. Add some!', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
