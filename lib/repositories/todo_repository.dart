import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/todo.dart';

class TodoRepository {
  String get _uid {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('ユーザーがログインしていません');
    }
    return user.uid;
  }

  CollectionReference get _todosCollection {
    return FirebaseFirestore.instance
        .collection('todos')
        .doc(_uid)
        .collection('tasks');
  }

  Stream<List<Todo>> watchTodos() {
    return _todosCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Todo(
          id: doc.id,
          title: data['title'],
          isDone: data['isDone'],
          dueDate: data['dueDate'] != null
              ? (data['dueDate'] as Timestamp).toDate() // ← Firestore独自の日付型を変換
              : null,
        );
      }).toList();
    });
  }

  Future<void> addTodo(String title, {DateTime? dueDate}) async {
    await _todosCollection.add({
      'title': title,
      'isDone': false,
      'dueDate': dueDate != null
          ? Timestamp.fromDate(dueDate)
          : null, // ← Dartの日付をFirestore用に変換
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosCollection.doc(todo.id).update({
      'title': todo.title,
      'isDone': todo.isDone,
      'dueDate':
          todo.dueDate != null ? Timestamp.fromDate(todo.dueDate!) : null,
    });
  }

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
