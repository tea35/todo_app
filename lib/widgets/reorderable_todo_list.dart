import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../providers/todo_notifier.dart';
import 'todo_list_item.dart';

class ReorderableTodoList extends ConsumerStatefulWidget {
  const ReorderableTodoList({super.key});

  @override
  ConsumerState<ReorderableTodoList> createState() =>
      _ReorderableTodoListState();
}

class _ReorderableTodoListState extends ConsumerState<ReorderableTodoList> {
  late List<Todo> _cachedTodos;

  @override
  void initState() {
    super.initState();
    // 初回のみ、現在の値を読み込む(以降、このWidgetが生きている間はwatchしない)
    _cachedTodos = ref.read(filteredTodoListProvider);
  }

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: _cachedTodos.length,
      itemBuilder: (context, index) {
        return TodoListItem(
          key: ValueKey(_cachedTodos[index].id),
          todo: _cachedTodos[index],
        );
      },
      onReorder: (oldIndex, newIndex) {
        if (oldIndex < newIndex) newIndex -= 1;

        setState(() {
          final item = _cachedTodos.removeAt(oldIndex);
          _cachedTodos.insert(newIndex, item);
        });

        ref.read(todoActionsProvider).saveOrder(_cachedTodos);
      },
    );
  }
}
