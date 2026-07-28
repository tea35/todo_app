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
              onPressed: () =>
                  Navigator.pop(context, controller.text.trim()), // 入力値を返して閉じる
              child: const Text('保存'),
            ),
          ],
        );
      },
    );

    if (result != null && result.isNotEmpty) {
      final originalIndex = ref.read(todoListProvider).indexOf(todo);
      ref.read(todoListProvider.notifier).editTodo(originalIndex, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey(todo),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        final originalIndex = ref.read(todoListProvider).indexOf(todo);
        ref.read(todoListProvider.notifier).removeAt(originalIndex);
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
        trailing: Checkbox(
          value: todo.isDone,
          onChanged: (value) {
            final originalIndex = ref.read(todoListProvider).indexOf(todo);
            ref.read(todoListProvider.notifier).toggleDone(originalIndex);
          },
        ),
      ),
    );
  }
}
