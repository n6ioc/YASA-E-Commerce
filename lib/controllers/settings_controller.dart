import 'package:flutter/material.dart';
import '../models/app_preferences.dart';
import '../services/storage_service.dart';

class SettingsController extends ChangeNotifier {
  final StorageService storage;
  AppPreferences _prefs;
  SettingsController(this.storage, this._prefs);

  AppPreferences get prefs => _prefs;

  Future<void> setDark(bool value) async {
    _prefs = _prefs.copyWith(themeMode: value ? ThemeMode.dark : ThemeMode.light);
    await storage.savePreferences(_prefs);
    notifyListeners();
  }

  Future<void> setSeedIndex(int idx) async {
    _prefs = _prefs.copyWith(seedColorIndex: idx);
    await storage.savePreferences(_prefs);
    notifyListeners();
  }
}