import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmanage/core/common/cubits/app_user/app_user_cubit.dart';
import 'package:taskmanage/core/common/widgets/loader.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/core/utils/get_status_color.dart';
import 'package:taskmanage/core/utils/get_status_icon.dart';
import 'package:taskmanage/core/utils/get_status_text.dart';
import 'package:taskmanage/core/utils/pick_image.dart';
import 'package:taskmanage/core/utils/show_snackbar.dart';
import 'package:taskmanage/features/task/data/models/task_model.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_cubit.dart';
import 'package:taskmanage/features/task/presentation/cubit/task_operation_state.dart';
import 'package:taskmanage/features/task/presentation/pages/task_viewer_page.dart';
import 'package:taskmanage/features/task/presentation/widgets/add_task_dialog.dart';

class TaskListWidget extends StatefulWidget {
  final Set<String> selectedTopicIds;
  final List<Topic> allTaskTopics;

  TaskListWidget({
    super.key,
    this.allTaskTopics = const [],
    this.selectedTopicIds = const {},
  });
  @override
  State<TaskListWidget> createState() => _TaskListWidgetState();
}

class _TaskListWidgetState extends State<TaskListWidget> {
  File? image;
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TaskOperationCubit, TaskOperationState>(
      listener: (context, state) {
        if (state is TaskOperationFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.failure.message)),
          );
        } else if (state is TaskOperationSuccess ||
            state is TaskOperationSuccessWithTask) {
          final posterId =
              (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
          showSnackBar(context, "Success");
          context.read<TaskOperationCubit>().getUserTasksList(
                userId: posterId,
              );
        }
      },
      builder: (context, state) {
        if (state is TaskOperationLoading) {
          // If we have previous tasks, show them while loading
          if (state.previousTasks != null && state.previousTasks!.isNotEmpty) {
            return _buildTaskList(context, state.previousTasks!);
          }
          return const Loader();
        } else if (state is TaskOperationUpdating ||
            state is TaskOperationInitial) {
          return const Loader();
        } else if (state is TaskOperationFailure) {
          return _buildErrorState(context, state);
        } else if (state is TaskOperationSuccessWithTasks) {
          if (state.tasks.isEmpty) {
            return _buildEmptyState();
          }
          return _buildTaskList(context, state.tasks);
        }
        // This should rarely be reached if states are handled properly
        return const Center(child: Text(''));
      },
    );
  }

  void selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
      });
    }
  }

  Widget _buildErrorState(BuildContext context, TaskOperationFailure state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Failed to load tasks: ${state.failure.message}',
              style: const TextStyle(color: AppPallete.errorColor),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => _fetchTasks(context),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(BuildContext context, List<Task> tasks) {
    if (tasks.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _fetchTasks(context),
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) => _buildTaskItem(tasks[index], context),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            widget.selectedTopicIds.isEmpty
                ? 'No tasks found\nTap + to create a new task'
                : 'No tasks match the selected topics',
            style: const TextStyle(color: AppPallete.gradient2),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildTaskItem(Task task, BuildContext context) {
    final taskModel = TaskModel.fromEntity(task);

    return Dismissible(
      key: Key(task.id ?? UniqueKey().toString()),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        context.read<TaskOperationCubit>().deleteExistingTask(task.id!);
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppPallete.borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task title and menu with status chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      task.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppPallete.gradient1,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () => _showStatusMenu(context, taskModel),
                        child: Chip(
                          label: Text(
                            getStatusText(taskModel.status ?? 'todo'),
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor:
                              getStatusColor(taskModel.status ?? 'todo'),
                          avatar: Icon(
                            getStatusIcon(taskModel.status ?? 'todo'),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: const Icon(Icons.more_vert,
                            color: AppPallete.gradient1),
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility,
                                    color: AppPallete.gradient1),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: AppPallete.gradient1),
                                SizedBox(width: 8),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'view') {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TaskViewerPage(task: task),
                              ),
                            );
                          } else if (value == 'edit') {
                            _showEditDialog(context, task);
                          } else if (value == 'delete') {
                            _confirmDelete(context, task);
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),

              // Description
              if (task.description?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Text(
                  task.description!,
                  style: const TextStyle(color: AppPallete.gradient2),
                ),
              ],

              // Topics display
              if (task.topics?.isNotEmpty ?? false) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: task.topics!.map((topic) {
                    return Chip(
                      label: Text(topic),
                      backgroundColor: AppPallete.gradient1.withOpacity(0.1),
                      labelStyle: const TextStyle(color: AppPallete.gradient1),
                    );
                  }).toList(),
                ),
              ],

              // Due date and priority
              const SizedBox(height: 8),
              Row(
                children: [
                  if (task.dueDate != null) ...[
                    const Icon(Icons.calendar_today,
                        size: 18, color: AppPallete.gradient1),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('MMM dd, yyyy').format(task.dueDate!),
                      style: const TextStyle(color: AppPallete.gradient1),
                    ),
                  ],
                  const Spacer(),
                  if (task.priority != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getPriorityColor(task.priority!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        task.priority!.toUpperCase(),
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _parseTopicColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppPallete.gradient1;
    }
  }

  void _showStatusMenu(BuildContext context, TaskModel task) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading:
                  const Icon(Icons.radio_button_unchecked, color: Colors.grey),
              title: const Text('To Do'),
              onTap: () {
                _updateTaskStatus(context, task.copyWith(status: 'todo'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.autorenew, color: Colors.blue),
              title: const Text('In Progress'),
              onTap: () {
                _updateTaskStatus(
                    context, task.copyWith(status: 'in_progress'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Done'),
              onTap: () {
                _updateTaskStatus(context, task.copyWith(status: 'done'));
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

// Method to update task status
  void _updateTaskStatus(BuildContext context, TaskModel updatedTask) {
    if (updatedTask.id == null ||
        updatedTask.status == null ||
        updatedTask.creatorId == null) {
      showSnackBar(context, "Missing required task information");
      return;
    }

    context.read<TaskOperationCubit>().updateExistingTask(
          taskId: updatedTask.id!,
          creatorId: updatedTask.creatorId!, // Add null check here
          status: updatedTask.status!,
        );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return AppPallete.gradient1;
    }
  }

  Future<void> _fetchTasks(BuildContext context) async {
    final userId =
        (context.read<AppUserCubit>().state as AppUserLoggedIn).user.id;
    context.read<TaskOperationCubit>().getUserTasksList(userId: userId);
  }

  void _showEditDialog(BuildContext context, Task task) {
    // Convert Task to TaskModel
    TaskModel taskModel = TaskModel(
      id: task.id,
      title: task.title,
      description: task.description,
      status: task.status,
      priority: task.priority,
      dueDate: task.dueDate,
      imageUrl: task.imageUrl,
      updatedAt: task.updatedAt,
      creatorId: task.creatorId,
      topics: task.topics,
    );

    Task updatedTask = taskModel;
    final titleController = TextEditingController(text: taskModel.title);
    final descriptionController =
        TextEditingController(text: taskModel.description);
    final dueDateController = TextEditingController(
      text: taskModel.dueDate != null
          ? DateFormat('yyyy-MM-dd HH:mm').format(taskModel.dueDate!)
          : '',
    );

    // Store the complete topic object reference
    Topic? selectedTopic;
    if (taskModel.topics?.isNotEmpty == true) {
      selectedTopic = widget.allTaskTopics.firstWhere(
        (topic) => topic.name == taskModel.topics!.first,
        orElse: () => Topic(id: '', name: taskModel.topics!.first),
      );
    }

    AddTaskDialog.show(
      context: context,
      titleController: titleController,
      descriptionController: descriptionController,
      dueDateController: dueDateController,
      initialPriority: taskModel.priority ?? 'medium',
      initialStatus: taskModel.status ?? 'todo',
      initialImage: taskModel.imageUrl,
      initialTopic: selectedTopic,
      availableTopics: widget.allTaskTopics,
      isEdit: true,
      onPriorityChanged: (priority) {
        updatedTask = taskModel.copyWith(priority: priority);
      },
      onStatusChanged: (status) {
        updatedTask = taskModel.copyWith(status: status);
      },
      onTopicChanged: (topic) {
        // Update both the selected topic reference and the task model
        selectedTopic = topic;
        updatedTask = taskModel.copyWith(
          topics: topic != null ? [topic.name] : [],
        );
      },
      onImageSelected: (newImage) {
        setState(() {
          image = newImage;
        });
        updatedTask = taskModel.copyWith(imageUrl: newImage?.path);
      },
      onCreatePressed: () {
        // Use the selectedTopic object directly to preserve the ID
        //
        //
        updatedTask = taskModel.copyWith(
          title: titleController.text,
          description: descriptionController.text,
        );
        List<Topic> topics = [];
        if (selectedTopic != null) {
          topics = [selectedTopic!];
        }

        context.read<TaskOperationCubit>().updateExistingTask(
              taskId: updatedTask.id!,
              image: image,
              title: titleController.text, // Use controller value directly
              description:
                  descriptionController.text, // Use controller value directly
              creatorId: updatedTask.creatorId,
              dueDate: updatedTask.dueDate!,
              priority: updatedTask.priority!,
              status: updatedTask.status!,
              topics: topics, // Now includes both id and name
              currentImageUrl: updatedTask.imageUrl,
            );
      },
    );
  }

  void _confirmDelete(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskOperationCubit>().deleteExistingTask(task.id!);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
