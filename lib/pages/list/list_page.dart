import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/models/task.dart';
import 'package:moodly/services/database_service.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  List<Task> _tasks = [];
  String? _task;
  DateTime? _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    final tasks = await _databaseService.getTasks();
    setState(() {
      _tasks = tasks;
    });
  }

  void _addTask() {
    _date = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add Task'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  onChanged: (value) {
                    setState(() {
                      _task = value;
                    });
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Task Title',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          _date != null
                              ? DateFormat('dd-MM-yyyy').format(_date!)
                              : 'No date selected',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _date ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _date = picked;
                          });
                          setDialogState(() {}); // Refresh UI inside dialog
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (_task?.trim().isEmpty ?? true) return;

                    await _databaseService.addTask(_task!.trim(), _date!);

                    setState(() {
                      _task = null;
                    });

                    Navigator.of(dialogContext).pop();
                    _loadTasks();
                  },
                  child: const Text('Add Task'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _toggleCompletion(Task task) async {
    final updatedStatus = task.status == 0 ? 1 : 0;
    await _databaseService.updateTaskStatus(task.id, updatedStatus);
    _loadTasks();
  }

  void _deleteTask(Task task) async {
    await _databaseService.deleteTask(task.id);
    _loadTasks();
  }

  void _editTask(Task task) {
    String editedTitle = task.title;
    DateTime editedDate = DateFormat('dd-MM-yyyy').parse(task.date);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Task'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: editedTitle),
                  onChanged: (value) {
                    editedTitle = value;
                  },
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Task Title',
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          DateFormat('dd-MM-yyyy').format(editedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: editedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          editedDate = picked;
                          setDialogState(() {}); // refresh UI
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  onPressed: () async {
                    if (editedTitle.trim().isEmpty) return;

                    await _databaseService.updateTask(
                      task.id,
                      editedTitle.trim(),
                      editedDate,
                    );

                    Navigator.of(dialogContext).pop();
                    _loadTasks();
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  DateTime parseDate(String date) => DateFormat('dd-MM-yyyy').parse(date);

  bool isPast(Task task) {
    final today = DateTime.now();
    final taskDate = parseDate(task.date);
    return taskDate.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool isToday(Task task) {
    final today = DateTime.now();
    final taskDate = parseDate(task.date);
    return taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day;
  }

  bool isFuture(Task task) {
    final today = DateTime.now();
    final taskDate = parseDate(task.date);
    return taskDate.isAfter(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final previousItems =
        _tasks
            .where((t) => isPast(t) && (t.status == 0) && !isToday(t))
            .toList()
          ..sort((a, b) => parseDate(a.date).compareTo(parseDate(b.date)));
    final todayItems =
        _tasks.where((t) => isToday(t) && (t.status == 0)).toList()
          ..sort((a, b) => parseDate(a.date).compareTo(parseDate(b.date)));
    final futureItems =
        _tasks.where((t) => isFuture(t) && (t.status == 0)).toList()
          ..sort((a, b) => parseDate(a.date).compareTo(parseDate(b.date)));
    final completedItems = _tasks.where((t) => (t.status == 1)).toList()
      ..sort((a, b) => parseDate(a.date).compareTo(parseDate(b.date)));

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Expanded(
            child: ListView(
              children: [
                if (previousItems.isNotEmpty) ...[
                  const SectionHeader(title: "Previous"),
                  const SizedBox(height: 4),
                  ...previousItems.map(
                    (task) => TodoCard(
                      task: task,
                      onToggle: _toggleCompletion,
                      onEdit: _editTask,
                      onDelete: _deleteTask,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (todayItems.isNotEmpty) ...[
                  const SectionHeader(title: "Today"),
                  const SizedBox(height: 4),
                  ...todayItems.map(
                    (task) => TodoCard(
                      task: task,
                      onToggle: _toggleCompletion,
                      onEdit: _editTask,
                      onDelete: _deleteTask,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (futureItems.isNotEmpty) ...[
                  const SectionHeader(title: "Upcoming"),
                  const SizedBox(height: 4),
                  ...futureItems.map(
                    (task) => TodoCard(
                      task: task,
                      onToggle: _toggleCompletion,
                      onEdit: _editTask,
                      onDelete: _deleteTask,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (completedItems.isNotEmpty) ...[
                  const SectionHeader(title: "Completed"),
                  const SizedBox(height: 4),
                  ...completedItems.map(
                    (task) => TodoCard(
                      task: task,
                      onToggle: _toggleCompletion,
                      onEdit: _editTask,
                      onDelete: _deleteTask,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            elevation: 2,
            onPressed: _addTask,
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(title, style: Theme.of(context).textTheme.titleSmall),
    );
  }
}

class TodoCard extends StatelessWidget {
  final Task task;
  final Function(Task) onToggle;
  final Function(Task) onEdit;
  final Function(Task) onDelete;

  const TodoCard({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 8.0),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: BorderSide(
          color: Theme.of(context).colorScheme.outlineVariant,
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Colored side bar
          Container(
            width: 6,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
          Expanded(
            child: ListTile(
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              leading: IconButton(
                icon: Icon(
                  task.status == 1
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: task.status == 1
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 20,
                ),
                onPressed: () => onToggle(task),
              ),
              title: Text(
                task.title,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                task.date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit(task);
                  } else if (value == 'delete') {
                    onDelete(task);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
