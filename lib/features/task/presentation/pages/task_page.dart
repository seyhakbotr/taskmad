import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/core/utils/show_snackbar.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_cubit.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_state.dart';
import 'package:taskmanage/features/task/presentation/widgets/add_task_dialog.dart';
import 'package:taskmanage/features/task/presentation/widgets/my_drawer.dart';

import 'package:taskmanage/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:taskmanage/features/task/presentation/widgets/task_list_widget.dart';

class TaskPage extends StatefulWidget {
  const TaskPage({super.key});

  @override
  State<TaskPage> createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dueDateController = TextEditingController();

  List<Topic> allTaskTopics = [];
  final Set<String> _selectedTopicIds = {};
  String _priority = 'medium';
  String _status = 'todo';
  Topic? _selectedTopic;
  File? _taskImage;
  @override
  void initState() {
    super.initState();
    _fetchTopics();
    _fetchUserTasks();
  }

  @override
  void dispose() {
    // Clean up the controllers when the widget is disposed
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    super.dispose();
  }

  void _fetchUserTasks() {
    final posterId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;

    final topicIds =
        _selectedTopicIds.isNotEmpty ? _selectedTopicIds.toList() : null;
    print("topicIds fetch $topicIds");
    context.read<TaskOperationCubit>().getUserTasksList(
          userId: posterId,
          topicIds: topicIds,
        );
  }

