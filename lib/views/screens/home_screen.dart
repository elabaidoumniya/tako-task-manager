// lib/views/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../models/task.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';
import '../widgets/task_card.dart';
import '../widgets/filter_chips.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final auth = Provider.of<AuthController>(context, listen: false);
    final ctrl = Provider.of<TaskController>(context, listen: false);
    if (auth.currentUser != null) await ctrl.loadData(auth.currentUser!.id);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final taskCtrl = context.watch<TaskController>();
    final name = auth.currentUser?.name.split(' ').first ?? '';

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: taskCtrl.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : NestedScrollView(
              headerSliverBuilder: (ctx, _) => [
                SliverAppBar(
                  expandedHeight: 220,
                  pinned: true,
                  backgroundColor: AppTheme.bg,
                  elevation: 0,
                  bottom: PreferredSize(
                    preferredSize: const Size.fromHeight(56),
                    child: Container(
                      color: AppTheme.bg,
                      child: TabBar(
                        controller: _tabCtrl,
                        tabs: const [
                          Tab(text: 'Liste'),
                          Tab(text: 'Kanban'),
                        ],
                        labelColor: AppTheme.primaryLight,
                        unselectedLabelColor: AppTheme.text3,
                        labelStyle: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                        indicator: UnderlineTabIndicator(
                          borderSide: const BorderSide(
                              color: AppTheme.primary, width: 2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      color: AppTheme.bg,
                      padding: const EdgeInsets.fromLTRB(24, 60, 24, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Bonjour, $name 👋',
                                        style: const TextStyle(
                                            fontSize: 26,
                                            fontWeight: FontWeight.w900,
                                            color: AppTheme.text,
                                            letterSpacing: -0.5)),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${taskCtrl.pendingTasks} tâche(s) en attente',
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: AppTheme.text2),
                                    ),
                                  ],
                                ),
                              ),
                              _IconBtn(
                                  icon: Icons.bar_chart_rounded,
                                  onTap: () =>
                                      context.push(AppRouter.stats)),
                              const SizedBox(width: 8),
                              _IconBtn(
                                  icon: Icons.person_outline_rounded,
                                  onTap: () =>
                                      context.push(AppRouter.profile)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Stats row
                          Row(children: [
                            _StatPill(
                                label: 'Total',
                                value: taskCtrl.totalTasks,
                                color: AppTheme.primary),
                            const SizedBox(width: 8),
                            _StatPill(
                                label: 'Terminées',
                                value: taskCtrl.doneTasks,
                                color: AppTheme.green),
                            const SizedBox(width: 8),
                            _StatPill(
                                label: 'En retard',
                                value: taskCtrl.overdueTasks,
                                color: AppTheme.red),
                          ]),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              body: TabBarView(
                controller: _tabCtrl,
                children: [
                  // ── LISTE VIEW ──
                  _ListView(taskCtrl: taskCtrl),
                  // ── KANBAN VIEW ──
                  _KanbanView(taskCtrl: taskCtrl),
                ],
              ),
            ),

      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
                color: AppTheme.primary.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRouter.taskForm),
          backgroundColor: Colors.transparent,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: const Text('Nouvelle tâche',
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }
}

// ── Liste view ────────────────────────────────────────────────────────────────

class _ListView extends StatelessWidget {
  final TaskController taskCtrl;
  const _ListView({required this.taskCtrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FilterChipsWidget(taskController: taskCtrl),
        Expanded(
          child: taskCtrl.filteredTasks.isEmpty
              ? _EmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  itemCount: taskCtrl.filteredTasks.length,
                  itemBuilder: (ctx, i) {
                    final task = taskCtrl.filteredTasks[i];
                    return TaskCard(
                      task: task,
                      category:
                          taskCtrl.getCategoryById(task.categoryId),
                      onTap: () => context.push(AppRouter.taskDetail,
                          extra: task),
                      onToggle: () => taskCtrl.toggleTaskDone(task),
                      onDelete: () => _confirmDelete(context, task),
                      onEdit: () =>
                          context.push(AppRouter.taskForm, extra: task),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _confirmDelete(BuildContext context, Task task) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Supprimer ?',
            style: TextStyle(
                color: AppTheme.text, fontWeight: FontWeight.w800)),
        content: Text('Supprimer "${task.title}" ?',
            style: const TextStyle(color: AppTheme.text2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler',
                  style: TextStyle(color: AppTheme.text2))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      Provider.of<TaskController>(context, listen: false)
          .deleteTask(task.id);
    }
  }
}

// ── Kanban view ────────────────────────────────────────────────────────────────

class _KanbanView extends StatelessWidget {
  final TaskController taskCtrl;
  const _KanbanView({required this.taskCtrl});

  static const cols = [
    (TaskStatus.todo, 'À faire', AppTheme.primary),
    (TaskStatus.inProgress, 'En cours', AppTheme.orange),
    (TaskStatus.done, 'Terminé', AppTheme.green),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: cols.map((col) {
          final (status, label, color) = col;
          final tasks =
              taskCtrl.allTasks.where((t) => t.status == status).toList();
          return _KanbanCol(
            label: label,
            color: color,
            tasks: tasks,
            status: status,
            taskCtrl: taskCtrl,
          );
        }).toList(),
      ),
    );
  }
}

class _KanbanCol extends StatelessWidget {
  final String label;
  final Color color;
  final List<Task> tasks;
  final TaskStatus status;
  final TaskController taskCtrl;

  const _KanbanCol({
    required this.label,
    required this.color,
    required this.tasks,
    required this.status,
    required this.taskCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<Task>(
      onAcceptWithDetails: (d) => taskCtrl.updateTaskStatus(d.data, status),
      builder: (ctx, candidates, _) {
        final hl = candidates.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 220,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: hl ? color.withOpacity(0.08) : AppTheme.bg2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: hl ? color.withOpacity(0.5) : AppTheme.border,
              width: hl ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(18)),
                  border: Border(
                      bottom: BorderSide(
                          color: color.withOpacity(0.15))),
                ),
                child: Row(children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text(label,
                      style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: color)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('${tasks.length}',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: color)),
                  ),
                ]),
              ),
              // Tasks
              if (tasks.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('Glissez une tâche ici',
                        style: TextStyle(
                            fontSize: 12, color: AppTheme.text3),
                        textAlign: TextAlign.center),
                  ),
                )
              else
                ...tasks.map((task) => Draggable<Task>(
                      data: task,
                      feedback: Material(
                        color: Colors.transparent,
                        child: _KanbanTile(task: task, color: color,
                            isDragging: true),
                      ),
                      childWhenDragging:
                          Opacity(opacity: 0.25,
                              child: _KanbanTile(
                                  task: task, color: color)),
                      child: _KanbanTile(task: task, color: color),
                    )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }
}

