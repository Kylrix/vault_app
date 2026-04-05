import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';
import '../widgets/vault_quick_launcher.dart';
import 'vault_credentials_screen.dart';
import 'vault_dashboard_screen.dart';
import 'vault_import_screen.dart';
import 'vault_settings_screen.dart';
import 'vault_sharing_screen.dart';
import 'vault_totp_screen.dart';

class VaultShell extends StatefulWidget {
  const VaultShell({super.key});

  @override
  State<VaultShell> createState() => _VaultShellState();
}

class _VaultShellState extends State<VaultShell> {
  int _index = 0;

  final _screens = const [
    VaultDashboardScreen(),
    VaultCredentialsScreen(),
    VaultTotpScreen(),
    VaultSharingScreen(),
    VaultImportScreen(),
    VaultSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return Shortcuts(
      shortcuts: {
        LogicalKeySet(LogicalKeyboardKey.meta, LogicalKeyboardKey.keyK): const ActivateIntent(),
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyK): const ActivateIntent(),
      },
      child: Actions(
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) async => _openQuickLauncher(context),
          ),
        },
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Kylrix Vault'),
            actions: [
              if (store.user != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Center(child: Text(store.user!.email)),
                ),
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => _openQuickLauncher(context),
              ),
              IconButton(
                icon: const Icon(Icons.lock),
                onPressed: store.lock,
              ),
            ],
          ),
          body: isDesktop
              ? Row(
                  children: [
                    NavigationRail(
                      selectedIndex: _index,
                      onDestinationSelected: (value) => setState(() => _index = value),
                      destinations: const [
                        NavigationRailDestination(icon: Icon(Icons.dashboard_outlined), label: Text('Dashboard')),
                        NavigationRailDestination(icon: Icon(Icons.vpn_key_outlined), label: Text('Vaults')),
                        NavigationRailDestination(icon: Icon(Icons.timer_outlined), label: Text('TOTP')),
                        NavigationRailDestination(icon: Icon(Icons.share_outlined), label: Text('Sharing')),
                        NavigationRailDestination(icon: Icon(Icons.upload_outlined), label: Text('Import')),
                        NavigationRailDestination(icon: Icon(Icons.settings_outlined), label: Text('Settings')),
                      ],
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _screens[_index]),
                  ],
                )
              : IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: isDesktop
              ? null
              : NavigationBar(
                  selectedIndex: _index,
                  onDestinationSelected: (value) => setState(() => _index = value),
                  destinations: const [
                    NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Home'),
                    NavigationDestination(icon: Icon(Icons.vpn_key_outlined), label: 'Vault'),
                    NavigationDestination(icon: Icon(Icons.timer_outlined), label: 'TOTP'),
                    NavigationDestination(icon: Icon(Icons.share_outlined), label: 'Share'),
                    NavigationDestination(icon: Icon(Icons.upload_outlined), label: 'Import'),
                    NavigationDestination(icon: Icon(Icons.settings_outlined), label: 'Settings'),
                  ],
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => _openQuickLauncher(context),
            child: const Icon(Icons.auto_fix_high),
          ),
        ),
      ),
    );
  }

  Future<void> _openQuickLauncher(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (_) => const VaultQuickLauncher(),
    );
  }
}
