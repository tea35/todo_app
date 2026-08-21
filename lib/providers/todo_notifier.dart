import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';
import '../models/todo_filter.dart';
import '../repositories/todo_repository.dart';
import '../services/notification_service.dart';

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

final localOrderedTodosProvider = StateProvider<List<Todo>?>((ref) => null);

class TodoActions {
  final Ref ref;
  TodoActions(this.ref);

  void addTodo(String title, {DateTime? dueDate}) async {
    await ref.read(todoRepositoryProvider).addTodo(title, dueDate: dueDate);

    if (dueDate != null) {
      final notificationId =
          DateTime.now().millisecondsSinceEpoch.remainder(100000);
      await NotificationService().scheduleNotification(
        id: notificationId,
        title: title,
        scheduledDate: dueDate,
      );
    }
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

  Future<void> saveOrder(List<Todo> reorderedTodos) async {
    await ref.read(todoRepositoryProvider).updateOrder(reorderedTodos);
  }

  Future<void> reorder(
      List<Todo> currentList, int oldIndex, int newIndex) async {
    try {
      print('並び替え前: ${currentList.map((t) => t.title).toList()}');
      print('oldIndex: $oldIndex, newIndex: $newIndex');

      if (oldIndex < newIndex) {
        newIndex -= 1;
      }

      final newList = [...currentList];
      final item = newList.removeAt(oldIndex);
      newList.insert(newIndex, item);

      print('並び替え後: ${newList.map((t) => t.title).toList()}');

      await ref.read(todoRepositoryProvider).updateOrder(newList);
      print('並び替え成功');
    } catch (e) {
      print('並び替えエラー: $e');
    }
  }
}

final todoActionsProvider = Provider<TodoActions>((ref) {
  return TodoActions(ref);
});
