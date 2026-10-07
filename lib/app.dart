import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/app_data.dart';
import 'demo/demo.dart';

import 'l10n/generated/app_localizations.dart';
import 'l10n/languages.dart';
import 'ui/app_lock.dart';
import 'ui/servers_screen.dart';
import 'ui/theme.dart';

/// The app on the saved data, or on the demo's while one is open: a new scope
/// for the demo and another after it, so neither sees the other's providers.
class ServerDeckRoot extends StatelessWidget {
  const ServerDeckRoot({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: demoTour,
    builder: (context, tour, _) => ProviderScope(
      key: ValueKey(tour != null),
      overrides: demoMode
          ? demoOverrides()
          : tour != null
          ? demoOverrides(settings: tour)
          : const [],
      child: const ServerDeckApp(),
    ),
  );
}

class ServerDeckApp extends ConsumerWidget {
  const ServerDeckApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(
      appDataProvider.select((d) => d.value?.settings.themeMode),
    );
    final language = ref.watch(
      appDataProvider.select((d) => d.value?.settings.language),
    );
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: chosenLocale(language),
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      themeMode: themeMode ?? ThemeMode.system,
      builder: (context, child) => AppLockGate(child: child!),
      home: const ServersScreen(),
    );
  }
}
