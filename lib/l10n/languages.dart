import 'dart:ui';

import 'generated/app_localizations.dart';

/// The languages the app is translated to, each named in itself, so anyone
/// can find their own in the list whatever language the app is in now.
const languageNames = {
  'hu': 'Magyar',
  'en': 'English',
  'de': 'Deutsch',
  'es': 'Español',
  'fr': 'Français',
};

/// The locale to show the app in: the chosen [language], or null to follow
/// the phone (also when the choice is not a translation any more).
Locale? chosenLocale(String? language) => AppLocalizations.supportedLocales
    .where((l) => l.languageCode == language)
    .firstOrNull;
