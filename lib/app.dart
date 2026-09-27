import 'package:flutter/material.dart';

import 'l10n/generated/app_localizations.dart';

class ServerDeckApp extends StatelessWidget {
  const ServerDeckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: _theme(Brightness.light),
      darkTheme: _theme(Brightness.dark),
      home: const _Home(),
    );
  }

  static ThemeData _theme(Brightness brightness) => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0E7C66),
          brightness: brightness,
        ),
      );
}

class _Home extends StatelessWidget {
  const _Home();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l.serversTitle)),
      body: Center(child: Text(l.serversEmpty)),
    );
  }
}
