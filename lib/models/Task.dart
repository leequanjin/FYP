class Task {
  final int? id;
  final String title;
  final String date;
  final int status;

  Task({
    this.id,
    required this.title,
    required this.date,
    required this.status,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      date: map['date'] as String,
      status: map['status'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'title': title,
      'date': date,
      'status': status,
    };
    if (id != null) map['id'] = id;
    return map;
  }
}