import 'package:flutter/material.dart';
class AppPreferences {
  final ThemeMode themeMode;
  final int seedColorIndex;
  const AppPreferences({required this.themeMode, required this.seedColorIndex});
  AppPreferences copyWith({ThemeMode? themeMode, int? seedColorIndex}) =>
      AppPreferences(themeMode: themeMode ?? this.themeMode, seedColorIndex: seedColorIndex ?? this.seedColorIndex);
  Map<String, dynamic> toJson() => {'themeMode': themeMode.index, 'seedColorIndex': seedColorIndex};
  factory AppPreferences.fromJson(Map<String, dynamic>? j) {
    if (j == null) return const AppPreferences(themeMode: ThemeMode.system, seedColorIndex: 0);
    final idx = (j['themeMode'] as int?) ?? 0;
    return AppPreferences(
      themeMode: ThemeMode.values[idx.clamp(0, ThemeMode.values.length - 1)],
      seedColorIndex: (j['seedColorIndex'] as int?) ?? 0,
    );
  }
}