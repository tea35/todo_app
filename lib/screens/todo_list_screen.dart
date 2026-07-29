import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/todo_notifier.dart';
import '../widgets/widgets.dart';
import '../models/todo_filter.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          const TodoFilterTabs(),
          const TodoInputField(),
          Expanded(
            child: currentFilter == TodoFilter.all
                ? ReorderableListView.builder(
                    itemCount: todos.length,
                    itemBuilder: (context, index) {
                      return TodoListItem(
                        key: ValueKey(todos[index]),
                        todo: todos[index],
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      ref
                          .read(todoListProvider.notifier)
                          .reorder(oldIndex, newIndex);
                    },
                  )
                : ListView.builder(
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
