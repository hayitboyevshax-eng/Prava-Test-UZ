import 'package:flutter/material.dart';

class C {
  static const bg = Color(0xFF0B0C10);
  static const surface = Color(0xFF15171E);
  static const surface2 = Color(0xFF1E212B);
  static const line = Color(0xFF2A2E3A);
  static const gold = Color(0xFFFFD700);
  static const orange = Color(0xFFE67E22);
  static const text = Color(0xFFF2F2F2);
  static const muted = Color(0xFF9AA0AD);
  static const ok = Color(0xFF2ECC71);
  static const bad = Color(0xFFFF5A5F);
  static const okBg = Color(0x262ECC71);
  static const badBg = Color(0x26FF5A5F);
  static const goldBg = Color(0x1FFFD700);
}

ThemeData buildTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: C.bg,
      colorScheme: const ColorScheme.dark(
        primary: C.gold,
        secondary: C.orange,
        surface: C.surface,
        error: C.bad,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
            bodyColor: C.text,
            displayColor: C.text,
          ),
    );
