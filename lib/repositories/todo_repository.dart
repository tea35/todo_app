import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/todo.dart';

class TodoRepository {
  static const _storageKey = 'todos';

  Future<List<Todo>> loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString(_storageKey);

    if (todoListString == null) {
      return [];
    }

    final decoded = jsonDecode(todoListString) as List;
    return decoded
        .map((item) => Todo(
              title: item['title'],
              isDone: item['isDone'],
            ))
        .toList();
  }

  Future<void> saveTodos(List<Todo> todos) async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = todos
        .map((todo) => {
              'title': todo.title,
              'isDone': todo.isDone,
            })
        .toList();
    await prefs.setString(_storageKey, jsonEncode(todoListJson));
  }
}
