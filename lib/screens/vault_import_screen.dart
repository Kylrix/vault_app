import 'package:flutter/material.dart';

class VaultImportScreen extends StatelessWidget {
  const VaultImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Import from CSV, JSON, or passkey bundles can be attached here.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
