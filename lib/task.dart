class Task {
  String title;
  String description;
  String? time;
  bool isDone;

  Task({
    required this.title,
    this.description = '',
    this.time,
    this.isDone = false,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'time': time,
        'isDone': isDone,
      };

  static Task fromJson(Map<String, dynamic> json) => Task(
        title: json['title'],
        description: json['description'] ?? '',
        time: json['time'],
        isDone: json['isDone'],
      );
}