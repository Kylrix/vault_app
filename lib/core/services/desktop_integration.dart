import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

import '../../widgets/vault_quick_launcher.dart';
import 'vault_store.dart';

class DesktopIntegration with WindowListener {
  DesktopIntegration({
    required this.navigatorKey,
    required this.store,
  });

  final GlobalKey<NavigatorState> navigatorKey;
  final VaultStore store;

  HotKey? _launcherHotKey;
  bool _initialized = false;

  bool get _isDesktop =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.macOS ||
          defaultTargetPlatform == TargetPlatform.linux);

  Future<void> initialize() async {
    if (!_isDesktop || _initialized) return;
    await windowManager.ensureInitialized();
    await windowManager.setPreventClose(store.settings.keepRunningInBackground);
    windowManager.addListener(this);
    await hotKeyManager.unregisterAll();
    await _registerHotkey();
    _initialized = true;
  }

  Future<void> refresh() async {
    if (!_isDesktop || !_initialized) return;
    await windowManager.setPreventClose(store.settings.keepRunningInBackground);
    await hotKeyManager.unregisterAll();
    await _registerHotkey();
  }

  Future<void> dispose() async {
    if (!_isDesktop || !_initialized) return;
    windowManager.removeListener(this);
    await hotKeyManager.unregisterAll();
    _initialized = false;
  }

  Future<void> _registerHotkey() async {
    if (!store.settings.desktopHotkeyEnabled) return;
    _launcherHotKey = HotKey(
      key: PhysicalKeyboardKey.space,
      modifiers: const [
        HotKeyModifier.control,
        HotKeyModifier.shift,
      ],
      scope: HotKeyScope.system,
      identifier: 'vault-quick-launch',
    );
    await hotKeyManager.register(
      _launcherHotKey!,
      keyDownHandler: (_) async => openLauncher(),
    );
  }

  Future<void> openLauncher() async {
    if (!_isDesktop) return;
    await windowManager.show();
    await windowManager.restore();
    await windowManager.focus();
    if (!store.isUnlocked) return;
    final navigator = navigatorKey.currentState;
    if (navigator == null) return;
    await navigator.push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierDismissible: true,
        barrierColor: Colors.black54,
        pageBuilder: (context, animation, secondaryAnimation) => const Center(
          child: VaultQuickLauncher(),
        ),
      ),
    );
  }

  @override
  void onWindowClose() {
    if (!store.settings.keepRunningInBackground) return;
    unawaited(windowManager.hide());
  }
}
