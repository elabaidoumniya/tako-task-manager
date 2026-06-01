// lib/views/screens/kanban_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class KanbanScreen extends StatefulWidget {
  const KanbanScreen({super.key});

  @override
  State<KanbanScreen> createState() => _KanbanScreenState();
}

class _KanbanScreenState extends State<KanbanScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = context.read<AuthController>();
    final taskCtrl = context.read<TaskController>();
    if (auth.currentUser != null && taskCtrl.allTasks.isEmpty) {
      await taskCtrl.loadData(auth.currentUser!.id);
    }
  }

  static const _columns = [
    _ColumnConfig(
      status: TaskStatus.todo,
      label: 'À faire',
      color: Color(0xFF3B82F6),
      icon: Icons.radio_button_unchecked_rounded,
    ),
    _ColumnConfig(
      status: TaskStatus.inProgress,
      label: 'En cours',
      color: Color(0xFFF5A623),
      icon: Icons.pending_rounded,
    ),
    _ColumnConfig(
      status: TaskStatus.done,
      label: 'Terminé',
      color: Color(0xFF2DD98F),
      icon: Icons.check_circle_outline_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();

    return Scaffold(
      backgroundColor: const Color(0xFF080716),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF111027),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1E1C38), width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: Colors.white),
          ),
        ),
        title: const Text('Tableau Kanban',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () => context.push(AppRouter.taskForm),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
      body: taskCtrl.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7B6EF6)))
          : Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _columns.map((col) {
                  final tasks = taskCtrl.tasksByStatus(col.status);
                  return Expanded(
                    child: _KanbanColumn(
                      config: col,
                      tasks: tasks,
                      onDrop: (task) =>
                          taskCtrl.moveTaskToStatus(task, col.status),
                      onTap: (task) =>
                          context.push(AppRouter.taskDetail, extra: task),
                      onEdit: (task) =>
                          context.push(AppRouter.taskForm, extra: task),
                      onDelete: (task) => taskCtrl.deleteTask(task.id),
                    ),
                  );
                }).toList(),
              ),
            ),
    );
  }
}

// ── Colonne ────────────────────────────────────────────────────────────────

class _KanbanColumn extends StatefulWidget {
  final _ColumnConfig config;
  final List<Task> tasks;
  final ValueChanged<Task> onDrop;
  final ValueChanged<Task> onTap;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDelete;

  const _KanbanColumn({
    required this.config,
    required this.tasks,
    required this.onDrop,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<_KanbanColumn> createState() => _KanbanColumnState();
}

class _KanbanColumnState extends State<_KanbanColumn> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onWillAcceptWithDetails: (details) {
        setState(() => _isHovered = true);
        return details.data.status != widget.config.status;
      },
      onLeave: (_) => setState(() => _isHovered = false),
      onAcceptWithDetails: (details) {
        setState(() => _isHovered = false);
        widget.onDrop(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.config.color.withOpacity(0.08)
                : const Color(0xFF111027),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isHovered
                  ? widget.config.color.withOpacity(0.4)
                  : const Color(0xFF1E1C38),
              width: 1,
            ),
          ),
          child: Column(
            children: [
              _ColumnHeader(
                  config: widget.config, count: widget.tasks.length),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 80),
                  itemCount: widget.tasks.length,
                  itemBuilder: (_, i) => _DraggableTaskCard(
                    task: widget.tasks[i],
                    color: widget.config.color,
                    onTap: widget.onTap,
                    onEdit: widget.onEdit,
                    onDelete: widget.onDelete,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── En-tête colonne ────────────────────────────────────────────────────────

class _ColumnHeader extends StatelessWidget {
  final _ColumnConfig config;
  final int count;

  const _ColumnHeader({required this.config, required this.count});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.07),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
            bottom: BorderSide(color: config.color.withOpacity(0.12), width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration:
                BoxDecoration(color: config.color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              config.label,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 13,
                color: config.color,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
            decoration: BoxDecoration(
              color: config.color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('$count',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: config.color)),
          ),
        ],
      ),
    );
  }
}

// ── Carte draggable ────────────────────────────────────────────────────────

