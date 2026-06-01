// lib/views/screens/task_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  const TaskDetailScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();
    final currentTask = taskCtrl.allTasks
            .cast<Task?>()
            .firstWhere((t) => t?.id == task.id, orElse: () => null) ??
        task;
    final category = taskCtrl.getCategoryById(currentTask.categoryId);

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
        title: const Text('Détails',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: Colors.white)),
        actions: [
          GestureDetector(
            onTap: () =>
                context.push(AppRouter.taskForm, extra: currentTask),
            child: Container(
              margin: const EdgeInsets.only(right: 16),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B6EF6).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: const Color(0xFF7B6EF6).withOpacity(0.3),
                    width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.edit_outlined,
                      size: 14, color: Color(0xFF9B8FF8)),
                  SizedBox(width: 6),
                  Text('Modifier',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF9B8FF8))),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Carte principale ─────────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF111027),
                borderRadius: BorderRadius.circular(24),
                border:
                    Border.all(color: const Color(0xFF1E1C38), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre + Badge statut
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          currentTask.title,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.3,
                            color: currentTask.isDone
                                ? const Color(0xFF4A4768)
                                : Colors.white,
                            decoration: currentTask.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      _StatusBadge(status: currentTask.status),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Description
                  if (currentTask.description.isNotEmpty) ...[
                    Text(
                      currentTask.description,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        color: Color(0xFF8A87A8),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Divider(
                        color: Colors.white.withOpacity(0.06), height: 1),
                    const SizedBox(height: 16),
                  ],

                  // Infos
                  _InfoRow(
                    icon: Icons.flag_rounded,
                    label: 'Priorité',
                    value: currentTask.priorityLabel,
                    valueColor: AppTheme.priorityColor(
                        currentTask.priority.index),
                  ),
                  if (category != null)
                    _InfoRow(
                      icon: Icons.label_outline_rounded,
                      label: 'Catégorie',
                      value: category.name,
                      valueColor: Color(category.colorValue),
                    ),
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'Création',
                    value: DateFormat('dd/MM/yyyy à HH:mm')
                        .format(currentTask.createdAt),
                  ),
                  if (currentTask.dueDate != null)
                    _InfoRow(
                      icon: Icons.event_outlined,
                      label: 'Échéance',
                      value: DateFormat('dd/MM/yyyy')
                          .format(currentTask.dueDate!),
                      valueColor: currentTask.isOverdue
                          ? const Color(0xFFFF4B4B)
                          : null,
                    ),

                  // Alerte retard
                  if (currentTask.isOverdue) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color:
                            const Color(0xFFFF4B4B).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: const Color(0xFFFF4B4B).withOpacity(0.3),
                            width: 1),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFFF4B4B), size: 16),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Cette tâche est en retard !',
                              style: TextStyle(
                                  color: Color(0xFFFF4B4B),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Changer le statut ────────────────────────────────────────
            const Text(
              'Mettre à jour le statut',
              style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: Colors.white),
            ),
            const SizedBox(height: 12),
            Row(
              children: TaskStatus.values.map((s) {
                final labels = ['À faire', 'En cours', 'Terminé'];
                final icons = [
                  Icons.radio_button_unchecked_rounded,
                  Icons.pending_outlined,
                  Icons.check_circle_outline_rounded,
                ];
                final isSelected = currentTask.status == s;
                final statusColor = s == TaskStatus.todo
                    ? const Color(0xFF3B82F6)
                    : s == TaskStatus.inProgress
                        ? const Color(0xFFF5A623)
                        : const Color(0xFF2DD98F);
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () =>
                          taskCtrl.updateTaskStatus(currentTask, s),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding:
                            const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? statusColor.withOpacity(0.1)
                              : const Color(0xFF111027),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? statusColor
                                : const Color(0xFF1E1C38),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(icons[s.index],
                                size: 20,
                                color: isSelected
                                    ? statusColor
                                    : const Color(0xFF4A4768)),
                            const SizedBox(height: 5),
                            Text(
                              labels[s.index],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: isSelected
                                    ? statusColor
                                    : const Color(0xFF4A4768),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF4A4768)),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(
                  color: Color(0xFF8A87A8),
                  fontSize: 14,
                  fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: valueColor ?? Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final config = {
      TaskStatus.todo: ('À faire', const Color(0xFF3B82F6)),
      TaskStatus.inProgress: ('En cours', const Color(0xFFF5A623)),
      TaskStatus.done: ('Terminé', const Color(0xFF2DD98F)),
    };
    final (label, color) = config[status]!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2), width: 1),
      ),
      child: Text(label,
          style: TextStyle(
              color: color,
              fontWeight: FontWeight.w800,
              fontSize: 11)),
    );
  }
}