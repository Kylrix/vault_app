import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';
import 'vault_setup_screen.dart';
import 'vault_shell.dart';
import '../widgets/vault_lock_screen.dart';

class VaultHomeScreen extends StatelessWidget {
  const VaultHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    if (store.isBootstrapping) {
      return const _SplashScreen();
    }
    if (!store.hasInitializedVault) {
      return const VaultSetupScreen();
    }
    if (!store.isUnlocked) {
      return const VaultLockScreen();
    }
    return const VaultShell();
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
