import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';

class VaultSettingsScreen extends StatelessWidget {
  const VaultSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    final settings = store.settings;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Settings', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        SwitchListTile(
          value: settings.autofillEnabled,
          onChanged: (value) => store.saveSettings(settings.copyWith(autofillEnabled: value)),
          title: const Text('Enable autofill palette'),
        ),
        SwitchListTile(
          value: settings.desktopHotkeyEnabled,
          onChanged: (value) => store.saveSettings(settings.copyWith(desktopHotkeyEnabled: value)),
          title: const Text('Enable desktop quick launcher'),
        ),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: () => _changePassword(context),
          child: const Text('Change master password'),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: store.lock,
          child: const Text('Lock vault'),
        ),
        OutlinedButton(
          onPressed: store.resetVault,
          child: const Text('Reset vault'),
        ),
      ],
    );
  }

  Future<void> _changePassword(BuildContext context) async {
    final current = TextEditingController();
    final next = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change master password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: current, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
            TextField(controller: next, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await context.read<VaultStore>().changeMasterPassword(current.text, next.text);
              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}
