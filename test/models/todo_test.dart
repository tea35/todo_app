import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/models/todo.dart';

void main() {
  group('Todo', () {
    test('初期状態ではisDoneがfalseになる', () {
      final todo = Todo(id: 'test-id-1', title: 'テストタスク');
      expect(todo.title, 'テストタスク');
      expect(todo.isDone, false);
    });

    test('isDoneをtrueで初期化できる', () {
      final todo = Todo(id: 'test-id-2', title: 'テストタスク', isDone: true);
      expect(todo.isDone, true);
    });
  });
}
