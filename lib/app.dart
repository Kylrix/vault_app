import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'core/services/desktop_integration.dart';
import 'core/services/vault_store.dart';
import 'screens/vault_home_screen.dart';

class VaultApp extends StatefulWidget {
  const VaultApp({super.key});

  @override
  State<VaultApp> createState() => _VaultAppState();
}

class _VaultAppState extends State<VaultApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  DesktopIntegration? _desktopIntegration;
  VaultStore? _store;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final store = context.read<VaultStore>();
    if (_store == store) return;
    _store?.removeListener(_syncDesktopIntegration);
    _store = store;
    _store!.addListener(_syncDesktopIntegration);
    _desktopIntegration ??= DesktopIntegration(
      navigatorKey: _navigatorKey,
      store: _store!,
    );
    _desktopIntegration!.initialize();
  }

  @override
  void dispose() {
    _store?.removeListener(_syncDesktopIntegration);
    _desktopIntegration?.dispose();
    super.dispose();
  }

  void _syncDesktopIntegration() {
    _desktopIntegration?.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark(useMaterial3: true);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF10B981),
      brightness: Brightness.dark,
      surface: const Color(0xFF161412),
    );
    return MaterialApp(
      navigatorKey: _navigatorKey,
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
