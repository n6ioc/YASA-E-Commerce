abstract class FirebaseService {
  Future<void> logEvent(String name, [Map<String, Object?> params = const {}]);
  static FirebaseService noop() => _NoopFirebaseService();
  static Future<FirebaseService> createEnabled() async {
    // TODO: replace with real Firebase Analytics if needed.
    return _NoopFirebaseService();
  }
}
class _NoopFirebaseService implements FirebaseService {
  @override
  Future<void> logEvent(String name, [Map<String, Object?> params = const {}]) async {}
}