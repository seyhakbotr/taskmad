import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taskmanage/core/themes/app_pallete.dart';
import 'package:taskmanage/features/task/domain/entities/task.dart';

class TaskViewerPage extends StatelessWidget {
  final Task task;

  const TaskViewerPage({
    super.key,
    required this.task,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details',
            style: TextStyle(fontWeight: FontWeight.w600)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () => _navigateToEdit(context),
          ),
        ],
        backgroundColor: AppPallete.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: AppPallete.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task image
            if (task.imageUrl != null && task.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 220,
                  decoration: BoxDecoration(
                    color: AppPallete.greyColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Image.network(
                    task.imageUrl!,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Header Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          task.title,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                color: AppPallete.gradient1,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                      ),
                    ],
                  ),

                  _buildStatusIndicator(),

                  // Topics
                  if (task.topics?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Topics',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppPallete.gradient1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: task.topics!.map((topic) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppPallete.gradient1.withOpacity(0.1),
                                    AppPallete.gradient2.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppPallete.gradient1.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              child: Text(
                                topic,
                                style: TextStyle(
                                  color: AppPallete.gradient1,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 24),
            _buildSectionDivider(),

            // Description
            _buildSection(
              title: 'Description',
              content: task.description ?? 'No description provided',
            ),

            const SizedBox(height: 24),
            _buildSectionDivider(),

            // Details
            _buildSection(
              title: 'Details',
              contentWidget: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today,
                    label: 'Due Date',
                    value: task.dueDate != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a')
                            .format(task.dueDate!)
                        : 'Not set',
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    icon: Icons.update,
                    label: 'Last Updated',
                    value: DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(task.updatedAt),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return Column(
      children: [
        Wrap(
          spacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getStatusColor(task.status ?? 'todo').withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.status?.toUpperCase() ?? 'TODO',
                style: TextStyle(
                  color: _getStatusColor(task.status ?? 'todo'),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getPriorityColor(task.priority ?? 'medium')
                    .withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                task.priority?.toUpperCase() ?? 'MEDIUM',
                style: TextStyle(
                  color: _getPriorityColor(task.priority ?? 'medium'),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSection(
      {String? title, String? content, Widget? contentWidget}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppPallete.gradient1,
                letterSpacing: -0.5,
              ),
            ),
          if (title != null) const SizedBox(height: 12),
          if (content != null)
            Text(
              content,
              style: const TextStyle(
                fontSize: 15,
                color: AppPallete.gradient2,
                height: 1.6,
              ),
            ),
          if (contentWidget != null) contentWidget,
        ],
      ),
    );
  }

  Widget _buildSectionDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Divider(
        height: 1,
        color: AppPallete.greyColor.withOpacity(0.2),
        thickness: 1,
      ),
    );
  }

  void _navigateToEdit(BuildContext context) {
    // Navigation implementation
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'todo':
        return AppPallete.highPriorityColor;
      case 'in progress':
        return AppPallete.mediumPriorityColor;
      case 'done':
        return AppPallete.lowPriorityColor;
      default:
        return AppPallete.gradient1;
    }
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppPallete.gradient1.withOpacity(0.8)),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: AppPallete.gradient2.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppPallete.gradient1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
