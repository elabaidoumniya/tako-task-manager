// lib/views/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../theme/app_theme.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final taskCtrl = context.watch<TaskController>();

    final tasksForMonth = taskCtrl.allTasks.where((task) =>
      task.dueDate != null &&
      task.dueDate!.year == _focusedDay.year &&
      task.dueDate!.month == _focusedDay.month
    ).toList();

    final tasksForDay = _selectedDay != null
        ? taskCtrl.allTasks.where((task) =>
            task.dueDate != null &&
            task.dueDate!.year == _selectedDay!.year &&
            task.dueDate!.month == _selectedDay!.month &&
            task.dueDate!.day == _selectedDay!.day).toList()
        : [];

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Calendrier', style: TextStyle(fontWeight: FontWeight.w800)),
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _focusedDay = DateTime.now();
                _selectedDay = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // En-tête mois
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1);
                  }),
                ),
                Text(
                  DateFormat('MMMM yyyy', 'fr').format(_focusedDay),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() {
                    _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1);
                  }),
                ),
              ],
            ),
          ),
          
          // Jours de la semaine
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['L', 'M', 'M', 'J', 'V', 'S', 'D'].map((day) {
                return Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12, color: AppTheme.text3),
                  ),
                );
              }).toList(),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Grille calendrier
          Expanded(
            flex: 2,
            child: _buildCalendarGrid(tasksForMonth),
          ),
          
          // Liste des tâches du jour
          if (_selectedDay != null)
            Expanded(
              flex: 1,
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.card,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Tâches du ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                    ),
                    Expanded(
                      child: tasksForDay.isEmpty
                          ? Center(
                              child: Text('Aucune tâche', style: TextStyle(color: AppTheme.text2)),
                            )
                          : ListView.builder(
                              itemCount: tasksForDay.length,
                              itemBuilder: (ctx, i) {
                                final task = tasksForDay[i];
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.bg2,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 3,
                                        height: 20,
                                        decoration: BoxDecoration(
                                          color: AppTheme.priorityColor(task.priority.index),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(task.title,
                                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                                      ),
                                      if (task.isDone)
                                        const Icon(Icons.check_circle, color: AppTheme.green, size: 18),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(List<Task> tasksForMonth) {
    final firstDayOfMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = DateTime(_focusedDay.year, _focusedDay.month + 1, 0).day;
    
    List<DateTime?> days = [];
    for (int i = 0; i < firstWeekday; i++) days.add(null);
    for (int i = 1; i <= daysInMonth; i++) days.add(DateTime(_focusedDay.year, _focusedDay.month, i));
    
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: days.length,
      itemBuilder: (ctx, i) {
        final day = days[i];
        if (day == null) return const SizedBox();
        
        final hasTasks = tasksForMonth.any((t) => t.dueDate?.day == day.day);
        final isToday = day.year == DateTime.now().year &&
            day.month == DateTime.now().month &&
            day.day == DateTime.now().day;
        final isSelected = _selectedDay != null &&
            _selectedDay!.year == day.year &&
            _selectedDay!.month == day.month &&
            _selectedDay!.day == day.day;
        
        return GestureDetector(
          onTap: () => setState(() => _selectedDay = day),
          child: Container(
            margin: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primary.withOpacity(0.2) : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isToday ? AppTheme.primary : Colors.transparent,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      color: isToday ? Colors.white : AppTheme.text,
                      fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
                if (hasTasks && !isToday)
                  Positioned(
                    bottom: 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryLight,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}