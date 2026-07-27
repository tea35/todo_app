import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_notifier.dart';
import '../widgets/todo_filter_tabs.dart';
import '../widgets/todo_input_field.dart';
import '../widgets/todo_list_item.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todos = ref.watch(filteredTodoListProvider);
    final allTodos = ref.watch(todoListProvider);
    final incompleteCount = allTodos.where((todo) => !todo.isDone).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text('TODOリスト (未完了: $incompleteCount / 全${allTodos.length}件)'),
      ),
      body: Column(
        children: [
          const TodoFilterTabs(),
          const TodoInputField(),
          Expanded(
            child: ListView.builder(
              itemCount: todos.length,
              itemBuilder: (context, index) {
                return TodoListItem(todo: todos[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}
