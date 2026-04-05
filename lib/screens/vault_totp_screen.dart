import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';
import '../widgets/vault_sections.dart';

class VaultTotpScreen extends StatefulWidget {
  const VaultTotpScreen({super.key});

  @override
  State<VaultTotpScreen> createState() => _VaultTotpScreenState();
}

class _VaultTotpScreenState extends State<VaultTotpScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<VaultStore>();
    final seconds = store.totpSecondsRemaining;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text('TOTP', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 12),
        Text('Codes rotate in $seconds seconds.'),
        const SizedBox(height: 20),
        ...store.totpItems.map(
          (item) => VaultRecordTile(
            title: item.issuer,
            subtitle: item.accountName,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(store.generateTotpCode(item), style: Theme.of(context).textTheme.titleLarge),
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () => Clipboard.setData(ClipboardData(text: store.generateTotpCode(item))),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
