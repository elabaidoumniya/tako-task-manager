// lib/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../models/task.dart';
import '../views/screens/home_screen.dart';
import '../views/screens/kanban_screen.dart';
import '../views/screens/login_screen.dart';
import '../views/screens/profile_screen.dart';
import '../views/screens/register_screen.dart';
import '../views/screens/stats_screen.dart';
import '../views/screens/task_detail_screen.dart';
import '../views/screens/task_form_screen.dart';
import '../views/screens/landing_screen.dart';
import '../views/screens/calendar_screen.dart';

class AppRouter {
  static const String landing = '/';
  static const String home = '/home';
  static const String kanban = '/kanban';
  static const String login = '/login';
  static const String register = '/register';
  static const String taskDetail = '/task-detail';
  static const String taskForm = '/task-form';
  static const String stats = '/stats';
  static const String profile = '/profile';
  static const String calendar = '/calendar';


  static GoRouter router(BuildContext context) {
    return GoRouter(
      initialLocation: landing,  // ← La landing page s'affiche en premier
      redirect: (ctx, state) async {
        final auth = ctx.read<AuthController>();
        final loggedIn = await auth.checkSession();
        
        // Chemins publics (accessibles sans authentification)
        final isPublicRoute = state.matchedLocation == landing ||
            state.matchedLocation == login ||
            state.matchedLocation == register;
        
        // Chemins protégés (nécessitent une authentification)
        final isProtectedRoute = state.matchedLocation == home ||
            state.matchedLocation == kanban ||
            state.matchedLocation == stats ||
            state.matchedLocation == profile ||
            state.matchedLocation == taskDetail ||
            state.matchedLocation == taskForm;
        
        // Si non connecté et essaie d'accéder à une route protégée → rediriger vers login
        if (!loggedIn && isProtectedRoute) {
          return login;
        }
        
        // Si connecté et essaie d'accéder à landing/login/register → rediriger vers home
        if (loggedIn && (state.matchedLocation == landing || 
                         state.matchedLocation == login || 
                         state.matchedLocation == register)) {
          return home;
        }
        
        // Sinon, rester sur la route demandée
        return null;
      },
      routes: [
        // Routes publiques
        GoRoute(path: landing, builder: (_, __) => const LandingScreen()),
        GoRoute(path: login, builder: (_, __) => const LoginScreen()),
        GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
        
        // Routes protégées (nécessitent authentification)
        GoRoute(path: home, builder: (_, __) => const HomeScreen()),
        GoRoute(path: kanban, builder: (_, __) => const KanbanScreen()),
        GoRoute(path: stats, builder: (_, __) => const StatsScreen()),
        GoRoute(path: profile, builder: (_, __) => const ProfileScreen()),
        GoRoute(path: calendar, builder: (_, __) => const CalendarScreen()),
        GoRoute(
          path: taskDetail,
          builder: (_, state) =>
              TaskDetailScreen(task: state.extra as Task),
        ),
        GoRoute(
          path: taskForm,
          builder: (_, state) =>
              TaskFormScreen(task: state.extra as Task?),
        ),
      ],
    );
  }
}