class Todo {
  int? id;
  String title;
  String description;
  bool isCompleted;
  bool isDeleted;
  DateTime createdAt;
  DateTime? deletedAt;
  DateTime? reminderDate;
  String? reminderType;

  Todo({
    this.id,
    required this.title,
    required this.description,
    this.isCompleted = false,
    this.isDeleted = false,
    this.deletedAt,
    this.reminderDate,
    this.reminderType,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
      'isDeleted': isDeleted ? 1 : 0,
      'deletedAt': deletedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'reminderDate': reminderDate?.toIso8601String(),
      'reminderType': reminderType,
    };
  }

  factory Todo.fromMap(Map<String, dynamic> map) {
    return Todo(
      id: map['id'],
      title: map['title'],
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
      isDeleted: map['isDeleted'] == 1,
      deletedAt: map['deletedAt'] != null ? DateTime.parse(map['deletedAt']) : null,
      createdAt: DateTime.parse(map['createdAt']),
      reminderDate: map['reminderDate'] != null ? DateTime.parse(map['reminderDate']) : null,
      reminderType: map['reminderType'],
    );
  }
}
