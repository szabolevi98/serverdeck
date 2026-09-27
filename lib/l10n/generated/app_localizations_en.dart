// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'ServerDeck';

  @override
  String get serversTitle => 'Servers';

  @override
  String get serversEmpty => 'No servers yet. Add one with the + button.';
}
