import 'package:flutter/foundation.dart';
import '../models/user_profile_local.dart';
import '../services/profile_dao.dart';
import '../services/storage_service.dart';

class ProfileController extends ChangeNotifier {
  final StorageService storage;
  ProfileDao? _dao;
  UserProfileLocal? _profile;
  bool _loading = false;
  Object? _error;

  ProfileController({required this.storage});

  bool get loading => _loading;
  Object? get error => _error;
  UserProfileLocal? get profile => _profile;

  Future<void> _ensureDao() async {
    _dao ??= await ProfileDao.open();
  }

  Future<void> ensureForUser({required String uid, String? email}) async {
    _loading = true; _error = null; // notify at the end to avoid build-phase updates
    try {
      await _ensureDao();
      final dao = _dao!;
      var p = await dao.getByUid(uid);
      if (p == null) {
        final cached = await storage.loadUserData();
        final cachedEmail = cached?['email'];
        // Seed only if the cached email matches the currently signed-in user.
        final seedName = (cachedEmail != null && cachedEmail.isNotEmpty && cachedEmail == (email ?? ''))
            ? (cached?['name'] ?? '')
            : '';
        final seedAddress = (cachedEmail != null && cachedEmail.isNotEmpty && cachedEmail == (email ?? ''))
            ? (cached?['address'] ?? '')
            : '';
        p = UserProfileLocal(
          uid: uid,
          email: email,
          name: seedName,
          address: seedAddress,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
        );
        await dao.upsert(p);
      }
      _profile = p;
    } catch (e) {
      _error = e;
    } finally {
      _loading = false; notifyListeners();
    }
  }

  void setName(String v) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(name: v);
    notifyListeners();
  }

  void setAddress(String v) {
    if (_profile == null) return;
    _profile = _profile!.copyWith(address: v);
    notifyListeners();
  }

  Future<void> save() async {
    if (_profile == null) return;
    await _ensureDao();
    final now = DateTime.now().millisecondsSinceEpoch;
    _profile = _profile!.copyWith(updatedAtMillis: now);
    await _dao!.upsert(_profile!);
    // Also cache basic fields for quick subtitle on next launch
    await storage.saveUserData(
      email: _profile!.email ?? '',
      name: _profile!.name,
      address: _profile!.address,
    );
    notifyListeners();
  }
}
