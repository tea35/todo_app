class Todo {
  final String id;
  final String title;
  bool isDone;
  final DateTime? dueDate; // ← 追加(nullable: 期限を設定しない場合もあるため)

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
  });
}
