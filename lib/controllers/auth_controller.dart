// lib/controllers/auth_controller.dart

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final ApiService _api = ApiService();
  final AuthService _authService = AuthService();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _currentUser != null;

  // Initialisation : vérifier la session au démarrage
  Future<bool> checkSession() async {
    final userId = await _authService.getCurrentUserId();
    if (userId == null) return false;

    final user = await _api.getUserById(userId);
    if (user == null) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  // Inscription
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      // Vérifier si l'email existe déjà
      final existing = await _api.getUserByEmail(email);
      if (existing != null) {
        _setError('Cet email est déjà utilisé.');
        return false;
      }

      final user = UserModel(
        id: const Uuid().v4(),
        name: name,
        email: email,
        password: password,
        createdAt: DateTime.now(),
      );

      final created = await _api.addUser(user);

      await _authService.saveSession(
        userId: created.id,
        userName: created.name,
        userEmail: created.email,
      );

      _currentUser = created;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur lors de l\'inscription : $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Connexion
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final user = await _api.getUserByEmail(email);

      if (user == null) {
        _setError('Aucun compte avec cet email.');
        return false;
      }

      if (user.password != password) {
        _setError('Mot de passe incorrect.');
        return false;
      }

      await _authService.saveSession(
        userId: user.id,
        userName: user.name,
        userEmail: user.email,
      );

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Erreur de connexion : $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Déconnexion
  Future<void> logout() async {
    await _authService.clearSession();
    _currentUser = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String msg) {
    _errorMessage = msg;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
