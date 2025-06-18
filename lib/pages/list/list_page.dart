import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TodoItem {
  String title;
  String date;
  bool completed;

  TodoItem({required this.title, required this.date, this.completed = false});

  DateTime get parsedDate => DateFormat('dd-MM-yyyy').parse(date);
}

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  List<TodoItem> todos = [
    TodoItem(title: "Buy groceries", date: "19-05-2025"),
    TodoItem(title: "Gym workout", date: "19-05-2025", completed: true),

    TodoItem(title: "Buy groceries", date: "19-06-2025"),
    TodoItem(title: "Gym workout", date: "19-06-2025", completed: true),

    TodoItem(title: "Submit FYP Chapter 4", date: "27-06-2025"),
    TodoItem(title: "Meet Leon", date: "09-10-2025"),

    TodoItem(title: "Dentist Appointment", date: "14-07-2025", completed: true),
    TodoItem(title: "Clean desk", date: "13-07-2025", completed: true),
  ];

  void toggleCompletion(TodoItem item) {
    setState(() {
      item.completed = !item.completed;
    });
  }

  void deleteTodo(TodoItem item) {
    setState(() {
      todos.remove(item);
    });
  }

  void editTodo(TodoItem item) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Edit '${item.title}' tapped")),
    );
  }

  bool isPast(TodoItem item) {
    final today = DateTime.now();
    final itemDate = item.parsedDate;
    return itemDate.isBefore(today);
  }

  bool isToday(TodoItem item) {
    final today = DateTime.now();
    final itemDate = item.parsedDate;
    return itemDate.year == today.year &&
        itemDate.month == today.month &&
        itemDate.day == today.day;
  }

  bool isFuture(TodoItem item) {
    final today = DateTime.now();
    final itemDate = item.parsedDate;
    return itemDate.isAfter(today);
  }

  @override
  Widget build(BuildContext context) {
    final previousItems = todos
        .where((t) => isPast(t) && !t.completed && !isToday(t))
        .toList();
    final todayItems = todos.where((t) => isToday(t) && !t.completed).toList();
    final futureItems = todos
        .where((t) => isFuture(t) && !t.completed)
        .toList();
    final completedItems = todos.where((t) => t.completed).toList();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Expanded(
        child: ListView(
          children: [
            if (previousItems.isNotEmpty) ...[
              const SectionHeader(title: "Previous"),
              const SizedBox(height: 4),
              ...previousItems.map(
                (todo) => TodoCard(
                  todo: todo,
                  onToggle: toggleCompletion,
                  onEdit: editTodo,
                  onDelete: deleteTodo,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (todayItems.isNotEmpty) ...[
              const SectionHeader(title: "Today"),
              const SizedBox(height: 4),
              ...todayItems.map(
                (todo) => TodoCard(
                  todo: todo,
                  onToggle: toggleCompletion,
                  onEdit: editTodo,
                  onDelete: deleteTodo,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (futureItems.isNotEmpty) ...[
              const SectionHeader(title: "Upcoming"),
              const SizedBox(height: 4),
              ...futureItems.map(
                (todo) => TodoCard(
                  todo: todo,
                  onToggle: toggleCompletion,
                  onEdit: editTodo,
                  onDelete: deleteTodo,
                ),
              ),
              const SizedBox(height: 12),
            ],
            if (completedItems.isNotEmpty) ...[
              const SectionHeader(title: "Completed"),
              const SizedBox(height: 4),
              ...completedItems.map(
                (todo) => TodoCard(
                  todo: todo,
                  onToggle: toggleCompletion,
                  onEdit: editTodo,
                  onDelete: deleteTodo,
                ),
              ),
            ],
          ],
        ),
      ),
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
  final TodoItem todo;
  final Function(TodoItem) onToggle;
  final Function(TodoItem) onEdit;
  final Function(TodoItem) onDelete;

  const TodoCard({
    super.key,
    required this.todo,
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
                  todo.completed
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: todo.completed
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  size: 20,
                ),
                onPressed: () => onToggle(todo),
              ),
              title: Text(
                todo.title,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                  decoration: todo.completed
                      ? TextDecoration.lineThrough
                      : null,
                ),
              ),
              subtitle: Text(
                todo.date,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              trailing: PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit(todo);
                  } else if (value == 'delete') {
                    onDelete(todo);
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
