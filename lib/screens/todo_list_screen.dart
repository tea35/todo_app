import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_notifier.dart';
import '../models/todo_filter.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen> {
  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    ref.read(todoListProvider.notifier).addTodo(text);
    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todos = ref.watch(filteredTodoListProvider);
    final allTodos = ref.watch(todoListProvider);
    final incompleteCount = allTodos.where((todo) => !todo.isDone).length;
    final currentFilter = ref.watch(todoFilterProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('TODOリスト (未完了: $incompleteCount / 全${allTodos.length}件)'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: SegmentedButton<TodoFilter>(
              segments: const [
                ButtonSegment(value: TodoFilter.all, label: Text('すべて')),
                ButtonSegment(value: TodoFilter.active, label: Text('未完了')),
                ButtonSegment(value: TodoFilter.completed, label: Text('完了済み')),
              ],
              selected: {currentFilter},
              onSelectionChanged: (newSelection) {
                ref
                    .read(todoFilterProvider.notifier)
                    .setFilter(newSelection.first);
              },
            ),
          ),
          Padding(
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
          ),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                final todo = todos[index];
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
                    final originalIndex =
                        ref.read(todoListProvider).indexOf(todo);
                    ref.read(todoListProvider.notifier).removeAt(originalIndex);
                  },
                  child: ListTile(
                    title: Text(
                      todo.title,
                      style: TextStyle(
                        decoration: todo.isDone
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                        color: todo.isDone ? Colors.grey : null,
                      ),
                    ),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        final originalIndex =
                            ref.read(todoListProvider).indexOf(todo);
                        ref
                            .read(todoListProvider.notifier)
                            .toggleDone(originalIndex);
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
