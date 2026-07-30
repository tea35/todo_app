import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/todo.dart';

class TodoRepository {
  final CollectionReference _todosCollection =
      FirebaseFirestore.instance.collection('todos');

  // Firestoreからリアルタイムでデータの変化を受け取るストリーム
  Stream<List<Todo>> watchTodos() {
    return _todosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Todo(
          id: doc.id,
          title: data['title'],
          isDone: data['isDone'],
        );
      }).toList();
    });
  }

  Future<void> addTodo(String title) async {
    await _todosCollection.add({
      'title': title,
      'isDone': false,
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosCollection.doc(todo.id).update({
      'title': todo.title,
      'isDone': todo.isDone,
    });
  }

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
