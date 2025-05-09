import 'package:flutter/material.dart';
import 'task_model.dart';
import 'package:intl/intl.dart';

class TaskListScreen extends StatefulWidget {
  final String title;
  final List<Task> tasks;
  final Function(Task) onTaskAdded;
  final Function(int) onTaskDeleted;
  final Function(int, bool) onTaskToggled;
  final bool isDateSpecific;
  final DateTime? selectedDate;

  const TaskListScreen({
    super.key,
    required this.title,
    required this.tasks,
    required this.onTaskAdded,
    required this.onTaskDeleted,
    required this.onTaskToggled,
    this.isDateSpecific = false,
    this.selectedDate,
  });

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TextEditingController _taskController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: widget.tasks.isEmpty
          ? Center(
        child: Text(
          widget.isDateSpecific
              ? 'Нет задач на эту дату'
              : 'Нет задач. Добавьте первую!',
          style: const TextStyle(fontSize: 18),
        ),
      )
          : ListView.builder(
        itemCount: widget.tasks.length,
        itemBuilder: (context, index) {
          final task = widget.tasks[index];
          return Dismissible(
            key: Key(task.id),
            direction: DismissDirection.endToStart,
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
                  title: const Text('Подтверждение'),
                  content: Text('Удалить задачу "${task.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Удалить'),
                    ),
                  ],
                ),
              );
            },
            onDismissed: (direction) {
              widget.onTaskDeleted(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Задача "${task.title}" удалена')),
              );
            },
            child: Card(
              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              child: ListTile(
                leading: Checkbox(
                  value: task.completed,
                  onChanged: (value) {
                    setState(() {
                      task.completed = value ?? false;
                    });
                    widget.onTaskToggled(index, value ?? false);
                  },
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    decoration: task.completed
                        ? TextDecoration.lineThrough
                        : null,
                  ),
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _showAddTaskDialog,
      ),
    );
  }

  void _showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Добавить задачу'),
        content: TextField(
          controller: _taskController,
          decoration: const InputDecoration(
            hintText: 'Введите задачу',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_taskController.text.isNotEmpty) {
                final newTask = Task(
                  title: _taskController.text,
                  date: widget.isDateSpecific
                      ? DateFormat('yyyy-MM-dd').format(widget.selectedDate!)
                      : widget.title,
                );
                widget.onTaskAdded(newTask);
                _taskController.clear();
                Navigator.pop(context);
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _taskController.dispose();
    super.dispose();
  }
}