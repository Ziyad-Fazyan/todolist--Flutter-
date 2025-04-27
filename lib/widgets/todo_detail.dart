import 'package:flutter/material.dart';
import '../models/todo_model.dart';
import '../providers/todo_provider.dart';
import 'package:provider/provider.dart';

class TodoDetailSheet extends StatefulWidget {
  final Todo? todo;
  final bool isEditing;

  const TodoDetailSheet({Key? key, this.todo, this.isEditing = false})
    : super(key: key);

  @override
  _TodoDetailSheetState createState() => _TodoDetailSheetState();
}

class _TodoDetailSheetState extends State<TodoDetailSheet> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  DateTime? _selectedDueDate;
  Priority _selectedPriority = Priority.medium;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.todo?.title ?? '');
    _descriptionController = TextEditingController(
      text: widget.todo?.description ?? '',
    );
    _selectedDueDate = widget.todo?.dueDate;
    _selectedPriority = widget.todo?.priority ?? Priority.medium;
    _selectedCategory = widget.todo?.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDueDate ?? DateTime.now()),
      );

      if (time != null) {
        setState(() {
          _selectedDueDate = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final todoProvider = Provider.of<TodoProvider>(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.isEditing ? 'Edit Tugas' : 'Tambah Tugas Baru',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Judul tugas...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
              prefixIcon: const Icon(Icons.assignment),
            ),
            autofocus: !widget.isEditing,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: InputDecoration(
              hintText: 'Deskripsi (opsional)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
              prefixIcon: const Icon(Icons.description),
            ),
            maxLines: 3,
            minLines: 1,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDate(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _selectedDueDate != null
                              ? 'Tenggat: ${_selectedDueDate!.day}/${_selectedDueDate!.month}/${_selectedDueDate!.year}'
                              : 'Tambah tenggat waktu',
                          style: TextStyle(
                            color:
                                _selectedDueDate != null
                                    ? colorScheme.onSurface
                                    : colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<Priority>(
                  value: _selectedPriority,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                    prefixIcon: const Icon(Icons.flag),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items:
                      Priority.values.map((priority) {
                        return DropdownMenuItem(
                          value: priority,
                          child: Text(
                            priority == Priority.low
                                ? 'Prioritas Rendah'
                                : priority == Priority.medium
                                ? 'Prioritas Sedang'
                                : 'Prioritas Tinggi',
                          ),
                        );
                      }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedPriority = value;
                      });
                    }
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String?>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: colorScheme.surfaceVariant.withOpacity(0.5),
                    prefixIcon: const Icon(Icons.category),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: null,
                      child: Text('Tanpa Kategori'),
                    ),
                    ...todoProvider.categories.map((category) {
                      return DropdownMenuItem(
                        value: category.id,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: category.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Batal'),
              ),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  if (_titleController.text.trim().isEmpty) return;

                  final todo = Todo(
                    id:
                        widget.todo?.id ??
                        DateTime.now().millisecondsSinceEpoch.toString(),
                    title: _titleController.text.trim(),
                    description: _descriptionController.text.trim(),
                    isCompleted: widget.todo?.isCompleted ?? false,
                    createdAt: widget.todo?.createdAt ?? DateTime.now(),
                    dueDate: _selectedDueDate,
                    priority: _selectedPriority,
                    category: _selectedCategory,
                  );

                  if (widget.isEditing) {
                    todoProvider.updateTodo(
                      widget.todo!,
                      title: todo.title,
                      description: todo.description,
                      dueDate: todo.dueDate,
                      priority: todo.priority,
                      category: todo.category,
                    );
                  } else {
                    todoProvider.addTodo(todo);
                  }

                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(widget.isEditing ? 'Simpan' : 'Tambah'),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
