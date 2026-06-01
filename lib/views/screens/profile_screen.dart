// lib/views/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../controllers/auth_controller.dart';
import '../../controllers/task_controller.dart';
import '../../routes/app_router.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final taskCtrl = context.watch<TaskController>();
    final user = auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.bg2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border, width: 1),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                size: 14, color: AppTheme.text),
          ),
        ),
        title: const Text('Profil',
            style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 17,
                color: AppTheme.text)),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          children: [
            // ── Avatar card ─────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -40),
                    child: Column(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppTheme.bg, width: 4),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7B6EF6), Color(0xFFB06CF5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user?.name.isNotEmpty == true
                                  ? user!.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                  fontSize: 30,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          user?.name ?? 'Utilisateur',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.text,
                              letterSpacing: -0.3),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          user?.email ?? '',
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppTheme.text3,
                              fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  Transform.translate(
                    offset: const Offset(0, -20),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      child: Row(
                        children: [
                          _StatCard(
                              label: 'Total',
                              value: taskCtrl.totalTasks,
                              color: const Color(0xFF7B6EF6)),
                          const SizedBox(width: 10),
                          _StatCard(
                              label: 'Terminé',
                              value: taskCtrl.doneTasks,
                              color: const Color(0xFF2DD98F)),
                          const SizedBox(width: 10),
                          _StatCard(
                              label: 'Attente',
                              value: taskCtrl.pendingTasks,
                              color: const Color(0xFFF5A623)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Options ─────────────────────────────────────────────────
            Container(
              decoration: BoxDecoration(
                color: AppTheme.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTheme.border, width: 1),
              ),
              child: Column(
                children: [
                  _OptionTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Statistiques avancées',
                    onTap: () => context.push(AppRouter.stats),
                  ),
                  Divider(
                      height: 1,
                      color: AppTheme.border,
                      indent: 56),
                  _OptionTile(
                    icon: Icons.logout_rounded,
                    title: 'Se déconnecter',
                    color: const Color(0xFFFF4B4B),
                    onTap: () => _confirmLogout(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.card,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: AppTheme.border, width: 1)),
        title: const Text('Déconnexion',
            style: TextStyle(
                fontWeight: FontWeight.w800, color: AppTheme.text)),
        content: const Text(
            'Voulez-vous vraiment vous déconnecter ?',
            style: TextStyle(
                fontWeight: FontWeight.w500, color: AppTheme.text2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Annuler',
                  style: TextStyle(
                      color: AppTheme.text3,
                      fontWeight: FontWeight.w700))),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF4B4B),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10)),
            child: const Text('Se déconnecter',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await Provider.of<AuthController>(context, listen: false).logout();
      context.go(AppRouter.login);
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: color)),
            const SizedBox(height: 3),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color.withOpacity(0.7),
                    fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.title,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = color ?? AppTheme.text;
    final iconColor = color ?? AppTheme.primary;
    return ListTile(
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(title,
          style: TextStyle(
              color: activeColor,
              fontWeight: FontWeight.w700,
              fontSize: 14)),
      trailing: Icon(Icons.chevron_right_rounded,
          color: AppTheme.text3, size: 20),
      onTap: onTap,
    );
  }
}