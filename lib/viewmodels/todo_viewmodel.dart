import 'package:flutter/foundation.dart';
import '../models/todo_model.dart';
import '../services/database_helper.dart';
import '../services/notification_service.dart';

class TodoViewModel extends ChangeNotifier {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final NotificationService _notificationService = NotificationService();
  List<Todo> _todos = [];
  List<Todo> _deletedTodos = [];
  bool _isLoading = false;

  List<Todo> get todos => _todos;
  List<Todo> get deletedTodos => _deletedTodos;
  bool get isLoading => _isLoading;

  Future<void> loadTodos() async {
    _isLoading = true;
    notifyListeners();

    _todos = await _databaseHelper.getTodos();
    _todos.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDeletedTodos() async {
    _isLoading = true;
    notifyListeners();

    _deletedTodos = await _databaseHelper.getDeletedTodos();
    _deletedTodos.sort((a, b) {
      final aDate = a.deletedAt ?? DateTime.now();
      final bDate = b.deletedAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });

    _isLoading = false;
    notifyListeners();
  }

  Future<void> softDeleteTodo(int id) async {
    await _notificationService.cancelNotification(id);
    await _databaseHelper.softDeleteTodo(id);
    await loadTodos();
    await loadDeletedTodos();
  }

  Future<void> restoreTodo(int id) async {
    await _databaseHelper.restoreTodo(id);
    await loadTodos();
    await loadDeletedTodos();
  }

  Future<void> addTodo(
    String title,
    String description,
    DateTime? reminderDate,
    String? reminderType,
  ) async {
    try {
      final todo = Todo(
        title: title,
        description: description,
        reminderDate: reminderDate,
        reminderType: reminderType,
      );

      final id = await _databaseHelper.insertTodo(todo);
      todo.id = id;

      if (reminderDate != null && reminderType != null) {
        await _notificationService.scheduleTodoReminder(todo);
      }

      await loadTodos();
    } catch (e) {
      print('Görev eklenirken hata oluştu: $e');
      // Hata durumunda kullanıcıya bilgi verebilirsiniz
      rethrow;
    }
  }

  Future<void> toggleTodoStatus(Todo todo) async {
    todo.isCompleted = !todo.isCompleted;
    await _databaseHelper.updateTodo(todo);
    await loadTodos();
  }

  Future<void> deleteTodo(int id) async {
    await _databaseHelper.deleteTodo(id);
    await loadTodos();
  }

  Future<void> updateTodo(
    Todo todo,
    String title,
    String description,
    DateTime? reminderDate,
    String? reminderType,
  ) async {
    try {
      todo.title = title;
      todo.description = description;
      todo.reminderDate = reminderDate;
      todo.reminderType = reminderType;

      await _databaseHelper.updateTodo(todo);

      // Eski bildirimi iptal et
      if (todo.id != null) {
        await _notificationService.cancelNotification(todo.id!);
      }

      // Yeni bildirimi ayarla
      if (reminderDate != null && reminderType != null) {
        try {
          await _notificationService.scheduleTodoReminder(todo);
        } catch (e) {
          print('Bildirim ayarlanırken hata oluştu: $e');
          // Bildirimi ayarlayamadık ama görev güncellendi
          // Kullanıcıya bilgi verelim ama işlemi iptal etmeyelim
          rethrow;
        }
      }

      await loadTodos();
    } catch (e) {
      print('Görev güncellenirken hata oluştu: $e');
      rethrow;
    }
  }
}
