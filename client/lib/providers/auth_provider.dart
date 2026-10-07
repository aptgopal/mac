import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  bool _isGuest = false;

  User? get user => _isGuest ? null : _authService.currentUser;
  User? get firebaseUser => _authService.currentUser;
  Stream<User?> get authStateChanges => _authService.authStateChanges;
  bool get isGuest => _isGuest;

  AuthProvider() {
    _loadGuestMode();
  }

  Future<void> _loadGuestMode() async {
    final prefs = await SharedPreferences.getInstance();
    _isGuest = prefs.getBool('guest_mode') ?? false;
    notifyListeners();
  }

  Future<void> register(String email, String password) async {
    await _authService.register(email: email, password: password);
    await _setGuestMode(false);
    _isGuest = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authService.login(email: email, password: password);
    await _setGuestMode(false);
    _isGuest = false;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _setGuestMode(false);
    _isGuest = false;
    await _authService.signOut();
    notifyListeners();
  }

  Future<void> signInAsGuest() async {
    await _authService.signInAnonymously();
    await _setGuestMode(true);
    _isGuest = true;
    notifyListeners();
  }

  Future<void> _setGuestMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    if (enabled) {
      await prefs.setBool('guest_mode', true);
    } else {
      await prefs.remove('guest_mode');
    }
  }
}
