import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:todo_app/models/task.dart';
import 'package:todo_app/services/hive_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final HiveService _hiveService = HiveService();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _dueDate;
  String _priority = 'Medium';

  bool get isEditing => widget.task != null;

  static const double _verticalSpace = 24.0;

  final Map<String, Color> _priorityColors = {
    'High': Colors.red.shade400,
    'Medium': Colors.orange.shade400,
    'Low': Colors.green.shade400,
  };

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? '');
    _descriptionController =
        TextEditingController(text: widget.task?.description ?? '');
    _dueDate = widget.task?.dueDate;
    _priority = widget.task?.priority ?? 'Medium';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).primaryColor,
                  onPrimary: Colors.white,
                  onSurface: Theme.of(context).textTheme.bodyLarge?.color,
                ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != _dueDate) {
      setState(() {
        _dueDate = pickedDate;
      });
    }
  }

  void _saveTask() {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState!.validate()) {
      if (isEditing) {
        widget.task!.title = _titleController.text.trim();
        widget.task!.description = _descriptionController.text.trim();
        widget.task!.dueDate = _dueDate;
        widget.task!.priority = _priority;
        _hiveService.updateTask(widget.task!);
        _showFeedback('Task updated successfully!');
      } else {
        final newTask = Task(
          id: '',
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          dueDate: _dueDate,
          priority: _priority,
          createdAt: DateTime.now(),
        );
        _hiveService.addTask(newTask);
        _showFeedback('Task added successfully!');
      }
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          Navigator.pop(context);
        }
      });
    } else {
      _showFeedback('Please fix the errors above.', isError: true);
    }
  }

  void _showFeedback(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor:
            isError ? Theme.of(context).colorScheme.error : Colors.green[600],
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Task' : 'Add New Task'),
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.titleLarge?.color,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionHeader('Task Details'),
                _buildTitleField(),
                const SizedBox(height: _verticalSpace),
                _buildDescriptionField(),
                const SizedBox(height: _verticalSpace * 1.5),
                _buildSectionHeader('Scheduling & Priority'),
                _buildDateTimePicker(),
                const SizedBox(height: _verticalSpace),
                _buildPrioritySelector(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildSaveButton(),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: Theme.of(context).primaryColor,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Title',
        hintText: 'e.g., Buy groceries',
        prefixIcon: Icon(Icons.title_rounded),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a title';
        }
        return null;
      },
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Add any extra details here...',
        prefixIcon: Icon(Icons.description_outlined),
        alignLabelWithHint: true,
      ),
      maxLines: 4,
      textCapitalization: TextCapitalization.sentences,
    );
  }

  Widget _buildDateTimePicker() {
    return TextFormField(
      readOnly: true,
      controller: TextEditingController(
        text: _dueDate == null ? '' : DateFormat.yMMMd().format(_dueDate!),
      ),
      decoration: const InputDecoration(
        labelText: 'Due Date',
        hintText: 'Select a date (Optional)',
        prefixIcon: Icon(Icons.calendar_today_outlined),
      ),
      onTap: _selectDate,
    );
  }

  Widget _buildPrioritySelector() {
    return DropdownButtonFormField<String>(
      initialValue: _priority,
      decoration: const InputDecoration(
        labelText: 'Priority',
        prefixIcon: Icon(Icons.flag_outlined),
      ),
      items: ['High', 'Medium', 'Low'].map((priority) {
        return DropdownMenuItem(
          value: priority,
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: _priorityColors[priority],
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              Text(priority),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _priority = value;
          });
        }
      },
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
      child: FilledButton.icon(
        onPressed: _saveTask,
        icon: const Icon(Icons.save_alt_rounded),
        label: Text(
          isEditing ? 'Update Task' : 'Create Task',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
