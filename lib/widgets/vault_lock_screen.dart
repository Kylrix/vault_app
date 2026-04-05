import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/services/vault_store.dart';

class VaultLockScreen extends StatefulWidget {
  const VaultLockScreen({super.key});

  @override
  State<VaultLockScreen> createState() => _VaultLockScreenState();
}

class _VaultLockScreenState extends State<VaultLockScreen> {
  final _controller = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(24),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock Vault', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 12),
                  const Text('Enter the master password to decrypt your local cache.'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _controller,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Master password'),
                    onSubmitted: (_) => _unlock(),
                  ),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: _busy ? null : _unlock,
                    child: _busy ? const CircularProgressIndicator() : const Text('Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _unlock() async {
    setState(() => _busy = true);
    try {
      await context.read<VaultStore>().unlock(_controller.text);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString())),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
