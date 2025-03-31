import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/core/utils/pick_image.dart';
import 'package:taskmanage/features/task/domain/entities/topic.dart';

class AddTaskDialog extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController dueDateController;
  final String initialStatus;
  final String initialPriority;
  final Topic? initialTopic;
  final String? initialImage;
  final List<Topic> availableTopics;
  final ValueChanged<String> onPriorityChanged;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<Topic?> onTopicChanged;
  final VoidCallback onCreatePressed;
  final ValueChanged<File?> onImageSelected;

  const AddTaskDialog({
    super.key,
    required this.titleController,
    this.initialStatus = 'todo',
    required this.descriptionController,
    required this.dueDateController,
    this.initialPriority = 'medium',
    this.initialTopic,
    required this.availableTopics,
    required this.onPriorityChanged,
    required this.onStatusChanged,
    required this.onTopicChanged,
    required this.onImageSelected,
    required this.onCreatePressed,
    this.initialImage,
  });

  static Future<void> show({
    required BuildContext context,
    required TextEditingController titleController,
    required TextEditingController descriptionController,
    required TextEditingController dueDateController,
    String initialPriority = 'medium',
    String initialStatus = 'todo',
    Topic? initialTopic,
    String? initialImage,
    required List<Topic> availableTopics,
    required ValueChanged<String> onPriorityChanged,
    required ValueChanged<File?> onImageSelected,
    required ValueChanged<String> onStatusChanged,
    required ValueChanged<Topic?> onTopicChanged,
    required VoidCallback onCreatePressed,
  }) async {
    return showDialog(
      context: context,
      builder: (context) => AddTaskDialog(
        titleController: titleController,
        descriptionController: descriptionController,
        dueDateController: dueDateController,
        initialPriority: initialPriority,
        onPriorityChanged: onPriorityChanged,
        initialStatus: initialStatus,
        onStatusChanged: onStatusChanged,
        initialTopic: initialTopic,
        initialImage: initialImage,
        availableTopics: availableTopics,
        onTopicChanged: onTopicChanged,
        onImageSelected: onImageSelected,
        onCreatePressed: onCreatePressed,
      ),
    );
  }

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  late String _selectedPriority;
  late String _selectedStatus;
  late Topic? _selectedTopic;
  File? _selectedImageFile; // For newly picked images
  String? _existingImageUrl; // For existing Supabase URLs

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.initialPriority;
    _selectedStatus = widget.initialStatus;
    _selectedTopic = widget.initialTopic != null &&
            widget.availableTopics.contains(widget.initialTopic)
        ? widget.initialTopic
        : null;
    _existingImageUrl = widget.initialImage; // Store the initial URL
  }

  Future<void> _selectImage() async {
    final pickedImage = await pickImage();
    if (pickedImage != null) {
      setState(() {
        _selectedImageFile = pickedImage;
        // Clear existing URL when new image is selected
        _existingImageUrl = null;
      });
      widget.onImageSelected(pickedImage);
    }
  }

  void _removeImage() {
    setState(() {
      _selectedImageFile = null;
      _existingImageUrl = null;
    });
    widget.onImageSelected(null); // Notify parent that image was removed
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        final DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );
        widget.dueDateController.text =
            DateFormat('yyyy-MM-dd HH:mm').format(finalDateTime);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GestureDetector(
              onTap: _selectImage,
              child: Stack(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppPallete.gradient1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _buildImagePreview(),
                  ),
                  if (_hasImage())
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                        ),
                        onPressed: _removeImage,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                hintStyle: TextStyle(color: AppPallete.gradient2),
              ),
              style: const TextStyle(fontSize: 18, color: AppPallete.gradient1),
              cursorColor: AppPallete.gradient1,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.descriptionController,
              decoration: const InputDecoration(
                hintText: 'Description',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                hintStyle: TextStyle(color: AppPallete.gradient2),
              ),
              style: const TextStyle(fontSize: 16, color: AppPallete.gradient1),
              cursorColor: AppPallete.gradient1,
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: widget.dueDateController,
              readOnly: true,
              onTap: () => _selectDateTime(context),
              decoration: const InputDecoration(
                hintText: 'Due date and time',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                hintStyle: TextStyle(color: AppPallete.gradient2),
                suffixIcon:
                    Icon(Icons.calendar_today, color: AppPallete.gradient1),
              ),
              style: const TextStyle(fontSize: 16, color: AppPallete.gradient1),
              cursorColor: AppPallete.gradient1,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedPriority,
              decoration: const InputDecoration(
                labelText: 'Priority',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'low', child: Text('Low')),
                DropdownMenuItem(value: 'medium', child: Text('Medium')),
                DropdownMenuItem(value: 'high', child: Text('High')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPriority = value;
                  });
                  widget.onPriorityChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'todo', child: Text('To Do')),
                DropdownMenuItem(
                    value: 'in_progress', child: Text('In Progress')),
                DropdownMenuItem(value: 'done', child: Text('Done')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                  });
                  widget.onStatusChanged(value);
                }
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Topic>(
              value: widget.availableTopics.contains(_selectedTopic)
                  ? _selectedTopic
                  : null,
              decoration: const InputDecoration(
                labelText: 'Topic',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              items: widget.availableTopics.map((topic) {
                return DropdownMenuItem<Topic>(
                  value: topic,
                  child: Text(topic.name),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedTopic = value;
                  });
                  widget.onTopicChanged(value);
                }
              },
              hint: const Text('Select a topic'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            widget.onCreatePressed();
            Navigator.pop(context);
          },
          child: const Text('Create'),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    if (_selectedImageFile != null) {
      // Show newly selected image
      return Image.file(_selectedImageFile!, fit: BoxFit.cover);
    } else if (_existingImageUrl != null) {
      // Show existing image from URL
      return Image.network(_existingImageUrl!, fit: BoxFit.cover);
    } else {
      // Show placeholder
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate,
              size: 40, color: AppPallete.gradient1),
          const SizedBox(height: 8),
          Text('Add Image', style: TextStyle(color: AppPallete.gradient1)),
        ],
      );
    }
  }

  bool _hasImage() {
    return _selectedImageFile != null || _existingImageUrl != null;
  }
}
