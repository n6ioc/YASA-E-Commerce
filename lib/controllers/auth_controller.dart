import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _auth;
  UserProfile? _user;
  late final StreamSubscription _sub;

  AuthController(this._auth) {
    _user = _auth.currentUser;
    _sub = _auth.authStateChanges().listen((u) { _user = u; notifyListeners(); });
  }

  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;

  Future<String?> signIn(String email, String password) async {
    try { await _auth.signIn(email: email, password: password); return null; }
    catch (e) { return e.toString(); }
  }

  Future<String?> signUp(String email, String password) async {
    try { await _auth.signUp(email: email, password: password); return null; }
    catch (e) { return e.toString(); }
  }

  Future<String?> signInAnonymously() async {
    try { await _auth.signInAnonymously(); return null; }
    catch (e) { return e.toString(); }
  }

  Future<String?> signInWithGoogle() async {
    try { await _auth.signInWithGoogle(); return null; }
    catch (e) { return e.toString(); }
  }

  Future<String?> resetPassword(String email) async {
    try { await _auth.sendPasswordResetEmail(email); return null; }
    catch (e) { return e.toString(); }
  }

  Future<void> signOut() => _auth.signOut();

  @override
  void dispose() { _sub.cancel(); super.dispose(); }
}