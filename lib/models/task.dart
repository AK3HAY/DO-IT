import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String? description;

  @HiveField(3)
  bool isCompleted;

  @HiveField(4)
  String priority;

  @HiveField(5)
  DateTime? dueDate;

  @HiveField(6)
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = 'Medium',
    this.dueDate,
    required this.createdAt,
  }) : id = id ?? const Uuid().v4();

  Task.from(Task other)
      : id = other.id,
        title = other.title,
        description = other.description,
        isCompleted = other.isCompleted,
        priority = other.priority,
        dueDate = other.dueDate,
        createdAt = other.createdAt;
}
