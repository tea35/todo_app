class Todo {
  final String id;
  final String title;
  bool isDone;
  final DateTime? dueDate;
  final int order;

  Todo({
    required this.id,
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.order = 0,
  });
}
