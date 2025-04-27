import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'package:provider/provider.dart';

class TodoStatistics extends StatelessWidget {
  const TodoStatistics({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    final totalTasks =
        todoProvider.todos.length + todoProvider.completedTodos.length;
    final completedTasks = todoProvider.completedTodos.length;
    final activeTasks = todoProvider.todos.length;

    final completionRate =
        totalTasks > 0 ? (completedTasks / totalTasks * 100) : 0;

    // Group tasks by priority
    final tasksByPriority = {
      Priority.low: 0,
      Priority.medium: 0,
      Priority.high: 0,
    };

    for (final todo in [
      ...todoProvider.todos,
      ...todoProvider.completedTodos,
    ]) {
      tasksByPriority[todo.priority] =
          (tasksByPriority[todo.priority] ?? 0) + 1;
    }

    // Group tasks by category
    final tasksByCategory = <String, int>{};
    for (final todo in [
      ...todoProvider.todos,
      ...todoProvider.completedTodos,
    ]) {
      if (todo.category != null) {
        tasksByCategory[todo.category!] =
            (tasksByCategory[todo.category!] ?? 0) + 1;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Statistik Tugas',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overview Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          context,
                          'Total',
                          totalTasks.toString(),
                          Icons.assignment,
                          colorScheme.primary,
                        ),
                        _buildStatItem(
                          context,
                          'Aktif',
                          activeTasks.toString(),
                          Icons.pending_actions,
                          colorScheme.secondary,
                        ),
                        _buildStatItem(
                          context,
                          'Selesai',
                          completedTasks.toString(),
                          Icons.check_circle,
                          colorScheme.tertiary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: completionRate / 100,
                        minHeight: 8,
                        backgroundColor: colorScheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tingkat penyelesaian: ${completionRate.toStringAsFixed(1)}%',
                      style: TextStyle(
                        color: colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Priority Distribution
            const Text(
              'Distribusi Prioritas',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withOpacity(0.5),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildPriorityBar(
                      context,
                      'Tinggi',
                      tasksByPriority[Priority.high]!,
                      totalTasks,
                      Colors.red,
                    ),
                    const SizedBox(height: 12),
                    _buildPriorityBar(
                      context,
                      'Sedang',
                      tasksByPriority[Priority.medium]!,
                      totalTasks,
                      Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    _buildPriorityBar(
                      context,
                      'Rendah',
                      tasksByPriority[Priority.low]!,
                      totalTasks,
                      Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category Distribution
            if (tasksByCategory.isNotEmpty) ...[
              const Text(
                'Distribusi Kategori',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: colorScheme.outlineVariant.withOpacity(0.5),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children:
                        tasksByCategory.entries.map((entry) {
                          final category = todoProvider.categories.firstWhere(
                            (c) => c.id == entry.key,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildCategoryBar(
                              context,
                              category.name,
                              entry.value,
                              totalTasks,
                              category.color,
                            ),
                          );
                        }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.outline,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(
              '$count tugas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    final percentage = total > 0 ? (count / total * 100) : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(label),
              ],
            ),
            Text(
              '$count tugas',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}
