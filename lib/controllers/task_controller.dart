// lib/controllers/task_controller.dart
 
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/task.dart';
import '../models/category.dart';
import '../services/api_service.dart';
 
class TaskController extends ChangeNotifier {
  final ApiService _api = ApiService();
 
  List<Task> _tasks = [];
  List<Category> _categories = [];
  bool _isLoading = false;
 
  TaskStatus? _filterStatus;
  String? _filterCategoryId;
  Priority? _filterPriority;
 
  bool get isLoading => _isLoading;
  List<Category> get categories => _categories;
  List<Task> get allTasks => _tasks;
 
  // FIX : le filtre catégorie était cassé car la condition AND n'était pas
  // indépendante du filtre statut. On évalue chaque filtre séparément.
  List<Task> get filteredTasks {
    return _tasks.where((task) {
      // Filtre statut
      if (_filterStatus != null && task.status != _filterStatus) return false;
      // Filtre catégorie — FIX principal : on compare bien les IDs
      if (_filterCategoryId != null &&
          _filterCategoryId!.isNotEmpty &&
          task.categoryId != _filterCategoryId) return false;
      // Filtre priorité
      if (_filterPriority != null && task.priority != _filterPriority) return false;
      return true;
    }).toList();
  }
 
  // ─── Tâches par colonne Kanban ───────────────────────────────────────────
  List<Task> tasksByStatus(TaskStatus status) =>
      _tasks.where((t) => t.status == status).toList();
 
  // ─── Stats ───────────────────────────────────────────────────────────────
  int get totalTasks => _tasks.length;
  int get doneTasks => _tasks.where((t) => t.isDone).length;
  int get pendingTasks => _tasks.where((t) => !t.isDone).length;
  int get overdueTasks => _tasks.where((t) => t.isOverdue).length;
  double get completionRate =>
      _tasks.isEmpty ? 0 : doneTasks / _tasks.length;
 
  // ─── Chargement ──────────────────────────────────────────────────────────
  Future<void> loadData(String userId) async {
    _setLoading(true);
    try {
      _tasks = await _api.getTasks(userId);
      _categories = await _api.getCategories(userId);
      if (_categories.isEmpty) {
        for (final cat in Category.defaultCategories(userId)) {
          await _api.addCategory(cat);
        }
        _categories = await _api.getCategories(userId);
      }
    } catch (e) {
      debugPrint('Erreur loadData: $e');
    }
    _setLoading(false);
  }
 
  // ─── CRUD ─────────────────────────────────────────────────────────────────
  Future<void> addTask({
    required String title,
    required String description,
    required Priority priority,
    required String categoryId,
    required String userId,
    DateTime? dueDate,
  }) async {
    final task = Task(
      id: const Uuid().v4(),
      title: title,
      description: description,
      priority: priority,
      status: TaskStatus.todo,
      categoryId: categoryId,
      createdAt: DateTime.now(),
      dueDate: dueDate,
      userId: userId,
    );
    try {
      final created = await _api.addTask(task);
      _tasks.insert(0, created);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur addTask: $e');
    }
  }
 
  Future<void> updateTask(Task updated) async {
    try {
      final result = await _api.updateTask(updated);
      final index = _tasks.indexWhere((t) => t.id == updated.id);
      if (index != -1) {
        _tasks[index] = result;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Erreur updateTask: $e');
    }
  }
 
  Future<void> deleteTask(String id) async {
    try {
      await _api.deleteTask(id);
      _tasks.removeWhere((t) => t.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Erreur deleteTask: $e');
    }
  }
 
  Future<void> toggleTaskDone(Task task) async {
    final updated = task.copyWith(
      status: task.isDone ? TaskStatus.todo : TaskStatus.done,
    );
    await updateTask(updated);
  }
 
  Future<void> updateTaskStatus(Task task, TaskStatus newStatus) async {
    await updateTask(task.copyWith(status: newStatus));
  }
 
  // ─── Kanban drag-and-drop ────────────────────────────────────────────────
  /// Appelé quand l'utilisateur dépose une tâche dans une colonne.
  /// Met à jour le statut optimistement (UI) puis synchro API.
  Future<void> moveTaskToStatus(Task task, TaskStatus newStatus) async {
    if (task.status == newStatus) return;
    // Mise à jour locale immédiate pour fluidité UI
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) return;
    _tasks[index] = task.copyWith(status: newStatus);
    notifyListeners();
    // Synchro serveur
    try {
      await _api.updateTask(_tasks[index]);
    } catch (e) {
      // Rollback si erreur
      _tasks[index] = task;
      notifyListeners();
      debugPrint('Erreur moveTaskToStatus: $e');
    }
  }
 
  // ─── Catégories ──────────────────────────────────────────────────────────
  Future<void> addCategory(Category category) async {
    await _api.addCategory(category);
    _categories.add(category);
    notifyListeners();
  }
 
  Category? getCategoryById(String id) {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
 
  // ─── Filtres ─────────────────────────────────────────────────────────────
  void setFilterStatus(TaskStatus? status) {
    _filterStatus = status;
    notifyListeners();
  }
 
  void setFilterCategory(String? id) {
    _filterCategoryId = id;
    notifyListeners();
  }
 
  void setFilterPriority(Priority? p) {
    _filterPriority = p;
    notifyListeners();
  }
 
  void clearFilters() {
    _filterStatus = null;
    _filterCategoryId = null;
    _filterPriority = null;
    notifyListeners();
  }
 
  TaskStatus? get filterStatus => _filterStatus;
  String? get filterCategoryId => _filterCategoryId;
  Priority? get filterPriority => _filterPriority;
 
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
 