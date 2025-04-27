import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'providers/todo_provider.dart';
import 'widgets/todo_detail.dart';
import 'widgets/todo_statistics.dart';
import 'models/todo_model.dart';
import 'dart:ui';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TodoProvider(),
      child: MaterialApp(
        title: 'Todo List App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.light,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.deepPurple,
            brightness: Brightness.dark,
          ),
          cardTheme: CardTheme(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late final AnimationController _fadeController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fadeController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: IndexedStack(
          key: ValueKey<int>(_selectedIndex),
          index: _selectedIndex,
          children: [
            _buildTodoList(context, todoProvider),
            const TodoStatistics(),
          ],
        ),
      ),
      // Perbaikan FloatingActionButton
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton.extended(
                heroTag: 'addTodo',
                elevation: 4,
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                onPressed: () {
                  HapticFeedback.mediumImpact();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder:
                        (context) => BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).scaffoldBackgroundColor,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),
                            padding: EdgeInsets.only(
                              bottom: MediaQuery.of(context).viewInsets.bottom,
                            ),
                            child: const TodoDetailSheet(),
                          ),
                        ),
                  );
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Tugas'),
              )
              : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          HapticFeedback.selectionClick();
          setState(() {
            _selectedIndex = index;
          });
        },
        elevation: 8,
        backgroundColor:
            isDark ? colorScheme.surface.withOpacity(0.9) : colorScheme.surface,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.check_circle_outline),
            selectedIcon: Icon(Icons.check_circle, color: colorScheme.primary),
            label: 'Tugas',
          ),
          NavigationDestination(
            icon: const Icon(Icons.analytics_outlined),
            selectedIcon: Icon(Icons.analytics, color: colorScheme.primary),
            label: 'Statistik',
          ),
        ],
      ),
    );
  }

  Widget _buildTodoList(BuildContext context, TodoProvider todoProvider) {
    final colorScheme = Theme.of(context).colorScheme;
    final filteredTodos = _getFilteredTodos(todoProvider);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar.large(
          title: const Text('Todo List'),
          floating: true,
          stretch: true,
          expandedHeight: 120,
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: 'Cari Tugas',
              onPressed: () {
                HapticFeedback.selectionClick();
                showSearch(
                  context: context,
                  delegate: TodoSearchDelegate(todoProvider),
                );
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.filter_list),
              tooltip: 'Filter Tugas',
              onSelected: (value) {
                HapticFeedback.selectionClick();
                setState(() {
                  _currentFilter = value;
                });
              },
              itemBuilder:
                  (context) => [
                    CheckedPopupMenuItem(
                      value: 'all',
                      checked: _currentFilter == 'all',
                      child: const Text('Semua Tugas'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'completed',
                      checked: _currentFilter == 'completed',
                      child: const Text('Tugas Selesai'),
                    ),
                    CheckedPopupMenuItem(
                      value: 'active',
                      checked: _currentFilter == 'active',
                      child: const Text('Tugas Aktif'),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'priority',
                      child: Row(
                        children: [
                          Icon(Icons.flag),
                          SizedBox(width: 8),
                          Text('Urutkan berdasarkan Prioritas'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'category',
                      child: Row(
                        children: [
                          Icon(Icons.category),
                          SizedBox(width: 8),
                          Text('Urutkan berdasarkan Kategori'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'date',
                      child: Row(
                        children: [
                          Icon(Icons.calendar_today),
                          SizedBox(width: 8),
                          Text('Urutkan berdasarkan Tanggal'),
                        ],
                      ),
                    ),
                  ],
            ),
          ],
        ),
        if (filteredTodos.isEmpty)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 80,
                    color: colorScheme.outline.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tidak ada tugas',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colorScheme.outline.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tekan tombol + untuk menambahkan tugas baru',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.outline.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final todo = filteredTodos[index];
                return _buildTodoItem(context, todo, todoProvider);
              }, childCount: filteredTodos.length),
            ),
          ),
      ],
    );
  }

  List<Todo> _getFilteredTodos(TodoProvider provider) {
    switch (_currentFilter) {
      case 'completed':
        return provider.todos.where((todo) => todo.isCompleted).toList();
      case 'active':
        return provider.todos.where((todo) => !todo.isCompleted).toList();
      case 'priority':
        final sortedList = List<Todo>.from(provider.todos);
        sortedList.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        return sortedList;
      case 'category':
        final sortedList = List<Todo>.from(provider.todos);
        sortedList.sort(
          (a, b) => (a.category ?? '').toLowerCase().compareTo(
            (b.category ?? '').toLowerCase(),
          ),
        );
        return sortedList;
      case 'date':
        final sortedList = List<Todo>.from(provider.todos);
        sortedList.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        return sortedList;
      default:
        return provider.todos;
    }
  }

  Widget _buildTodoItem(
    BuildContext context,
    Todo todo,
    TodoProvider provider,
  ) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isOverdue =
        todo.dueDate != null &&
        !todo.isCompleted &&
        todo.dueDate!.isBefore(DateTime.now());

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Dismissible(
        key: Key(todo.id),
        background: Container(
          decoration: BoxDecoration(
            color: Colors.red.shade700,
            borderRadius: BorderRadius.circular(16),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          child: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          provider.deleteTodo(todo);
          HapticFeedback.mediumImpact();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Tugas dihapus'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              action: SnackBarAction(
                label: 'Batalkan',
                onPressed: () {
                  // Implement undo functionality
                  provider.addTodo(todo);
                },
              ),
            ),
          );
        },
        child: Hero(
          tag: 'todo-${todo.id}',
          child: Card(
            margin: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder:
                          (context) => BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(24),
                                ),
                              ),
                              padding: EdgeInsets.only(
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom,
                              ),
                              child: TodoDetailSheet(
                                todo: todo,
                                isEditing: true,
                              ),
                            ),
                          ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: _getPriorityColor(todo.priority, colorScheme),
                          width: 5,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Transform.scale(
                                scale: 1.2,
                                child: Checkbox(
                                  value: todo.isCompleted,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  onChanged: (value) {
                                    HapticFeedback.selectionClick();
                                    provider.toggleTodoCompletion(todo);
                                  },
                                  activeColor: colorScheme.primary,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  todo.title,
                                  style: textTheme.titleMedium?.copyWith(
                                    decoration:
                                        todo.isCompleted
                                            ? TextDecoration.lineThrough
                                            : null,
                                    color:
                                        todo.isCompleted
                                            ? colorScheme.outline
                                            : null,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (todo.description?.isNotEmpty ?? false)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(56, 4, 16, 0),
                            child: Text(
                              todo.description!,
                              style: textTheme.bodyMedium?.copyWith(
                                color:
                                    todo.isCompleted
                                        ? colorScheme.outline
                                        : colorScheme.onSurfaceVariant,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(56, 12, 16, 16),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              if (todo.category != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: (todo.categoryColor ??
                                            colorScheme.primaryContainer)
                                        .withOpacity(
                                          todo.isCompleted ? 0.3 : 0.15,
                                        ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.label,
                                        size: 14,
                                        color:
                                            todo.isCompleted
                                                ? (todo.categoryColor ??
                                                        colorScheme.primary)
                                                    .withOpacity(0.7)
                                                : todo.categoryColor ??
                                                    colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        todo.category!,
                                        style: textTheme.labelSmall?.copyWith(
                                          color:
                                              todo.isCompleted
                                                  ? (todo.categoryColor ??
                                                          colorScheme.primary)
                                                      .withOpacity(0.7)
                                                  : todo.categoryColor ??
                                                      colorScheme.primary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (todo.dueDate != null)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        isOverdue && !todo.isCompleted
                                            ? Colors.red.withOpacity(0.15)
                                            : colorScheme.surfaceVariant
                                                .withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.event,
                                        size: 14,
                                        color:
                                            isOverdue && !todo.isCompleted
                                                ? Colors.red
                                                : colorScheme.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _formatDate(todo.dueDate!),
                                        style: textTheme.labelSmall?.copyWith(
                                          color:
                                              isOverdue && !todo.isCompleted
                                                  ? Colors.red
                                                  : colorScheme
                                                      .onSurfaceVariant,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getPriorityColor(
                                    todo.priority,
                                    colorScheme,
                                  ).withOpacity(todo.isCompleted ? 0.1 : 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.flag,
                                      size: 14,
                                      color:
                                          todo.isCompleted
                                              ? _getPriorityColor(
                                                todo.priority,
                                                colorScheme,
                                              ).withOpacity(0.7)
                                              : _getPriorityColor(
                                                todo.priority,
                                                colorScheme,
                                              ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      _getPriorityText(todo.priority),
                                      style: textTheme.labelSmall?.copyWith(
                                        color:
                                            todo.isCompleted
                                                ? _getPriorityColor(
                                                  todo.priority,
                                                  colorScheme,
                                                ).withOpacity(0.7)
                                                : _getPriorityColor(
                                                  todo.priority,
                                                  colorScheme,
                                                ),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(Priority priority, ColorScheme colorScheme) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade700;
      case Priority.medium:
        return Colors.orange.shade600;
      case Priority.low:
        return Colors.green.shade600;
    }
  }

  String _getPriorityText(Priority priority) {
    switch (priority) {
      case Priority.high:
        return 'Tinggi';
      case Priority.medium:
        return 'Sedang';
      case Priority.low:
        return 'Rendah';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Hari ini';
    } else if (dateToCheck == tomorrow) {
      return 'Besok';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class TodoSearchDelegate extends SearchDelegate<String> {
  final TodoProvider todoProvider;

  TodoSearchDelegate(this.todoProvider);

  @override
  ThemeData appBarTheme(BuildContext context) {
    final theme = Theme.of(context);
    return theme.copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurface.withOpacity(0.6),
        ),
        border: InputBorder.none,
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        tooltip: 'Hapus pencarian',
        onPressed: () {
          query = '';
          showSuggestions(context);
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      tooltip: 'Kembali',
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      // Show recent searches or categories
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kategori Populer',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _getUniqueCategories().map((category) {
                    return ActionChip(
                      label: Text(category),
                      onPressed: () {
                        query = category;
                        showResults(context);
                      },
                    );
                  }).toList(),
            ),
          ],
        ),
      );
    }
    return _buildSearchResults(context);
  }

  List<String> _getUniqueCategories() {
    final categories =
        todoProvider.todos
            .where((todo) => todo.category != null && todo.category!.isNotEmpty)
            .map((todo) => todo.category!)
            .toSet()
            .toList();
    return categories.take(6).toList();
  }

  Widget _buildSearchResults(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final results =
        todoProvider.todos
            .where(
              (todo) =>
                  todo.title.toLowerCase().contains(query.toLowerCase()) ||
                  (todo.description?.toLowerCase().contains(
                        query.toLowerCase(),
                      ) ??
                      false) ||
                  (todo.category?.toLowerCase().contains(query.toLowerCase()) ??
                      false),
            )
            .toList();

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: colorScheme.outline.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak ada hasil untuk "$query"',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final todo = results[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(
              todo.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                decoration:
                    todo.isCompleted ? TextDecoration.lineThrough : null,
              ),
            ),
            subtitle:
                todo.description != null
                    ? Text(
                      todo.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                    : null,
            leading: CircleAvatar(
              backgroundColor:
                  todo.isCompleted
                      ? colorScheme.surfaceVariant
                      : _getPriorityColor(
                        todo.priority,
                        colorScheme,
                      ).withOpacity(0.2),
              child: Icon(
                todo.isCompleted ? Icons.check : Icons.description,
                color:
                    todo.isCompleted
                        ? colorScheme.primary
                        : _getPriorityColor(todo.priority, colorScheme),
              ),
            ),
            onTap: () {
              close(context, todo.id);
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder:
                    (context) => BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(24),
                          ),
                        ),
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                        ),
                        child: TodoDetailSheet(todo: todo, isEditing: true),
                      ),
                    ),
              );
            },
          ),
        );
      },
    );
  }

  Color _getPriorityColor(Priority priority, ColorScheme colorScheme) {
    switch (priority) {
      case Priority.high:
        return Colors.red.shade700;
      case Priority.medium:
        return Colors.orange.shade600;
      case Priority.low:
        return Colors.green.shade600;
    }
  }
}
