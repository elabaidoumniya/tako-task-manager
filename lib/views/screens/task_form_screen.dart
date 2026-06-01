// lib/views/screens/task_form_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';
import '../../services/notification_service.dart';

class TaskFormScreen extends StatefulWidget {
  final Task? task;
  const TaskFormScreen({super.key, this.task});

  @override
  State<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends State<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  TaskStatus _selectedStatus = TaskStatus.todo;
  String _selectedCategoryId = '';
  DateTime? _selectedDueDate;
  bool _enableReminder = false;  // ← NOUVEAU

  bool get _isEditing => widget.task != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _titleController.text = widget.task!.title;
      _descController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedStatus = widget.task!.status;
      _selectedCategoryId = widget.task!.categoryId;
      _selectedDueDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: AppTheme.darkTheme,
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _selectedDueDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final taskCtrl = Provider.of<TaskController>(context, listen: false);
    final authCtrl = Provider.of<AuthController>(context, listen: false);
    final userId = authCtrl.currentUser!.id;

    if (_isEditing) {
      final updated = widget.task!.copyWith(
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _selectedPriority,
        status: _selectedStatus,
        categoryId: _selectedCategoryId,
        dueDate: _selectedDueDate,
      );
      await taskCtrl.updateTask(updated);
      
      // Mise à jour du rappel
      if (_enableReminder && _selectedDueDate != null) {
        await NotificationService().scheduleTaskReminder(updated);
      } else if (!_enableReminder) {
        await NotificationService().cancelReminder(updated.id);
      }
    } else {
      final newId = DateTime.now().millisecondsSinceEpoch.toString();
      final newTask = Task(
        id: newId,
        title: _titleController.text.trim(),
        description: _descController.text.trim(),
        priority: _selectedPriority,
        status: TaskStatus.todo,
        categoryId: _selectedCategoryId,
        createdAt: DateTime.now(),
        dueDate: _selectedDueDate,
        userId: userId,
      );
      await taskCtrl.addTask(
        title: newTask.title,
        description: newTask.description,
        priority: newTask.priority,
        categoryId: newTask.categoryId,
        userId: userId,
        dueDate: newTask.dueDate,
      );
      
      // Programmer le rappel
      if (_enableReminder && _selectedDueDate != null) {
        await NotificationService().scheduleTaskReminder(newTask);
      }
    }

    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_isEditing ? 'Tâche mise à jour' : 'Tâche créée avec succès'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0B0A16) : const Color(0xFFF6F5FC),
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Modifier la tâche' : 'Nouvelle tâche',
          style: const TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Titre & Description
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131224) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Titre de la tâche *',
                        prefixIcon: Icon(Icons.title_rounded),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Le titre est obligatoire';
                        }
                        if (v.trim().length < 3) return 'Minimum 3 caractères';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descController,
                      maxLines: 3,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Description (optionnel)',
                        prefixIcon: Icon(Icons.notes_rounded),
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Priorité
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131224) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Priorité de la tâche',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 12),
                    Row(
                      children: Priority.values.map((p) {
                        final colors = [
                          const Color(0xFF10B981),
                          const Color(0xFFF59E0B),
                          const Color(0xFFEF4444),
                        ];
                        final labels = ['Faible', 'Moyenne', 'Haute'];
                        final isSelected = _selectedPriority == p;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: GestureDetector(
                              onTap: () => setState(() => _selectedPriority = p),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? colors[p.index].withOpacity(0.12)
                                      : (isDark ? const Color(0xFF1E1C38) : Colors.grey.shade100),
                                  border: Border.all(
                                    color: isSelected ? colors[p.index] : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Column(
                                  children: [
                                    Icon(Icons.flag_rounded,
                                        color: isSelected ? colors[p.index] : Colors.grey.shade400,
                                        size: 20),
                                    const SizedBox(height: 4),
                                    Text(labels[p.index],
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: isSelected
                                              ? colors[p.index]
                                              : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                                        )),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Statut (édition seulement)
            if (_isEditing) ...[
              Card(
                elevation: 0,
                color: isDark ? const Color(0xFF131224) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Statut actuel',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TaskStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(prefixIcon: Icon(Icons.flag_rounded)),
                        dropdownColor: isDark ? const Color(0xFF1C1B33) : Colors.white,
                        items: TaskStatus.values.map((s) {
                          final labels = ['À faire', 'En cours', 'Terminé'];
                          return DropdownMenuItem(
                            value: s,
                            child: Text(labels[s.index], style: const TextStyle(fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (v) => setState(() => _selectedStatus = v!),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Catégorie
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131224) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Catégorie',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 12),
                    if (taskCtrl.categories.isEmpty)
                      const Text('Aucune catégorie disponible',
                          style: TextStyle(fontWeight: FontWeight.w500))
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: taskCtrl.categories.map((cat) {
                          final isSelected = _selectedCategoryId == cat.id;
                          final catColor = Color(cat.colorValue);
                          return FilterChip(
                            label: Text(cat.name),
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedCategoryId = isSelected ? '' : cat.id),
                            avatar: Icon(_categoryIcon(cat.icon), size: 16,
                                color: isSelected ? Colors.white : catColor),
                            backgroundColor: isDark ? const Color(0xFF1E1C38) : Colors.grey.shade100,
                            selectedColor: catColor,
                            checkmarkColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                              side: BorderSide(color: isSelected ? catColor : Colors.transparent, width: 1.5),
                            ),
                            labelStyle: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Date d'échéance
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131224) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Date d'échéance",
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                    const SizedBox(height: 12),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1C38) : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: isDark ? Colors.transparent : Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, color: Colors.grey, size: 20),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDueDate != null
                                  ? DateFormat('dd/MM/yyyy').format(_selectedDueDate!)
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: _selectedDueDate != null
                                    ? (isDark ? Colors.white : const Color(0xFF0F0E1A))
                                    : Colors.grey,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedDueDate != null)
                              GestureDetector(
                                onTap: () => setState(() => _selectedDueDate = null),
                                child: const Icon(Icons.close_rounded, size: 18, color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── OPTION RAPPEL (NOUVEAU) ──
            Card(
              elevation: 0,
              color: isDark ? const Color(0xFF131224) : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.notifications_outlined, color: Colors.grey),
                        const SizedBox(width: 12),
                        const Text('Me rappeler 1h avant',
                            style: TextStyle(fontWeight: FontWeight.w500)),
                      ],
                    ),
                    Switch(
                      value: _enableReminder,
                      onChanged: (val) => setState(() => _enableReminder = val),
                      activeColor: AppTheme.primary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 28),

            // Bouton Enregistrer
            Container(
              height: 56,
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text(
                  _isEditing ? 'Enregistrer les modifications' : 'Créer la tâche',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  IconData _categoryIcon(String icon) {
    switch (icon) {
      case 'work': return Icons.work_outline_rounded;
      case 'person': return Icons.person_outline_rounded;
      case 'school': return Icons.school_outlined;
      case 'favorite': return Icons.favorite_border_rounded;
      default: return Icons.label_outline_rounded;
    }
  }
}