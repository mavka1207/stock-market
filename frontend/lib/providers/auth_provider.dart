import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../db/local_db.dart';

class AuthProvider extends ChangeNotifier {
  Map<String, dynamic>? _currentUser;

  Map<String, dynamic>? get currentUser => _currentUser;

  int? get currentUserId => _currentUser?['id'] as int?;

  bool get isLoggedIn => _currentUser != null;

  // hashing password
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // SIGNUP
  Future<String?> signup({
    required String email,
    required String password,
  }) async {
    try {
      final existing = await LocalDB.getUserByEmail(email);
      if (existing != null) {
        return 'User with this email already exists';
      }

      final userId = await LocalDB.createUser(
        email: email,
        passwordHash: _hashPassword(password),
      );

      _currentUser = await LocalDB.getUserById(userId);
      notifyListeners();
      return null;

    } catch (e) {
      return 'Signup failed: $e';
    }
  }

  // LOGIN
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      final user = await LocalDB.getUserByEmail(email);
      if (user == null) {
        return 'User not found';
      }

      if (user['password_hash'] != _hashPassword(password)) {
        return 'Wrong password';
      }

      _currentUser = user;
      notifyListeners();
      return null;

    } catch (e) {
      return 'Login failed: $e';
    }
  }

  // LOGOUT
  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // update balance after buy/sell
  void updateBalance(double newBalance) {
    if (_currentUser != null) {
      _currentUser = Map<String, dynamic>.from(_currentUser!);
      _currentUser!['balance'] = newBalance;
      notifyListeners();
    }
  }
}