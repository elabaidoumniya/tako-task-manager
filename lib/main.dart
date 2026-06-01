// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'controllers/auth_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/theme_controller.dart';  // ← AJOUTER
import 'routes/app_router.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => TaskController()),
        ChangeNotifierProvider(create: (_) => ThemeController()),  // ← AJOUTER
      ],
      child: const TakoApp(),
    ),
  );
}

class TakoApp extends StatelessWidget {
  const TakoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        return MaterialApp.router(
          title: 'Tako',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router(context),
        );
      },
    );
  }
}