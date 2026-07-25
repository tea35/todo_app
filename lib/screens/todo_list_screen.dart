import 'package:flutter/material.dart';
import '../models/todo.dart';
import '../repositories/todo_repository.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [];
  final TextEditingController _textController = TextEditingController();
  final TodoRepository _repository = TodoRepository(); // ← Repositoryのインスタンスを保持

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  Future<void> _loadTodos() async {
    final todos = await _repository.loadTodos();
    setState(() {
      _todos.clear();
      _todos.addAll(todos);
    });
  }

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(Todo(title: text));
    });
    _repository.saveTodos(_todos); // ← 直接SharedPreferencesを呼ばず、Repository経由に

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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('TODOリスト'),
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
              itemCount: _todos.length,
              itemBuilder: (context, index) {
                final todo = _todos[index];
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
                    setState(() {
                      _todos.removeAt(index);
                    });
                    _repository.saveTodos(_todos); // ← ここも変更
                  },
                  child: ListTile(
                    title: Text(todo.title),
                    trailing: Checkbox(
                      value: todo.isDone,
                      onChanged: (value) {
                        setState(() {
                          todo.isDone = value ?? false;
                        });
                        _repository.saveTodos(_todos); // ← ここも変更
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
