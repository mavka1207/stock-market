import 'package:flutter/foundation.dart';

class AuthProvider extends ChangeNotifier {
  // later you will store:
  // - current user
  // - isLoggedIn
  // - signup/login/logout methods

  final bool _isLoggedIn = false;

  bool get isLoggedIn => _isLoggedIn;
}