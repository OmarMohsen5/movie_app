import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:movie_app/Services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

/// Holds authentication state for the whole app.
/// Screens listen to this instead of talking to Firebase directly.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus status = AuthStatus.unknown;
  User? user;
  String? errorMessage;
  bool isLoading = false;

  AuthProvider() {
    _authService.authStateChanges.listen((firebaseUser) {
      user = firebaseUser;
      status = firebaseUser == null
          ? AuthStatus.unauthenticated
          : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  String? get userId => user?.uid;

  Future<bool> register(String email, String password) async {
    return _run(() => _authService.register(email, password));
  }

  Future<bool> login(String email, String password) async {
    return _run(() => _authService.login(email, password));
  }

  Future<void> logout() async {
    await _authService.logout();
  }

  Future<bool> _run(Future<User?> Function() action) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();
    try {
      await action();
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      errorMessage = e.message;
      isLoading = false;
      notifyListeners();
      return false;
    } catch (_) {
      errorMessage = 'Something went wrong. Please try again.';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}