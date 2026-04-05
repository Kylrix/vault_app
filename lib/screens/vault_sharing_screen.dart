import 'package:flutter/material.dart';

class VaultSharingScreen extends StatelessWidget {
  const VaultSharingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Secure sharing is ready for encrypted handoff flows.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