class _DraggableTaskCard extends StatelessWidget {
  final Task task;
  final Color color;
  final ValueChanged<Task> onTap;
  final ValueChanged<Task> onEdit;
  final ValueChanged<Task> onDelete;

  const _DraggableTaskCard({
    required this.task,
    required this.color,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Draggable<Task>(
      data: task,
      feedback: Material(
        color: Colors.transparent,
        child: SizedBox(
          width: MediaQuery.of(context).size.width / 3 - 24,
          child: _TaskCardBody(task: task, color: color, isDragging: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _TaskCardBody(task: task, color: color),
      ),
      child: GestureDetector(
        onTap: () => onTap(task),
        child: _TaskCardBody(
          task: task,
          color: color,
          onEdit: () => onEdit(task),
          onDelete: () => onDelete(task),
        ),
      ),
    );
  }
}

// ── Corps de la carte ──────────────────────────────────────────────────────

class _TaskCardBody extends StatelessWidget {
  final Task task;
  final Color color;
  final bool isDragging;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _TaskCardBody({
    required this.task,
    required this.color,
    this.isDragging = false,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final pColor = AppTheme.priorityColor(task.priority.index);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF161430),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: task.isOverdue
              ? const Color(0xFFFF4B4B).withOpacity(0.35)
              : const Color(0xFF1E1C38),
          width: 1,
        ),
        boxShadow: isDragging
            ? [
                BoxShadow(
                    color: color.withOpacity(0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 8))
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre + menu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 3,
                  height: 36,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: pColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: task.isDone
                          ? const Color(0xFF4A4768)
                          : Colors.white,
                      decoration:
                          task.isDone ? TextDecoration.lineThrough : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isDragging && (onEdit != null || onDelete != null))
                  SizedBox(
                    width: 22,
                    height: 22,
                    child: PopupMenuButton<String>(
                      padding: EdgeInsets.zero,
                      iconSize: 14,
                      icon: const Icon(Icons.more_horiz_rounded,
                          color: Color(0xFF4A4768), size: 14),
                      color: const Color(0xFF1A1835),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: const BorderSide(
                              color: Color(0xFF2A2750), width: 1)),
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'edit',
                          height: 36,
                          child: Row(children: [
                            Icon(Icons.edit_outlined,
                                size: 14, color: Color(0xFF9B8FF8)),
                            SizedBox(width: 8),
                            Text('Modifier',
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white)),
                          ]),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          height: 36,
                          child: Row(children: [
                            Icon(Icons.delete_outline_rounded,
                                size: 14, color: Color(0xFFFF4B4B)),
                            SizedBox(width: 8),
                            Text('Supprimer',
                                style: TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFFFF4B4B),
                                    fontWeight: FontWeight.w700)),
                          ]),
                        ),
                      ],
                      onSelected: (v) {
                        if (v == 'edit') onEdit?.call();
                        if (v == 'delete') onDelete?.call();
                      },
                    ),
                  ),
              ],
            ),

            if (task.description.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                task.description,
                style: const TextStyle(
                    color: Color(0xFF8A87A8),
                    fontSize: 11,
                    fontWeight: FontWeight.w500),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],

            const SizedBox(height: 10),

            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _Badge(
                  label: task.priorityLabel,
                  icon: Icons.flag_rounded,
                  color: pColor,
                  bg: pColor.withOpacity(0.12),
                ),
                if (task.dueDate != null)
                  _Badge(
                    label: _fmt(task.dueDate!),
                    icon: Icons.event_rounded,
                    color: task.isOverdue
                        ? const Color(0xFFFF4B4B)
                        : const Color(0xFF8A87A8),
                    bg: task.isOverdue
                        ? const Color(0xFFFF4B4B).withOpacity(0.12)
                        : const Color(0xFF1E1C38),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}';
}

// ── Badge ──────────────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;

  const _Badge(
      {required this.label,
      required this.icon,
      required this.color,
      required this.bg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: color),
          const SizedBox(width: 3),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

// ── Config colonne ─────────────────────────────────────────────────────────

class _ColumnConfig {
  final TaskStatus status;
  final String label;
  final Color color;
  final IconData icon;

  const _ColumnConfig({
    required this.status,
    required this.label,
    required this.color,
    required this.icon,
  });
}