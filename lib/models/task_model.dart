class Task {
  final String title;
  final String status;

  Task({required this.title, required this.status});

  factory Task.fromJson(Map json) {
    return Task(
      title: json['title'],
      status: json['status'],
    );
  }
}