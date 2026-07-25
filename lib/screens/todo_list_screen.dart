import 'package:flutter/material.dart';
import '../models/todo.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListString = prefs.getString('todos');
    if (todoListString != null) {
      final decoded = jsonDecode(todoListString) as List;
      setState(() {
        _todos.clear();
        _todos.addAll(decoded.map((item) => Todo(
              title: item['title'],
              isDone: item['isDone'],
            )));
      });
    }
  }

  Future<void> _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final todoListJson = _todos
        .map((todo) => {
              'title': todo.title,
              'isDone': todo.isDone,
            })
        .toList();
    await prefs.setString('todos', jsonEncode(todoListJson));
  }

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(Todo(title: text));
    });
    _saveTodos();

    _textController.clear();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todoリスト'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
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
                    onSubmitted: (_) => _addTodo(), // Enterキーでも追加できる
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
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
                return Dismissible(
                    key: ValueKey(todo), // ← 各アイテムを識別するための一意なキー
                    direction: DismissDirection.endToStart, // 右から左へのスワイプのみ許可
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      setState(() {
                        _todos.removeAt(index);
                      });
                      _saveTodos();
                    },
                    child: ListTile(
                      title: Text(todo.title),
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize.min, // ← Rowの幅を中身分だけに抑える(前回学んだやつです)
                        children: [
                          Checkbox(
                            value: todo.isDone,
                            onChanged: (value) {
                              setState(() {
                                todo.isDone = value ?? false;
                              });
                              _saveTodos();
                            },
                          ),
                        ],
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }
}
