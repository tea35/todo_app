import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_notifier.dart';

class TodoListItem extends ConsumerWidget {
  final Todo todo;

  const TodoListItem({super.key, required this.todo});

  Future<void> _showEditDialog(BuildContext context, WidgetRef ref) async {
    final controller = TextEditingController(text: todo.title);

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('タスクを編集'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      ref.read(todoActionsProvider).editTodo(todo, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey('dismissible_${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        ref.read(todoActionsProvider).removeTodo(todo.id);
      },
      child: ListTile(
        title: GestureDetector(
          onTap: () => _showEditDialog(context, ref),
          child: Text(
            todo.title,
            style: TextStyle(
              decoration: todo.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              color: todo.isDone ? Colors.grey : null,
            ),
          ),
        ),
        subtitle: todo.dueDate != null
            ? Text(
                '期限: ${todo.dueDate!.year}/${todo.dueDate!.month}/${todo.dueDate!.day} '
                '${todo.dueDate!.hour.toString().padLeft(2, '0')}:${todo.dueDate!.minute.toString().padLeft(2, '0')}',
                style: TextStyle(
                  color: todo.dueDate!.isBefore(DateTime.now()) && !todo.isDone
                      ? Colors.red
                      : Colors.grey,
                ),
              )
            : null,
        trailing: Checkbox(
          value: todo.isDone,
          onChanged: (value) {
            ref.read(todoActionsProvider).toggleDone(todo);
          },
        ),
      ),
    );
  }
}
