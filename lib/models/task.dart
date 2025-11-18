enum TaskPriority{
  low,
  medium,
  high,
}

class Task{
  String id;
  String title;
  bool isDone;
  TaskPriority priority;
  DateTime? dueDate;
  String notes;
  String? categoryId;

  Task({
    required this.id,
    required this.title,
    this.isDone = false,
    this.priority = TaskPriority.medium, // default medium
    this.dueDate,
    this.notes = '',
    this.categoryId,
  });

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'isDone': isDone,
      'priority': priority.index, // menyimpan index priority
      'dueDate': dueDate?.toIso8601String(), // menyimpan tanggal kedaluwarsa
      'notes': notes,
      'categoryId': categoryId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map){
    return Task(
      id: map['id'],
      title: map['title'],
      isDone: map['isDone'] ?? false, // null safety
      priority: TaskPriority.values[map['priority'] ?? 1], // default medium
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      notes: map['notes'] ?? '',
      categoryId: map['categoryId'],
    );
  }
}