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
          order: data['order'] ?? 0,
        );
      }).toList();
    });
  }

  Future<void> addTodo(String title, {DateTime? dueDate}) async {
    final snapshot = await _todosCollection
        .orderBy('order', descending: true)
        .limit(1)
        .get();
    final maxOrder = snapshot.docs.isEmpty
        ? 0
        : (snapshot.docs.first.data() as Map<String, dynamic>)['order'] as int;

    await _todosCollection.add({
      'title': title,
      'isDone': false,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate) : null,
      'order': maxOrder + 1,
    });
  }

  Future<void> updateTodo(Todo todo) async {
    await _todosCollection.doc(todo.id).update({
      'title': todo.title,
      'isDone': todo.isDone,
      'dueDate':
          todo.dueDate != null ? Timestamp.fromDate(todo.dueDate!) : null,
      'order': todo.order,
    });
  }

  Future<void> updateOrder(List<Todo> reorderTodos) async {
    final batch = FirebaseFirestore.instance.batch();
    for (int i = 0; i < reorderTodos.length; i++) {
      final docRef = _todosCollection.doc(reorderTodos[i].id);
      batch.update(docRef, {'order': i});
    }
    await batch.commit();
  }

  Future<void> deleteTodo(String id) async {
    await _todosCollection.doc(id).delete();
  }
}
