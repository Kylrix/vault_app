import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../core/services/vault_store.dart';

class VaultQuickLauncher extends StatelessWidget {
  const VaultQuickLauncher({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    final credentials = store.filteredCredentials;
    return AlertDialog(
      title: const Text('Quick launch'),
      content: SizedBox(
        width: 600,
        child: ListView(
          shrinkWrap: true,
          children: [
            ...credentials.map(
              (credential) => ListTile(
                title: Text(credential.title),
                subtitle: Text(credential.username),
                trailing: Wrap(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person_outline),
                      onPressed: () => Clipboard.setData(ClipboardData(text: credential.username)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.copy),
                      onPressed: () => Clipboard.setData(ClipboardData(text: credential.password)),
                    ),
                    IconButton(
                      icon: const Icon(Icons.open_in_new),
                      onPressed: credential.url.isEmpty ? null : () => launchUrl(Uri.parse(credential.url)),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(),
            ...store.totpItems.map(
              (item) => ListTile(
                title: Text(item.issuer),
                subtitle: Text(item.accountName),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => Clipboard.setData(ClipboardData(text: store.generateTotpCode(item))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
