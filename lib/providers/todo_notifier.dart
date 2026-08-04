import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';
import '../repositories/todo_repository.dart';

final todoRepositoryProvider = Provider<TodoRepository>((ref) {
  return TodoRepository();
});

final todoListStreamProvider = StreamProvider<List<Todo>>((ref) {
  final repository = ref.watch(todoRepositoryProvider);
  return repository.watchTodos();
});

final todoFilterProvider = NotifierProvider<TodoFilterNotifier, TodoFilter>(() {
  return TodoFilterNotifier();
});

class TodoFilterNotifier extends Notifier<TodoFilter> {
  @override
  TodoFilter build() => TodoFilter.all;

  void setFilter(TodoFilter filter) {
    state = filter;
  }
}

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todosAsync = ref.watch(todoListStreamProvider);
  final filter = ref.watch(todoFilterProvider);

  // todosAsyncは「読み込み中」「エラー」「成功」のいずれかの状態を持つ(後述)
  final todos = todosAsync.value ?? [];

  switch (filter) {
    case TodoFilter.active:
      return todos.where((todo) => !todo.isDone).toList();
    case TodoFilter.completed:
      return todos.where((todo) => todo.isDone).toList();
    case TodoFilter.all:
      return todos;
  }
});

class TodoActions {
  final Ref ref;
  TodoActions(this.ref);

  void addTodo(String title, {DateTime? dueDate}) {
    ref.read(todoRepositoryProvider).addTodo(title, dueDate: dueDate);
  }

  void toggleDone(Todo todo) {
    final updated = Todo(
      id: todo.id,
      title: todo.title,
      isDone: !todo.isDone,
      dueDate: todo.dueDate,
    );
    ref.read(todoRepositoryProvider).updateTodo(updated);
  }

  void editTodo(Todo todo, String newTitle, {DateTime? newDueDate}) {
    final updated = Todo(
      id: todo.id,
      title: newTitle,
      isDone: todo.isDone,
      dueDate: newDueDate,
    );
    ref.read(todoRepositoryProvider).updateTodo(updated);
  }

  void removeTodo(String id) {
    ref.read(todoRepositoryProvider).deleteTodo(id);
  }

  void reorder(int oldIndex, int newIndex) {
    // 注意: Firestoreでの並び替えは別途対応が必要(後述)
  }
}

final todoActionsProvider = Provider<TodoActions>((ref) {
  return TodoActions(ref);
});
