import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/vault_home_screen.dart';

class VaultApp extends StatelessWidget {
  const VaultApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      brightness: Brightness.dark,
      surface: const Color(0xFF161412),
    );
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kylrix Vault',
      theme: base.copyWith(
        colorScheme: colorScheme,
        scaffoldBackgroundColor: const Color(0xFF0A0908),
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF161412),
          surfaceTintColor: Colors.transparent,
          foregroundColor: colorScheme.onSurface,
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF161412),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF1C1A18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const VaultHomeScreen(),
    );
  }
}
