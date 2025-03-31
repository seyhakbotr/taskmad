import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:taskmanage/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/usecases/tasks/get_user_tasks.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_cubit.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_state.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    // Load tasks when the page initializes
    final posterId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

    context.read<TaskOperationCubit>().getUserTasksList(
          userId: posterId,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text('Calendar',
            style: TextStyle(color: AppPallete.gradient2)),
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: BlocConsumer<TaskOperationCubit, TaskOperationState>(
        listener: (context, state) {
          // Handle any state changes if needed
        },
        builder: (context, state) {
          List<Task> tasks = [];
          if (state is TaskOperationSuccessWithTasks) {
            tasks = state.tasks;
          }

          // Filter tasks for the selected day
          final selectedDayTasks = _selectedDay != null
              ? tasks
                  .where((task) =>
                      task.dueDate != null &&
                      isSameDay(task.dueDate, _selectedDay))
                  .toList()
              : [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TableCalendar(
                  daysOfWeekHeight: 40.0,
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  calendarFormat: _calendarFormat,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                  },
                  onFormatChanged: (format) {
                    setState(() {
                      _calendarFormat = format;
                    });
                  },
                  onPageChanged: (focusedDay) {
                    _focusedDay = focusedDay;
                  },
                  eventLoader: (day) {
                    // Return tasks for this day
                    return tasks
                        .where((task) =>
                            task.dueDate != null &&
                            isSameDay(task.dueDate, day))
                        .toList();
                  },
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: const TextStyle(
                      color: AppPallete.borderColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    leftChevronIcon: const Icon(Icons.chevron_left,
                        color: AppPallete.gradient2),
                    rightChevronIcon: const Icon(Icons.chevron_right,
                        color: AppPallete.gradient2),
                  ),
                  calendarStyle: CalendarStyle(
                    weekendTextStyle:
                        const TextStyle(color: AppPallete.errorColor),
                    todayDecoration: BoxDecoration(
                      color: AppPallete.highlightColor,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: AppPallete.gradient2,
                      shape: BoxShape.circle,
                    ),
                    defaultTextStyle: const TextStyle(color: Colors.black),
                    outsideTextStyle:
                        const TextStyle(color: AppPallete.greyColor),
                    cellPadding: const EdgeInsets.all(8),
                    // Add marker for days with tasks
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    decoration: BoxDecoration(
                      color: AppPallete.gradient2,
                    ),
                    weekdayStyle: const TextStyle(color: AppPallete.whiteColor),
                    weekendStyle: const TextStyle(color: AppPallete.errorColor),
                  ),
                ),
                const SizedBox(height: 20),
                // Display tasks for selected day
                if (_selectedDay != null) ...[
                  Text(
                    'Tasks for ${DateFormat.yMMMd().format(_selectedDay!)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppPallete.gradient2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: selectedDayTasks.length,
                      itemBuilder: (context, index) {
                        final task = selectedDayTasks[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            title: Text(task.title),
                            subtitle: Text(task.description ?? ''),
                            trailing: Text(
                              task.priority ?? '',
                              style: TextStyle(
                                color: _getPriorityColor(task.priority),
                              ),
                            ),
                            onTap: () {
                              // Navigate to task details or edit
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
      case 'high':
        return AppPallete.highPriorityColor;
      case 'medium':
        return AppPallete.mediumPriorityColor;
      case 'low':
        return AppPallete.lowPriorityColor;
      default:
        return AppPallete.greyColor;
    }
  }
}
