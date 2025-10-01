// lib/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/hive_service.dart';

class TaskCard extends StatefulWidget {
  final Task task;
  // Add this callback function
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    // Add this to the constructor
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  final HiveService _hiveService = HiveService();

  void _toggleCompleted(bool? value) {
    if (value == null) return;
    setState(() {
      widget.task.isCompleted = value;
    });
    _hiveService.updateTask(widget.task);
  }

  // The _deleteTask method is no longer needed here.

  Color _getPriorityColor(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    switch (widget.task.priority) {
      case 'High':
        return Colors.red.shade400;
      case 'Medium':
        return isDark ? Colors.orange.shade300 : Colors.orange.shade700;
      case 'Low':
        return isDark ? Colors.blue.shade300 : Colors.blue.shade600;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPastDue = widget.task.dueDate != null &&
        widget.task.dueDate!.isBefore(DateTime.now()) &&
        !widget.task.isCompleted;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          // ignore: deprecated_member_use
          color: theme.colorScheme.outline.withOpacity(0.2),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: widget.task.isCompleted,
              onChanged: _toggleCompleted,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              activeColor: theme.primaryColor,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.task.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      decoration: widget.task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: widget.task.isCompleted
                          ? Colors.grey
                          : theme.textTheme.bodyLarge?.color,
                    ),
                  ),
                  if (widget.task.description?.isNotEmpty ?? false)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        widget.task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  if (widget.task.dueDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            size: 14,
                            color: isPastDue
                                ? Colors.red.shade400
                                : Colors.grey.shade600,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            DateFormat.yMMMd().format(widget.task.dueDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: isPastDue
                                  ? Colors.red.shade400
                                  : Colors.grey.shade600,
                              fontWeight: isPastDue ? FontWeight.bold : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // This is the new part for the delete button, if you want one inside the card
            if (widget.task.isCompleted && widget.onDelete != null)
              IconButton(
                icon: Icon(Icons.delete_outline, color: Colors.red.shade300),
                onPressed: widget.onDelete, // Use the callback here!
                tooltip: 'Delete Task',
              ),
            Container(
              width: 5,
              height: 40,
              decoration: BoxDecoration(
                color: _getPriorityColor(context),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
