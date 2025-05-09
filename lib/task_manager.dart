import 'package:flutter/material.dart';
import 'task_list_screen.dart';
import 'task_model.dart';
import 'package:intl/intl.dart';

class TaskManagerHome extends StatefulWidget {
  const TaskManagerHome({super.key});

  @override
  State<TaskManagerHome> createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome> {
  final Map<String, List<Task>> _tasks = {
    'Годовые': [],
    'Недельные': [],
    'Ежедневные': [],
    'На дату': [],
  };

  @override
  Widget build(BuildContext context) {
    // Группируем задачи по датам
    final dateTasksMap = <String, List<Task>>{};
    for (final task in _tasks['На дату']!) {
      if (!dateTasksMap.containsKey(task.date)) {
        dateTasksMap[task.date] = [];
      }
      dateTasksMap[task.date]!.add(task);
    }

    // Сортируем даты по возрастанию
    final sortedDates = dateTasksMap.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Менеджер задач'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTaskCategoryCard('Годовые', Icons.calendar_today),
            const SizedBox(height: 16),
            _buildTaskCategoryCard('Недельные', Icons.calendar_view_week),
            const SizedBox(height: 16),
            _buildTaskCategoryCard('Ежедневные', Icons.today),
            ...sortedDates.map((date) => Column(
              children: [
                const SizedBox(height: 16),
                _buildDateTasksCard(
                  dateTasksMap[date]!,
                  DateFormat('dd.MM.yyyy').format(DateTime.parse(date)),
                ),
              ],
            )),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => _showDatePickerDialog(context),
      ),
    );
  }

  Widget _buildTaskCategoryCard(String title, IconData icon) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskListScreen(
                title: title,
                tasks: _tasks[title]!,
                onTaskAdded: (task) {
                  setState(() {
                    _tasks[title]!.add(task);
                  });
                },
                onTaskDeleted: (index) {
                  setState(() {
                    _tasks[title]!.removeAt(index);
                  });
                },
                onTaskToggled: (index, completed) {
                  setState(() {
                    _tasks[title]![index].completed = completed;
                  });
                },
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(fontSize: 20),
              ),
              const Spacer(),
              Text(
                _tasks[title]!.length.toString(),
                style: const TextStyle(fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTasksCard(List<Task> tasks, String formattedDate) {
    // Получаем дату из первой задачи (все задачи в списке имеют одинаковую дату)
    final date = tasks.isNotEmpty ? tasks.first.date : '';

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskListScreen(
                title: formattedDate,
                tasks: tasks,
                onTaskAdded: (task) {
                  setState(() {
                    _tasks['На дату']!.add(task);
                  });
                },
                onTaskDeleted: (index) {
                  setState(() {
                    _tasks['На дату']!.removeWhere(
                            (t) => t.id == tasks[index].id);
                  });
                },
                onTaskToggled: (index, completed) {
                  setState(() {
                    tasks[index].completed = completed;
                  });
                },
                isDateSpecific: true,
                selectedDate: DateTime.parse(date),
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Задачи на $formattedDate',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...tasks.map((task) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Checkbox(
                      value: task.completed,
                      onChanged: (value) {
                        setState(() {
                          task.completed = value ?? false;
                        });
                      },
                    ),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
  Future<void> _showDatePickerDialog(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && mounted) {
      final dateKey = DateFormat('yyyy-MM-dd').format(pickedDate);
      final formattedDate = DateFormat('dd.MM.yyyy').format(pickedDate);

      // Проверяем, есть ли уже задачи на эту дату
      final hasTasksForDate = _tasks['На дату']!
          .any((task) => task.date == dateKey);

      // Если нет задач на эту дату, просто переходим к экрану добавления
      if (!hasTasksForDate) {
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskListScreen(
                    title: formattedDate,
                    tasks: [],
                    // Пустой список задач для новой даты
                    onTaskAdded: (task) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']!.add(task);
                        });
                      }
                    },
                    onTaskDeleted: (index) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']!.removeAt(index);
                        });
                      }
                    },
                    onTaskToggled: (index, completed) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']![index].completed = completed;
                        });
                      }
                    },
                    isDateSpecific: true,
                    selectedDate: pickedDate,
                  ),
            ),
          );
        }
      } else {
        // Если задачи на эту дату уже есть, показываем их
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  TaskListScreen(
                    title: formattedDate,
                    tasks: _tasks['На дату']!
                        .where((task) => task.date == dateKey)
                        .toList(),
                    onTaskAdded: (task) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']!.add(task);
                        });
                      }
                    },
                    onTaskDeleted: (index) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']!.removeAt(index);
                        });
                      }
                    },
                    onTaskToggled: (index, completed) {
                      if (mounted) {
                        setState(() {
                          _tasks['На дату']![index].completed = completed;
                        });
                      }
                    },
                    isDateSpecific: true,
                    selectedDate: pickedDate,
                  ),
            ),
          );
        }
      }
    }
  }
}