class _KanbanTile extends StatelessWidget {
  final Task task;
  final Color color;
  final bool isDragging;
  const _KanbanTile(
      {required this.task, required this.color, this.isDragging = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 6, 10, 0),
      padding: const EdgeInsets.all(12),
      width: isDragging ? 200 : null,
      decoration: BoxDecoration(
        color: AppTheme.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
        boxShadow: isDragging
            ? [BoxShadow(
                color: color.withOpacity(0.3), blurRadius: 16)]
            : null,
      ),
      child: Row(
        children: [
          Container(
              width: 3,
              height: 40,
              decoration: BoxDecoration(
                  color: AppTheme.priorityColor(task.priority.index),
                  borderRadius: BorderRadius.circular(2))),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task.title,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.text),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                        color: AppTheme.priorityColor(
                            task.priority.index),
                        shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 5),
                  Text(task.priorityLabel,
                      style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.priorityColor(
                              task.priority.index))),
                ]),
              ],
            ),
          ),
          Icon(Icons.drag_indicator_rounded,
              size: 16, color: AppTheme.text3),
        ],
      ),
    );
  }
}

// ── Helpers ────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.task_alt_rounded,
                size: 40, color: Colors.white),
          ),
          const SizedBox(height: 20),
          const Text('Aucune tâche',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.text)),
          const SizedBox(height: 8),
          const Text('Appuyez sur + pour commencer',
              style: TextStyle(
                  fontSize: 14, color: AppTheme.text2)),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.bg2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Icon(icon, color: AppTheme.text2, size: 20),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  const _StatPill(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                  color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$value $label',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w700, color: color)),
        ],
      ),
    );
  }
}