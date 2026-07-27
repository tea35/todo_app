import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';
import '../repositories/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todoListProvider = NotifierProvider<TodoNotifier, List<Todo>>(() {
  return TodoNotifier();
});

class TodoNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    _loadTodos(); // 初期化時に読み込みを開始
    return []; // 最初は空リストを返す(読み込み完了後にstateを更新する)
  }

  Future<void> _loadTodos() async {
    final repository = ref.read(todoRepositoryProvider);
    final todos = await repository.loadTodos();
    state = todos; // 読み込み完了後、stateを更新 → 画面が自動的に再描画される
  }

  void addTodo(String title) {
    state = [...state, Todo(title: title)]; // 既存配列 + 新しい要素 で新しい配列を作る
    _save();
  }

  void toggleDone(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i == index)
          Todo(title: state[i].title, isDone: !state[i].isDone)
        else
          state[i]
    ];
    _save();
  }

  void removeAt(int index) {
    state = [
      for (int i = 0; i < state.length; i++)
        if (i != index) state[i]
    ];
    _save();
  }

  void _save() {
    final repository = ref.read(todoRepositoryProvider);
    repository.saveTodos(state);
  }
}

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilter>(() {
  return TodoFilterNotifier();
});

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all; // 初期値は「すべて表示」

  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.isDone).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.isDone).toList();
    case TodoFilter.all:
      return todos;
  }
});
