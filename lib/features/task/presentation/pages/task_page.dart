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
          // Handle side effects here, such as showing Snackbars if needed
          if (state is TaskOperationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${state.failure.message}'),
            ));
          }
        },
        builder: (context, state) {
          final cubit = context.read<TaskOperationCubit>();
          final topics = cubit.availableTopics; // Using cubit's allTaskTopics

          return RefreshIndicator(
            onRefresh: () async {
              _fetchUserTasks();
              _fetchTopics();
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
                            'Upcoming Deadlines',
                            style: TextStyle(
                              color: AppPallete.gradient1,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          BlocBuilder<TaskOperationCubit, TaskOperationState>(
                            builder: (context, state) {
                              final upcoming = state
                                      is TaskOperationSuccessWithTasks
                                  ? state.tasks
                                      .where((t) =>
                                          t.dueDate != null &&
                                          t.dueDate!.isAfter(DateTime.now()))
                                      .take(3)
                                      .toList()
                                  : [];

                              if (upcoming.isEmpty) {
                                return const Text(
                                  'No upcoming deadlines',
                                  style: TextStyle(color: AppPallete.gradient2),
                                );
                              }

                              return Column(
                                children: upcoming
                                    .map((task) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4),
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today,
                                                size: 16,
                                                color: AppPallete.gradient1,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  task.title,
                                                  style: const TextStyle(
                                                      color:
                                                          AppPallete.gradient1),
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                DateFormat('MMM dd')
                                                    .format(task.dueDate!),
                                                style: const TextStyle(
                                                    color:
                                                        AppPallete.gradient2),
                                              ),
                                            ],
                                          ),
                                        ))
                                    .toList(),
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
                          'Recent Tasks',
                          style: TextStyle(
                            color: AppPallete.gradient1,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        InkWell(
                          onTap: () => _viewAllTasks(),
                          child: const Text(
                            'View All',
                            style: TextStyle(
                              color: AppPallete.gradient2,
                              fontWeight: FontWeight.w500,
                              decoration: TextDecoration.underline,
                            ),
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
