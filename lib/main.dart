import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'demo/demo.dart';

void main() {
  runApp(
    ProviderScope(
      overrides: demoMode ? demoOverrides() : const [],
      child: const ServerDeckApp(),
    ),
  );
}
