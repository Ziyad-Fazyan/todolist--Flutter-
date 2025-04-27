import 'package:flutter/material.dart';
import '../models/todo_model.dart';

class TodoProvider extends ChangeNotifier {
  final List<Todo> _todos = [];
  final List<Todo> _completedTodos = [];
  final List<Category> _categories = [];
  String? _selectedCategory;
  Priority? _selectedPriority;
  DateTime? _selectedDate;

  List<Todo> get todos => _todos;
  List<Todo> get completedTodos => _completedTodos;
  List<Category> get categories => _categories;
  String? get selectedCategory => _selectedCategory;
  Priority? get selectedPriority => _selectedPriority;
  DateTime? get selectedDate => _selectedDate;

  void addTodo(Todo todo) {
    _todos.add(todo);
    _sortTodos();
    notifyListeners();
  }

  void toggleTodoCompletion(Todo todo) {
    todo.isCompleted = !todo.isCompleted;

    if (todo.isCompleted) {
      _todos.remove(todo);
      _completedTodos.add(todo);
    } else {
      _completedTodos.remove(todo);
      _todos.add(todo);
    }

    _sortTodos();
    notifyListeners();
  }

  void deleteTodo(Todo todo) {
    if (todo.isCompleted) {
      _completedTodos.remove(todo);
    } else {
      _todos.remove(todo);
    }
    notifyListeners();
  }

  void updateTodo(
    Todo todo, {
    String? title,
    String? description,
    DateTime? dueDate,
    Priority? priority,
    String? category,
  }) {
    final index =
        todo.isCompleted ? _completedTodos.indexOf(todo) : _todos.indexOf(todo);

    if (index != -1) {
      final updatedTodo = todo.copyWith(
        title: title,
        description: description,
        dueDate: dueDate,
        priority: priority,
        category: category,
      );

      if (todo.isCompleted) {
        _completedTodos[index] = updatedTodo;
      } else {
        _todos[index] = updatedTodo;
      }

      _sortTodos();
      notifyListeners();
    }
  }

  void addCategory(Category category) {
    _categories.add(category);
    notifyListeners();
  }

  void deleteCategory(Category category) {
    _categories.remove(category);
    notifyListeners();
  }

  void setSelectedCategory(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSelectedPriority(Priority? priority) {
    _selectedPriority = priority;
    notifyListeners();
  }

  void setSelectedDate(DateTime? date) {
    _selectedDate = date;
    notifyListeners();
  }

  List<Todo> getFilteredTodos() {
    return _todos.where((todo) {
      final categoryMatch =
          _selectedCategory == null || todo.category == _selectedCategory;
      final priorityMatch =
          _selectedPriority == null || todo.priority == _selectedPriority;
      final dateMatch =
          _selectedDate == null ||
          (todo.dueDate != null &&
              todo.dueDate!.year == _selectedDate!.year &&
              todo.dueDate!.month == _selectedDate!.month &&
              todo.dueDate!.day == _selectedDate!.day);

      return categoryMatch && priorityMatch && dateMatch;
    }).toList();
  }

  void _sortTodos() {
    _todos.sort((a, b) {
      // Sort by priority first
      final priorityComparison = b.priority.index.compareTo(a.priority.index);
      if (priorityComparison != 0) return priorityComparison;

      // Then by due date if available
      if (a.dueDate != null && b.dueDate != null) {
        final dateComparison = a.dueDate!.compareTo(b.dueDate!);
        if (dateComparison != 0) return dateComparison;
      } else if (a.dueDate != null) {
        return -1;
      } else if (b.dueDate != null) {
        return 1;
      }

      // Finally by creation date
      return b.createdAt.compareTo(a.createdAt);
    });

    _completedTodos.sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
