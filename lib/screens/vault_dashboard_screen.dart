import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';
import '../widgets/vault_sections.dart';

class VaultDashboardScreen extends StatelessWidget {
  const VaultDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('Vault Overview', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            StatTile(label: 'Credentials', value: store.credentials.length.toString(), icon: Icons.vpn_key),
            StatTile(label: 'Folders', value: store.folders.length.toString(), icon: Icons.folder),
            StatTile(label: 'TOTP', value: store.totpItems.length.toString(), icon: Icons.timer),
            StatTile(label: 'Autofill', value: store.canUseAutofill ? 'On' : 'Off', icon: Icons.auto_mode),
          ],
        ),
        const SizedBox(height: 24),
        const _QuickActions(),
        const SizedBox(height: 24),
        Text('Recent credentials', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        ...store.filteredCredentials.take(5).map((credential) => VaultRecordTile(
              title: credential.title,
              subtitle: credential.username,
              trailing: IconButton(
                icon: Icon(credential.isFavorite ? Icons.star : Icons.star_border),
                onPressed: () => context.read<VaultStore>().toggleFavorite(credential),
              ),
            )),
      ],
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          onPressed: () => _openCreateCredential(context),
          icon: const Icon(Icons.add),
          label: const Text('Create credential'),
        ),
      ],
    );
  }

  Future<void> _openCreateCredential(BuildContext context) async {
    final title = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();
    final url = TextEditingController();
    final notes = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Create credential'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: title, decoration: const InputDecoration(labelText: 'Title')),
              TextField(controller: username, decoration: const InputDecoration(labelText: 'Username')),
              TextField(controller: password, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
              TextField(controller: url, decoration: const InputDecoration(labelText: 'URL')),
              TextField(controller: notes, decoration: const InputDecoration(labelText: 'Notes')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              await context.read<VaultStore>().upsertCredential(
                    title: title.text,
                    username: username.text,
                    password: password.text,
                    url: url.text,
                    notes: notes.text,
                    folderId: '',
                    favorite: false,
                  );
              if (context.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
