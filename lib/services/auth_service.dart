// lib/services/auth_service.dart

import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  static const String _keyUserId = 'userId';
  static const String _keyUserName = 'userName';
  static const String _keyUserEmail = 'userEmail';

  // Sauvegarder la session
  Future<void> saveSession({
    required String userId,
    required String userName,
    required String userEmail,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserName, userName);
    await prefs.setString(_keyUserEmail, userEmail);
  }

  // Récupérer l'ID de l'utilisateur connecté
  Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

  // Récupérer le nom
  Future<String?> getCurrentUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_keyUserId);
  }

  // Supprimer la session (logout)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
