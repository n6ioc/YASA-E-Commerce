import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart' as g;

class UserProfile {
  final String uid;
  final String? email;
  final bool isAnonymous;
  const UserProfile({required this.uid, this.email, required this.isAnonymous});
  static UserProfile fromFirebase(fb.User u) =>
      UserProfile(uid: u.uid, email: u.email, isAnonymous: u.isAnonymous);
}

abstract class AuthService {
  Stream<UserProfile?> authStateChanges();
  UserProfile? get currentUser;

  Future<UserProfile?> signIn({required String email, required String password});
  Future<UserProfile?> signUp({required String email, required String password});
  Future<UserProfile?> signInAnonymously();
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);
  Future<UserProfile?> signInWithGoogle();

  static Future<AuthService> create() => AuthServiceDummy.create();
}

// Real Firebase (enable when USE_FIREBASE = true and FlutterFire configured)
class AuthServiceFirebase implements AuthService {
  final fb.FirebaseAuth _auth;
  AuthServiceFirebase._(this._auth);
  static Future<AuthService> create() async => AuthServiceFirebase._(fb.FirebaseAuth.instance);

  @override
  Stream<UserProfile?> authStateChanges() =>
      _auth.authStateChanges().map((u) => u == null ? null : UserProfile.fromFirebase(u));

  @override
  UserProfile? get currentUser =>
      _auth.currentUser == null ? null : UserProfile.fromFirebase(_auth.currentUser!);

  @override
  Future<UserProfile?> signIn({required String email, required String password}) async {
    final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
    final u = cred.user;
    return u == null ? null : UserProfile.fromFirebase(u);
  }

  @override
  Future<UserProfile?> signUp({required String email, required String password}) async {
    final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
    final u = cred.user;
    return u == null ? null : UserProfile.fromFirebase(u);
  }

  @override
  Future<UserProfile?> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    final u = cred.user;
    return u == null ? null : UserProfile.fromFirebase(u);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) => _auth.sendPasswordResetEmail(email: email);

  @override
  Future<UserProfile?> signInWithGoogle() async {
    final gg = g.GoogleSignIn(scopes: ['email']);
    final acct = await gg.signIn();
    if (acct == null) return null;
    final auth = await acct.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      idToken: auth.idToken,
      accessToken: auth.accessToken,
    );
    final res = await _auth.signInWithCredential(credential);
    return res.user == null ? null : UserProfile.fromFirebase(res.user!);
  }
}

// Dummy (default so app runs without Firebase)
class AuthServiceDummy implements AuthService {
  UserProfile? _user;
  final _ctrl = StreamController<UserProfile?>.broadcast();
  AuthServiceDummy._();
  static Future<AuthService> create() async => AuthServiceDummy._();

  @override
  Stream<UserProfile?> authStateChanges() => _ctrl.stream;

  @override
  UserProfile? get currentUser => _user;

  @override
  Future<UserProfile?> signIn({required String email, required String password}) async {
    _user = UserProfile(uid: 'dummy-${email.hashCode}', email: email, isAnonymous: false);
    _ctrl.add(_user);
    return _user;
  }

  @override
  Future<UserProfile?> signUp({required String email, required String password}) =>
      signIn(email: email, password: password);

  @override
  Future<UserProfile?> signInAnonymously() async {
    _user = const UserProfile(uid: 'guest', email: null, isAnonymous: true);
    _ctrl.add(_user);
    return _user;
  }

  @override
  Future<void> signOut() async {
    _user = null;
    _ctrl.add(null);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<UserProfile?> signInWithGoogle() =>
      signIn(email: 'google.user@example.com', password: '');
}