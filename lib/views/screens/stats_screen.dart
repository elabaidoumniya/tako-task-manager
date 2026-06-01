// lib/views/screens/stats_screen.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Statistiques',
            style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
      ),
      body: taskCtrl.totalTasks == 0
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: AppTheme.bg2,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.bar_chart_rounded,
                        size: 40, color: AppTheme.text3),
                  ),
                  const SizedBox(height: 20),
                  Text('Pas encore de données disponibles',
                      style: TextStyle(
                          color: AppTheme.text3,
                          fontSize: 16,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProgressCircleCard(
                      done: taskCtrl.doneTasks, total: taskCtrl.totalTasks),
                  const SizedBox(height: 20),
                  
                  const _SectionTitle(title: 'Tendance des 7 derniers jours'),
                  const SizedBox(height: 10),
                  _WeeklyBarChart(tasks: taskCtrl.allTasks),
                  const SizedBox(height: 20),
                  
                  const _SectionTitle(title: 'Répartition par statut'),
                  const SizedBox(height: 10),
                  _StatusPieChart(tasks: taskCtrl.allTasks),
                  const SizedBox(height: 20),
                  
                  const _SectionTitle(title: 'Tâches par priorité'),
                  const SizedBox(height: 10),
                  _PriorityBarChart(tasks: taskCtrl.allTasks),
                  const SizedBox(height: 20),
                  
                  const _SectionTitle(title: 'Résumé en chiffres'),
                  const SizedBox(height: 8),
                  _SummaryGrid(taskCtrl: taskCtrl),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: -0.3, color: AppTheme.text));
  }
}

class _ProgressCircleCard extends StatelessWidget {
  final int done;
  final int total;
  const _ProgressCircleCard({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : done / total;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 6,
                  backgroundColor: AppTheme.bg2,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(percent * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.text),
                    ),
                    const Text('complété',
                        style: TextStyle(fontSize: 9, color: AppTheme.text3)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Progression globale',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.text2)),
                const SizedBox(height: 6),
                Text('$done tâches terminées sur $total',
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.text)),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: percent,
                  minHeight: 6,
                  backgroundColor: AppTheme.bg2,
                  valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyBarChart extends StatelessWidget {
  final List<Task> tasks;
  const _WeeklyBarChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final List<DateTime> last7Days = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day - (6 - i));
    });
    
    final counts = last7Days.map((date) {
      return tasks.where((task) =>
        task.createdAt.year == date.year &&
        task.createdAt.month == date.month &&
        task.createdAt.day == date.day
      ).length;
    }).toList();
    
    final maxCount = counts.isEmpty ? 5 : counts.reduce((a, b) => a > b ? a : b);
    final maxY = (maxCount == 0 ? 5 : maxCount + 1).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final index = value.toInt();
                    if (index < 0 || index >= 7) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '${last7Days[index].day}',
                        style: const TextStyle(fontSize: 11, color: AppTheme.text3),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10, color: AppTheme.text3),
                  ),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppTheme.border,
                strokeWidth: 0.5,
              ),
            ),
            barGroups: List.generate(7, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: counts[i].toDouble(),
                    color: AppTheme.primary,
                    width: 20,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _StatusPieChart extends StatelessWidget {
  final List<Task> tasks;
  const _StatusPieChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final counts = [
      tasks.where((t) => t.status == TaskStatus.todo).length,
      tasks.where((t) => t.status == TaskStatus.inProgress).length,
      tasks.where((t) => t.status == TaskStatus.done).length,
    ];
    final colors = [
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981)
    ];
    final labels = ['À faire', 'En cours', 'Terminé'];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 140,
              child: PieChart(
                PieChartData(
                  sections: List.generate(3, (i) {
                    return PieChartSectionData(
                      value: counts[i].toDouble(),
                      color: colors[i],
                      title: counts[i] > 0 ? '${counts[i]}' : '',
                      radius: 45,
                      titleStyle: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    );
                  }).where((s) => s.value > 0).toList(),
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: List.generate(3, (i) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                            color: colors[i], shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    Text(
                      '${labels[i]} (${counts[i]})',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.text2),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _PriorityBarChart extends StatelessWidget {
  final List<Task> tasks;
  const _PriorityBarChart({required this.tasks});

  @override
  Widget build(BuildContext context) {
    final counts = [
      tasks.where((t) => t.priority == Priority.low).length,
      tasks.where((t) => t.priority == Priority.medium).length,
      tasks.where((t) => t.priority == Priority.high).length,
    ];
    final colors = [
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFFEF4444)
    ];
    final labels = ['Faible', 'Moyenne', 'Haute'];
    final int maxCount = counts.reduce((a, b) => a > b ? a : b);
    final double maxY = (maxCount == 0 ? 5 : maxCount + 2).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.border),
      ),
      child: SizedBox(
        height: 180,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: maxY,
            barTouchData: BarTouchData(enabled: true),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) => Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      labels[value.toInt()],
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.text2),
                    ),
                  ),
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 2,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.text3),
                  ),
                ),
              ),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: AppTheme.border,
                strokeWidth: 0.5,
              ),
            ),
            barGroups: List.generate(3, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: counts[i].toDouble(),
                    color: colors[i],
                    width: 40,
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── GRILLE RÉSUMÉ EN CHIFFRES (CARTES COMPACTES) ───────────────────────────────

class _SummaryGrid extends StatelessWidget {
  final TaskController taskCtrl;
  const _SummaryGrid({required this.taskCtrl});

  @override
  Widget build(BuildContext context) {
    final items = [
      ('Total', taskCtrl.totalTasks, Icons.list_alt_rounded, AppTheme.primary),
      ('Terminées', taskCtrl.doneTasks, Icons.check_circle_outline_rounded, const Color(0xFF10B981)),
      ('En attente', taskCtrl.pendingTasks, Icons.pending_outlined, const Color(0xFFF59E0B)),
      ('En retard', taskCtrl.overdueTasks, Icons.warning_amber_rounded, const Color(0xFFEF4444)),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: items.map((item) {
          final (label, count, icon, color) = item;
          return Container(
            width: 90,  // Largeur fixe pour chaque carte
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            decoration: BoxDecoration(
              color: AppTheme.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(height: 4),
                Text('$count',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: color)),
                const SizedBox(height: 2),
                Text(label,
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.text3)),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}