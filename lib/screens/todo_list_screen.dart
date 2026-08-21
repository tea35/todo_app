import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timezone/timezone.dart';
import '../models/todo_filter.dart';
import '../providers/todo_notifier.dart';
import '../widgets/widgets.dart';

class TodoListScreen extends ConsumerWidget {
  const TodoListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosAsync = ref.watch(todoListStreamProvider);
    final serverTodos = ref.watch(filteredTodoListProvider);
    final localOverride = ref.watch(localOrderedTodosProvider);
    final currentFilter = ref.watch(todoFilterProvider);

    final todos = localOverride ?? serverTodos;
    print(
        '画面再描画: ${todos.map((t) => t.title).toList()}'); // デバッグ用: 画面再描画時にタスクのタイトルを出力

    final allTodos = todosAsync.value ?? [];
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
            child: todosAsync.when(
              data: (_) => currentFilter == TodoFilter.all
                  ? const ReorderableTodoList()
                  : ListView.builder(
                      itemCount: todos.length,
                      itemBuilder: (context, index) {
                        return TodoListItem(
                          key: ValueKey(todos[index].id),
                          todo: todos[index],
                        );
                      },
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('エラー: $error')),
            ),
          ),
        ],
      ),
    );
  }
}
