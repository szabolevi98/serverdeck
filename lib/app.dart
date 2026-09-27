import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';
import 'ui/servers_screen.dart';
import 'ui/theme.dart';

class ServerDeckApp extends StatelessWidget {
  const ServerDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),
      home: const ServersScreen(),
    );
  }
}
