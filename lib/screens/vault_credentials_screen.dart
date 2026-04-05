import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/services/vault_store.dart';
import '../widgets/vault_sections.dart';

class VaultCredentialsScreen extends StatelessWidget {
  const VaultCredentialsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search vault',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: context.read<VaultStore>().search,
              ),
            ),
            const SizedBox(width: 12),
            FilledButton.icon(
              onPressed: () => _openEditor(context),
              icon: const Icon(Icons.add),
              label: const Text('Add'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            ChoiceChip(
              label: const Text('All'),
              selected: store.selectedFolderId == 'all',
              onSelected: (_) => context.read<VaultStore>().selectFolder('all'),
            ),
            ...store.folders.map(
              (folder) => ChoiceChip(
                label: Text(folder.name),
                selected: store.selectedFolderId == folder.id,
                onSelected: (_) => context.read<VaultStore>().selectFolder(folder.id),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...store.filteredCredentials.map(
          (credential) => VaultRecordTile(
            title: credential.title,
            subtitle: credential.username,
            trailing: Wrap(
              spacing: 8,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => Clipboard.setData(ClipboardData(text: credential.password)),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new),
                  onPressed: credential.url.isEmpty ? null : () => launchUrl(Uri.parse(credential.url)),
                ),
                IconButton(
                  icon: Icon(credential.isFavorite ? Icons.star : Icons.star_border),
                  onPressed: () => context.read<VaultStore>().toggleFavorite(credential),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openEditor(BuildContext context) async {
    final title = TextEditingController();
    final username = TextEditingController();
    final password = TextEditingController();
    final url = TextEditingController();
    final notes = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New credential'),
        content: SingleChildScrollView(
          child: AutofillGroup(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: title,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: username,
                  decoration: const InputDecoration(labelText: 'Username'),
                  autofillHints: const [AutofillHints.username],
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: password,
                  obscureText: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Password'),
                  autofillHints: const [AutofillHints.password],
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: url,
                  decoration: const InputDecoration(labelText: 'URL'),
                  autofillHints: const [AutofillHints.url],
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                TextField(
                  controller: notes,
                  decoration: const InputDecoration(labelText: 'Notes'),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
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
