import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'demo/demo.dart';
import 'monitor/background.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!demoMode) {
    try {
      await initMonitoring();
    } catch (_) {
      // The app works without the monitor; it only cannot run in the back.
    }
  }
  runApp(
    ProviderScope(
      overrides: demoMode ? demoOverrides() : const [],
      child: const ServerDeckApp(),
    ),
  );
}
