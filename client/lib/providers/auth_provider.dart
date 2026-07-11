import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? get user => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;

  Future<void> register(String email, String password) =>
      _authService.register(email: email, password: password);

  Future<void> login(String email, String password) =>
      _authService.login(email: email, password: password);

  Future<void> signOut() => _authService.signOut();
}
