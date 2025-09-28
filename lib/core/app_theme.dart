import 'package:flutter/material.dart';

class BuiltTheme {
  final ThemeData light;
  final ThemeData dark;
  const BuiltTheme(this.light, this.dark);
}

BuiltTheme buildAppTheme({required int seedIndex, required bool darkMode}) {
  final seeds = <Color>[
    Colors.indigo,
    Colors.teal,
    Colors.deepOrange,
    Colors.pink,
    Colors.green,
    Colors.blueGrey,
  ];
  final seed = seeds[seedIndex % seeds.length];
  ThemeData base(Brightness b) {
    final scheme = ColorScheme.fromSeed(seedColor: seed, brightness: b);
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      cardTheme: const CardThemeData(
        elevation: 1.5,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(b == Brightness.dark ? 0.25 : 0.6),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide(color: scheme.primary, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: scheme.onSurface,
        indicator: BoxDecoration(
          color: scheme.primary.withOpacity(0.18),
          borderRadius: BorderRadius.circular(16),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 12),
      ),
      textTheme: const TextTheme(
        bodyMedium: TextStyle(height: 1.2),
        titleMedium: TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
  return BuiltTheme(base(Brightness.light), base(Brightness.dark));
}