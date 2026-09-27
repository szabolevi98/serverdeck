import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

import '../data/app_data.dart';
import 'theme.dart';
import 'widgets.dart';

final localAuthProvider = Provider<LocalAuthentication>(
  (ref) => LocalAuthentication(),
);

/// Asks the phone's own lock (fingerprint, face or PIN). True when passed.
Future<bool> unlockWithDevice(WidgetRef ref, String reason) async {
  try {
    return await ref
        .read(localAuthProvider)
        .authenticate(
          localizedReason: reason,
          persistAcrossBackgrounding: true,
        );
  } on PlatformException {
    return false;
  } on LocalAuthException {
    return false;
  }
}

/// Covers the app with a lock screen when the app lock is on: at start, and
/// after [grace] in the background.
class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});
  final Widget child;

  static const grace = Duration(seconds: 60);

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate> {
  late final AppLifecycleListener _lifecycle;
  bool _locked = true;
  bool _asking = false;
  DateTime? _left;

  @override
  void initState() {
    super.initState();
    _lifecycle = AppLifecycleListener(
      onHide: () => _left ??= DateTime.now(),
      onShow: () {
        final left = _left;
        _left = null;
        if (left != null &&
            DateTime.now().difference(left) >= AppLockGate.grace &&
            _enabled) {
          setState(() => _locked = true);
          _unlock();
        }
      },
    );
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  bool get _enabled =>
      ref.read(appDataProvider).value?.settings.appLock ?? false;

  Future<void> _unlock() async {
    if (_asking) return;
    _asking = true;
    final ok = await unlockWithDevice(ref, context.l.lockReason);
    _asking = false;
    if (ok && mounted) setState(() => _locked = false);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(appDataProvider);
    // Nothing is shown until the settings are read, so the app cannot flash
    // up before the lock does.
    if (!data.hasValue && !data.hasError) {
      return const ColoredBox(color: Colors.transparent);
    }
    final enabled = data.value?.settings.appLock ?? false;
    if (!enabled || !_locked) return widget.child;

    WidgetsBinding.instance.addPostFrameCallback((_) => _unlock());
    return Material(
      color: context.colors.surfaceContainerLowest,
      child: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const TintedIcon(Icons.lock_rounded, size: 84),
              const SizedBox(height: 24),
              Text('ServerDeck', style: context.text.headlineMedium),
              const SizedBox(height: 8),
              Text(
                context.l.lockTitle,
                style: context.text.bodyMedium?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: _unlock,
                icon: const Icon(Icons.fingerprint_rounded),
                label: Text(context.l.lockUnlock),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
