import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moodly/db/tables/task_table.dart';
import 'package:moodly/models/Task.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<Task> _tasks = [];
  String? _task;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await TaskTable.getAll();
    setState(() => _tasks = tasks);
  }

  void _addTask() {
    _task = null;
    _date = DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Task'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    onChanged: (value) => _task = value,
                    decoration: const InputDecoration(
                      hintText: 'Task Title',
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      _date = picked;
                      setDialogState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd-MM-yyyy').format(_date),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.check),
                    label: const Text('Add Task'),
                    onPressed: () async {
                      if (_task?.trim().isEmpty ?? true) return;

                      await TaskTable.add(_task!.trim(), _date);
                      Navigator.of(dialogContext).pop();
                      _loadTasks();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  void _editTask(Task task) {
    String editedTitle = task.title;
    DateTime editedDate = DateFormat('dd-MM-yyyy').parse(task.date);
    final titleController = TextEditingController(text: editedTitle);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Edit Task'),
        content: StatefulBuilder(
          builder: (context, setDialogState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  borderRadius: BorderRadius.circular(8),
                  child: TextField(
                    controller: titleController,
                    onChanged: (value) => editedTitle = value,
                    decoration: const InputDecoration(
                      hintText: 'Task Title',
                      border: UnderlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Due Date',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: editedDate,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      editedDate = picked;
                      setDialogState(() {});
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Theme.of(context).dividerColor),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          DateFormat('dd-MM-yyyy').format(editedDate),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                    onPressed: () async {
                      if (editedTitle.trim().isEmpty) return;

                      await TaskTable.update(
                        task.id!,
                        editedTitle.trim(),
                        editedDate,
                      );
                      Navigator.of(dialogContext).pop();
                      _loadTasks();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _toggleCompletion(Task task) async {
    final updatedStatus = task.status == 0 ? 1 : 0;
    await TaskTable.updateStatus(task.id!, updatedStatus);
    _loadTasks();
  }

  Future<void> _deleteTask(Task task) async {
    await TaskTable.delete(task.id!);
    _loadTasks();
  }

  DateTime _parseDate(String date) => DateFormat('dd-MM-yyyy').parse(date);

  bool _isPast(Task task) {
    final today = DateTime.now();
    final taskDate = _parseDate(task.date);
    return taskDate.isBefore(DateTime(today.year, today.month, today.day));
  }

  bool _isToday(Task task) {
    final today = DateTime.now();
    final taskDate = _parseDate(task.date);
    return taskDate.year == today.year &&
        taskDate.month == today.month &&
        taskDate.day == today.day;
  }

  bool _isFuture(Task task) {
    final today = DateTime.now();
    final taskDate = _parseDate(task.date);
    return taskDate.isAfter(DateTime(today.year, today.month, today.day));
  }

  @override
  Widget build(BuildContext context) {
    final previousItems =
        _tasks
            .where((t) => _isPast(t) && t.status == 0 && !_isToday(t))
            .toList()
          ..sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));

    final todayItems =
        _tasks.where((t) => _isToday(t) && t.status == 0).toList()
          ..sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));

    final futureItems =
        _tasks.where((t) => _isFuture(t) && t.status == 0).toList()
          ..sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));

    final completedItems = _tasks.where((t) => t.status == 1).toList()
      ..sort((a, b) => _parseDate(a.date).compareTo(_parseDate(b.date)));

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeInOut,
            switchOutCurve: Curves.easeInOut,
            child: ListView(
              key: ValueKey(_tasks),
              children: [
                ..._buildSection("Previous", previousItems),
                ..._buildSection("Today", todayItems),
                ..._buildSection("Upcoming", futureItems),
                ..._buildSection("Completed", completedItems),
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

  List<Widget> _buildSection(String title, List<Task> items) => [
    SectionHeader(title: title),
    const SizedBox(height: 4),
    Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outlineVariant,
      indent: 8,
      endIndent: 8,
    ),
    const SizedBox(height: 8),
    ...items.map(
      (task) => TodoCard(
        task: task,
        onToggle: _toggleCompletion,
        onEdit: _editTask,
        onDelete: _deleteTask,
      ),
    ),
    const SizedBox(height: 24),
  ];
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12.0),
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
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
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
                  if (value == 'edit') onEdit(task);
                  if (value == 'delete') onDelete(task);
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
