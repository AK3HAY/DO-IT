import 'package:hive/hive.dart';
import 'package:todo_app/models/task.dart';
import 'package:uuid/uuid.dart';

class HiveService {
  static const String _boxName = 'tasksBox';

  Future<Box<Task>> openBox() async {
    return await Hive.openBox<Task>(_boxName);
  }

  Box<Task> getTasksBox() {
    return Hive.box<Task>(_boxName);
  }

  Future<void> addTask(Task task) async {
    final box = getTasksBox();
    task.id = const Uuid().v4();
    await box.put(task.id, task);
  }

  Future<void> updateTask(Task task) async {
    await task.save();
  }

  Future<void> deleteTask(Task task) async {
    await task.delete();
  }
}
