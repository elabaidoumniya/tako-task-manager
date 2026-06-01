// lib/views/widgets/task_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';
import '../../models/category.dart';
import '../../theme/app_theme.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final Category? category;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TaskCard({
    super.key,
    required this.task,
    this.category,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final pColor = AppTheme.priorityColor(task.priority.index);
    final isDone = task.isDone;

    return Dismissible(
      key: Key(task.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async { onDelete(); return false; },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: AppTheme.red.withOpacity(0.15),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.red.withOpacity(0.3)),
        ),
        child: const Icon(Icons.delete_outline_rounded,
            color: AppTheme.red, size: 24),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppTheme.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDone
                  ? AppTheme.border
                  : pColor.withOpacity(0.25),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Barre priorité
                Container(
                  width: 3,
                  height: 52,
                  margin: const EdgeInsets.only(top: 2),
                  decoration: BoxDecoration(
                    color: isDone ? AppTheme.border : pColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 14),

                // Checkbox
                GestureDetector(
                  onTap: onToggle,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 24,
                    height: 24,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? AppTheme.green : Colors.transparent,
                      border: isDone
                          ? null
                          : Border.all(
                              color: AppTheme.text3, width: 2),
                    ),
                    child: isDone
                        ? const Icon(Icons.check_rounded,
                            size: 13, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 14),

                // Contenu
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: isDone ? AppTheme.text3 : AppTheme.text,
                          decoration: isDone
                              ? TextDecoration.lineThrough
                              : null,
                          decorationColor: AppTheme.text3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (task.description.isNotEmpty) ...[
                        const SizedBox(height: 3),
                        Text(task.description,
                            style: const TextStyle(
                                color: AppTheme.text3, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis),
                      ],
                      const SizedBox(height: 10),

                      // Badges
                      Wrap(
                        spacing: 6,
                        children: [
                          _Badge(
                            label: task.priorityLabel,
                            color: pColor,
                            bg: AppTheme.priorityBg(task.priority.index),
                          ),
                          if (category != null)
                            _Badge(
                              label: category!.name,
                              color: Color(category!.colorValue),
                              bg: Color(category!.colorValue)
                                  .withOpacity(0.12),
                            ),
                          if (task.dueDate != null)
                            _Badge(
                              label: DateFormat('dd/MM')
                                  .format(task.dueDate!),
                              color: task.isOverdue
                                  ? AppTheme.red
                                  : AppTheme.text3,
                              bg: task.isOverdue
                                  ? AppTheme.red.withOpacity(0.1)
                                  : AppTheme.bg2,
                              icon: Icons.event_rounded,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Menu
                PopupMenuButton(
                  color: AppTheme.bg3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: AppTheme.border)),
                  icon: const Icon(Icons.more_vert_rounded,
                      color: AppTheme.text3, size: 20),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: const [
                        Icon(Icons.edit_outlined,
                            size: 16, color: AppTheme.primaryLight),
                        SizedBox(width: 10),
                        Text('Modifier',
                            style: TextStyle(
                                color: AppTheme.text, fontSize: 14)),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(children: const [
                        Icon(Icons.delete_outline_rounded,
                            size: 16, color: AppTheme.red),
                        SizedBox(width: 10),
                        Text('Supprimer',
                            style: TextStyle(
                                color: AppTheme.red, fontSize: 14)),
                      ]),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'delete') onDelete();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData? icon;
  const _Badge(
      {required this.label,
      required this.color,
      required this.bg,
      this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 10, color: color),
            const SizedBox(width: 4),
          ],
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}
