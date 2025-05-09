import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String date;
  bool completed;

  Task({
    String? id,
    required this.title,
    required this.date,
    this.completed = false,
  }) : id = id ?? const Uuid().v4();

  @override
  String toString() {
    return 'Task{id: $id, title: $title, date: $date, completed: $completed}';
  }
}