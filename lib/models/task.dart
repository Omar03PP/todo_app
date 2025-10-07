class Task {
  String title;
  String description;
  bool done;
  DateTime? dueDate; 

  Task(
    this.title, {
    this.description = '',
    this.done = false,
    this.dueDate,
  });
}