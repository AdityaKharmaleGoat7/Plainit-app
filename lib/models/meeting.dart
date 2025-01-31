class Meeting {
  final String title;
  final DateTime dateTime;
  final String description;

  Meeting({
    required this.title,
    required this.dateTime,
    this.description = '',
  });
}
  