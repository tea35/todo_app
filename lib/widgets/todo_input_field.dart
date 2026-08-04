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
  DateTime? _selectedDueDate;

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref
        .read(todoActionsProvider)
        .addTodo(text, dueDate: _selectedDueDate); // ← todoActionsProvider経由に変更
    _textController.clear();
    setState(() {
      _selectedDueDate = null;
    });
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
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
      child: Column(
        children: [
          Row(
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
          const SizedBox(height: 8),
          Row(
            children: [
              TextButton.icon(
                onPressed: _pickDueDate,
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _selectedDueDate == null
                      ? '期限を設定'
                      : '${_selectedDueDate!.year}/${_selectedDueDate!.month}/${_selectedDueDate!.day}',
                ),
              ),
              if (_selectedDueDate != null)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => _selectedDueDate = null),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
