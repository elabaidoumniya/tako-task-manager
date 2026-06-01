// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/task.dart';
import '../models/user.dart';
import '../models/category.dart';

class ApiService {
  // ============================================================
  // SIMULATION 2 : API LOCALE (json-server)
  // static const String _baseUrl = 'http://localhost:3000';
  // ============================================================
  // SIMULATION 3 : API EXTERNE (MockAPI.io)
  // Remplacez par votre URL MockAPI.io
  // ============================================================
  static const String _baseUrl = 'https://6a1e08cabcc4f20d5ca5488c.mockapi.io';

  // ── Headers ──────────────────────────────────────────────────────────────
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // ── TASKS ─────────────────────────────────────────────────────────────────

  Future<List<Task>> getTasks(String userId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/tasks?userId=$userId'))
        .timeout(const Duration(seconds: 10));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Task.fromMap(e)).toList();
  }

  Future<Task> addTask(Task task) async {
    final response = await http
        .post(Uri.parse('$_baseUrl/tasks'),
            headers: _jsonHeaders, body: jsonEncode(task.toMap()))
        .timeout(const Duration(seconds: 10));
    _check(response, expected: [200, 201]);
    return Task.fromMap(jsonDecode(response.body));
  }

  Future<Task> updateTask(Task task) async {
    final response = await http
        .put(Uri.parse('$_baseUrl/tasks/${task.id}'),
            headers: _jsonHeaders, body: jsonEncode(task.toMap()))
        .timeout(const Duration(seconds: 10));
    _check(response);
    return Task.fromMap(jsonDecode(response.body));
  }

  Future<void> deleteTask(String id) async {
    final response = await http
        .delete(Uri.parse('$_baseUrl/tasks/$id'))
        .timeout(const Duration(seconds: 10));
    _check(response, expected: [200, 204]);
  }

  // ── USERS ─────────────────────────────────────────────────────────────────

  Future<UserModel?> getUserByEmail(String email) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/users?email=$email'))
        .timeout(const Duration(seconds: 10));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) return null;
    return UserModel.fromMap(data.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/users?id=$id'))
        .timeout(const Duration(seconds: 10));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    if (data.isEmpty) return null;
    return UserModel.fromMap(data.first);
  }

  Future<UserModel> addUser(UserModel user) async {
    final response = await http
        .post(Uri.parse('$_baseUrl/users'),
            headers: _jsonHeaders, body: jsonEncode(user.toMap()))
        .timeout(const Duration(seconds: 10));
    _check(response, expected: [200, 201]);
    return UserModel.fromMap(jsonDecode(response.body));
  }

  // ── CATEGORIES ────────────────────────────────────────────────────────────

  Future<List<Category>> getCategories(String userId) async {
    final response = await http
        .get(Uri.parse('$_baseUrl/categories?userId=$userId'))
        .timeout(const Duration(seconds: 10));
    _check(response);
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((e) => Category.fromMap(e)).toList();
  }

  Future<Category> addCategory(Category category) async {
    final response = await http
        .post(Uri.parse('$_baseUrl/categories'),
            headers: _jsonHeaders, body: jsonEncode(category.toMap()))
        .timeout(const Duration(seconds: 10));
    _check(response, expected: [200, 201]);
    return Category.fromMap(jsonDecode(response.body));
  }

  // ── Helper ────────────────────────────────────────────────────────────────

  void _check(http.Response response, {List<int> expected = const [200]}) {
    if (!expected.contains(response.statusCode)) {
      throw Exception(
          'HTTP ${response.statusCode} : ${response.reasonPhrase}\n${response.body}');
    }
  }
}