  void _fetchTopics() async {
    await context.read<TaskOperationCubit>().fetchAllTaskTopics();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPallete.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "My Tasks",
          style: TextStyle(
            color: AppPallete.gradient1,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppPallete.gradient1),
      ),
      body: BlocConsumer<TaskOperationCubit, TaskOperationState>(
        listener: (context, state) {
          if (state is TaskOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.failure.message}'),
            ));
          }
        },
        builder: (context, state) {
          final cubit = context.read<TaskOperationCubit>();
          final topics = cubit.availableTopics;

          return RefreshIndicator(
            onRefresh: () async {
              _fetchTopics();
              _fetchUserTasks();
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Upcoming deadlines card
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(
                        color: AppPallete.borderColor,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Task Progress',
                            style: TextStyle(
                              color: AppPallete.gradient1,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 16),
                          BlocBuilder<TaskOperationCubit, TaskOperationState>(
                            builder: (context, state) {
                              if (state is! TaskOperationSuccessWithTasks) {
                                return const CircularProgressIndicator();
                              }

                              final tasks = state.tasks;
                              final totalTasks = tasks.length;

                              if (totalTasks == 0) {
                                return const Text(
                                  'No tasks available',
                                  style: TextStyle(color: AppPallete.gradient2),
                                );
                              }

                              // Count tasks by status
                              final doneCount =
                                  tasks.where((t) => t.status == 'done').length;
                              final inProgressCount = tasks
                                  .where((t) => t.status == 'in_progress')
                                  .length;
                              final todoCount =
                                  tasks.where((t) => t.status == 'todo').length;

                              // Calculate percentages
                              final donePercent = doneCount / totalTasks;
                              final inProgressPercent =
                                  inProgressCount / totalTasks;
                              final todoPercent = todoCount / totalTasks;

                              return Column(
                                children: [
                                  // Progress bar
                                  SizedBox(
                                    height: 20,
                                    child: Stack(
                                      children: [
                                        // Background
                                        Container(
                                          decoration: BoxDecoration(
                                            color: AppPallete.borderColor
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                        ),
                                        // Progress segments
                                        Row(
                                          children: [
                                            // Done portion
                                            Expanded(
                                              flex: (donePercent * 100).round(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color: Colors
                                                      .green, // Done color
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                            // In Progress portion
                                            Expanded(
                                              flex: (inProgressPercent * 100)
                                                  .round(),
                                              child: Container(
                                                color: Colors
                                                    .blue, // In Progress color
                                              ),
                                            ),
                                            // Todo portion
                                            Expanded(
                                              flex: (todoPercent * 100).round(),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  color:
                                                      Colors.grey, // Todo color
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(10),
                                                    bottomRight:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  // Legend
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      _buildLegendItem(
                                          'Done', Colors.green, doneCount),
                                      _buildLegendItem('In Progress',
                                          Colors.blue, inProgressCount),
                                      _buildLegendItem(
                                          'To Do', Colors.grey, todoCount),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${(donePercent * 100).toStringAsFixed(1)}% done',
                                    style: TextStyle(
                                      color: AppPallete.gradient1,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Topics filter chips
                  if (topics.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        'Topics',
                        style: TextStyle(
                          color: AppPallete.gradient1,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: topics.length,
                        itemBuilder: (context, index) {
                          final topic = topics[index];
                          final isSelected =
                              _selectedTopicIds.contains(topic.id);
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(topic.name),
                              selected: isSelected,
                              onSelected: (selected) {
                                setState(() {
                                  if (selected) {
                                    _selectedTopicIds.add(topic.id);
                                  } else {
                                    _selectedTopicIds.remove(topic.id);
                                  }
                                  print(
                                      'Selected topics: ${_selectedTopicIds.join(', ')}');
                                  _fetchUserTasks(); // This will trigger a new fetch with filters
                                });
                              },
                              selectedColor: AppPallete.gradient1,
                              backgroundColor: AppPallete.gradient3,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? AppPallete.whiteColor
                                    : AppPallete.highPriorityColor,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                  color: isSelected
                                      ? AppPallete.gradient1
                                      : AppPallete.borderColor,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  // Recent tasks header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'All Tasks',
                          style: TextStyle(
                            color: AppPallete.gradient1,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Task list
                  Expanded(
                    child: TaskListWidget(
                      selectedTopicIds: _selectedTopicIds,
                      allTaskTopics:
                          cubit.availableTopics, // Using allTaskTopics
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final cubit =
              context.read<TaskOperationCubit>(); // Get the cubit here
          AddTaskDialog.show(
            context: context,
            titleController: _titleController,
            descriptionController: _descriptionController,
            dueDateController: _dueDateController,
            initialPriority: _priority,
            initialTopic: _selectedTopic,
            availableTopics:
                cubit.availableTopics, // Pass the topics from the cubit
            initialStatus: _status,
            onImageSelected: (image) => setState(() => _taskImage = image),
            onPriorityChanged: (priority) =>
                setState(() => _priority = priority),
            onStatusChanged: (status) => setState(() => _status = status),
            onTopicChanged: (topic) => setState(() => _selectedTopic = topic),
            onCreatePressed: _handleTaskCreation,
          );
        },
        backgroundColor: AppPallete.gradient1,
        child: const Icon(Icons.add, color: AppPallete.whiteColor),
      ),
      drawer: const MyDrawer(),
    );
  }

  Widget _viewAllTasks() {
    // Temporary placeholder - return an empty container
    return Container();
  }

  Widget _buildLegendItem(String text, Color color, int count) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text('$count $text', style: TextStyle(fontSize: 12)),
      ],
    );
  }

  void _handleTaskCreation() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    final dueDateString = _dueDateController.text;

    if (title.isEmpty) {
      showSnackBar(context, 'Title is required', isError: true);
      return;
    }

    if (_selectedTopic == null) {
      showSnackBar(context, 'Please select a topic', isError: true);
      return;
    }

    try {
      DateTime dueDate;
      if (dueDateString.isNotEmpty) {
        dueDate = DateFormat('yyyy-MM-dd HH:mm').parse(dueDateString);
      } else {
        dueDate = DateTime.now().add(const Duration(days: 1));
      }

      final user = (context.read<AppUserCubit>().state as AppUserLoggedIn).user;

      await context.read<TaskOperationCubit>().uploadNewTask(
            image: _taskImage ?? File(''),
            topics: [_selectedTopic!], // Use the selected topic
            title: title,
            description: description,
            status: _status,
            creatorId: user.id,
            dueDate: dueDate,
            priority: _priority,
          );

      showSnackBar(context, 'Task Created Successfully');

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _dueDateController.clear();
      setState(() {
        _priority = 'medium';
        _status = 'todo';
        _taskImage = null;
        _selectedTopic = null;
      });

      _fetchUserTasks();
    } catch (e) {
      showSnackBar(context, 'Error Creating Task', isError: true);
    }
  }

  void_setFilter(param0) {}
}
