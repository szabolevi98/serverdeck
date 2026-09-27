// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appTitle => 'ServerDeck';

  @override
  String get serversTitle => 'Szerverek';

  @override
  String get serversEmpty => 'Még nincs szerver. Adj hozzá egyet a + gombbal.';
}
