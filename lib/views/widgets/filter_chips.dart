// lib/views/widgets/filter_chips.dart

import 'package:flutter/material.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class FilterChipsWidget extends StatelessWidget {
  final TaskController taskController;
  const FilterChipsWidget({super.key, required this.taskController});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          _Chip(
            label: 'Tout',
            icon: Icons.apps_rounded,
            isSelected: taskController.filterStatus == null &&
                taskController.filterCategoryId == null,
            onTap: taskController.clearFilters,
            color: AppTheme.primary,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'À faire',
            icon: Icons.radio_button_unchecked_rounded,
            isSelected: taskController.filterStatus == TaskStatus.todo,
            onTap: () => taskController.setFilterStatus(
              taskController.filterStatus == TaskStatus.todo
                  ? null
                  : TaskStatus.todo,
            ),
            color: const Color(0xFF3B82F6),
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'En cours',
            icon: Icons.pending_rounded,
            isSelected:
                taskController.filterStatus == TaskStatus.inProgress,
            onTap: () => taskController.setFilterStatus(
              taskController.filterStatus == TaskStatus.inProgress
                  ? null
                  : TaskStatus.inProgress,
            ),
            color: AppTheme.orange,
          ),
          const SizedBox(width: 8),
          _Chip(
            label: 'Terminé',
            icon: Icons.check_circle_outline_rounded,
            isSelected: taskController.filterStatus == TaskStatus.done,
            onTap: () => taskController.setFilterStatus(
              taskController.filterStatus == TaskStatus.done
                  ? null
                  : TaskStatus.done,
            ),
            color: AppTheme.green,
          ),

          if (taskController.categories.isNotEmpty) ...[
            const SizedBox(width: 12),
            Container(
                width: 1, height: 18, color: AppTheme.border),
            const SizedBox(width: 12),

            // ← FIX: filtrer par catégorie correctement
            ...taskController.categories.map((cat) {
              final isSelected =
                  taskController.filterCategoryId == cat.id;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _Chip(
                  label: cat.name,
                  isSelected: isSelected,
                  onTap: () {
                    // Si déjà sélectionné → désélectionner
                    // Sinon → filtrer par cette catégorie ET effacer filtre status
                    if (isSelected) {
                      taskController.setFilterCategory(null);
                    } else {
                      taskController.setFilterStatus(null);
                      taskController.setFilterCategory(cat.id);
                    }
                  },
                  color: Color(cat.colorValue),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String label;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  const _Chip({
    required this.label,
    this.icon,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.bg2,
          borderRadius: BorderRadius.circular(50),
          border: Border.all(
            color: isSelected
                ? color.withOpacity(0.5)
                : AppTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon,
                  size: 13,
                  color: isSelected ? color : AppTheme.text3),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isSelected ? color : AppTheme.text3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
