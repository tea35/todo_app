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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todoリスト'),
        backgroundColor: Colors.deepPurple[300],
      ),
      body: ListView.builder(
          itemCount: _todos.length,
          itemBuilder: (context, index) {
            final todo = _todos[index];
            return ListTile(
                title: Text(todo.title),
                trailing: Checkbox(
                    value: todo.isDone,
                    onChanged: (bool? value) {
                      setState(() {
                        todo.isDone = value ?? false;
                      });
                    }));
          }),
    );
  }
}
