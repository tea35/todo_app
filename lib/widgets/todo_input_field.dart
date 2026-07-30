import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_notifier.dart';

class TodoInputField extends ConsumerStatefulWidget {
  const TodoInputField({super.key});

  @override
  ConsumerState<TodoInputField> createState() => _TodoInputFieldState();
}

class _TodoInputFieldState extends ConsumerState<TodoInputField> {
  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(todoActionsProvider).addTodo(text); // ← todoActionsProvider経由に変更
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: 'タスクを入力',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => _addTodo(),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _addTodo,
            child: const Text('追加'),
          ),
        ],
      ),
    );
  }
}
