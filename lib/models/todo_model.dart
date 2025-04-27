import 'package:flutter/material.dart';

enum Priority { low, medium, high }

class Todo {
  final String id;
  String title;
  String? description;
  bool isCompleted;
  final DateTime createdAt;
  DateTime? dueDate;
  Priority priority;
  String? category;
  Color? categoryColor;

  Todo({
    required this.id,
    required this.title,
    this.description,
    required this.isCompleted,
    required this.createdAt,
    this.dueDate,
    this.priority = Priority.medium,
    this.category,
    this.categoryColor,
  });

  Todo copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? dueDate,
    Priority? priority,
    String? category,
    Color? categoryColor,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      categoryColor: categoryColor ?? this.categoryColor,
    );
  }
}

class Category {
  final String id;
  String name;
  Color color;

  Category({required this.id, required this.name, required this.color});
}
