import 'package:flutter/material.dart';
import '../models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Todo> _todos = [
    Todo(title: '牛乳を買う'),
    Todo(title: 'レポートを書く'),
    Todo(title: '部屋を片付ける'),
  ];

  final TextEditingController _textController = TextEditingController();

  void _addTodo() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _todos.add(Todo(title: text));
    });

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
