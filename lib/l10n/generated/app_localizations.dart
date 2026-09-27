import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In hu, this message translates to:
  /// **'ServerDeck'**
  String get appTitle;

  /// No description provided for @ok.
  ///
  /// In hu, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In hu, this message translates to:
  /// **'Mégse'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In hu, this message translates to:
  /// **'Mentés'**
  String get save;

  /// No description provided for @delete.
  ///
  /// In hu, this message translates to:
  /// **'Törlés'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In hu, this message translates to:
  /// **'Szerkesztés'**
  String get edit;

  /// No description provided for @rename.
  ///
  /// In hu, this message translates to:
  /// **'Átnevezés'**
  String get rename;

  /// No description provided for @paste.
  ///
  /// In hu, this message translates to:
  /// **'Beillesztés'**
  String get paste;

  /// No description provided for @fieldRequired.
  ///
  /// In hu, this message translates to:
  /// **'Kötelező'**
  String get fieldRequired;

  /// No description provided for @serversTitle.
  ///
  /// In hu, this message translates to:
  /// **'Szerverek'**
  String get serversTitle;

  /// No description provided for @serversEmptyTitle.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs szerver'**
  String get serversEmptyTitle;

  /// No description provided for @serversEmpty.
  ///
  /// In hu, this message translates to:
  /// **'Adj hozzá egy szervert a címével és a felhasználóneveddel. A ServerDeck SSH-n kapcsolódik, a szerverre semmit nem kell telepíteni.'**
  String get serversEmpty;

  /// No description provided for @serverAdd.
  ///
  /// In hu, this message translates to:
  /// **'Új szerver'**
  String get serverAdd;

  /// No description provided for @serverEditTitle.
  ///
  /// In hu, this message translates to:
  /// **'Szerver szerkesztése'**
  String get serverEditTitle;

  /// No description provided for @serverDeleteTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd: {name}?'**
  String serverDeleteTitle(String name);

  /// No description provided for @serverDeleteMessage.
  ///
  /// In hu, this message translates to:
  /// **'A szerver mentett jelszava, parancsai és naplóforrásai is törlődnek. A kulcsok megmaradnak.'**
  String get serverDeleteMessage;

  /// No description provided for @serverSectionConnection.
  ///
  /// In hu, this message translates to:
  /// **'Kapcsolat'**
  String get serverSectionConnection;

  /// No description provided for @serverSectionAuth.
  ///
  /// In hu, this message translates to:
  /// **'Bejelentkezés'**
  String get serverSectionAuth;

  /// No description provided for @serverHost.
  ///
  /// In hu, this message translates to:
  /// **'Cím'**
  String get serverHost;

  /// No description provided for @serverUser.
  ///
  /// In hu, this message translates to:
  /// **'Felhasználó'**
  String get serverUser;

  /// No description provided for @serverPort.
  ///
  /// In hu, this message translates to:
  /// **'Port'**
  String get serverPort;

  /// No description provided for @serverPortInvalid.
  ///
  /// In hu, this message translates to:
  /// **'1–65535'**
  String get serverPortInvalid;

  /// No description provided for @serverName.
  ///
  /// In hu, this message translates to:
  /// **'Név'**
  String get serverName;

  /// No description provided for @serverNameHint.
  ///
  /// In hu, this message translates to:
  /// **'Ha üres, a cím lesz'**
  String get serverNameHint;

  /// No description provided for @statusChecking.
  ///
  /// In hu, this message translates to:
  /// **'…'**
  String get statusChecking;

  /// No description provided for @statusDown.
  ///
  /// In hu, this message translates to:
  /// **'nem elérhető'**
  String get statusDown;

  /// No description provided for @authKey.
  ///
  /// In hu, this message translates to:
  /// **'Kulcs'**
  String get authKey;

  /// No description provided for @authPassword.
  ///
  /// In hu, this message translates to:
  /// **'Jelszó'**
  String get authPassword;

  /// No description provided for @authKeyPick.
  ///
  /// In hu, this message translates to:
  /// **'SSH-kulcs'**
  String get authKeyPick;

  /// No description provided for @authKeyMissing.
  ///
  /// In hu, this message translates to:
  /// **'Válassz kulcsot'**
  String get authKeyMissing;

  /// No description provided for @authKeyNone.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs kulcsod. Generálj egyet, és a nyilvános felét tedd a szerver ~/.ssh/authorized_keys fájljába.'**
  String get authKeyNone;

  /// No description provided for @authPasswordKept.
  ///
  /// In hu, this message translates to:
  /// **'Mentve. Hagyd üresen, ha nem változik.'**
  String get authPasswordKept;

  /// No description provided for @keysTitle.
  ///
  /// In hu, this message translates to:
  /// **'SSH-kulcsok'**
  String get keysTitle;

  /// No description provided for @keysEmptyTitle.
  ///
  /// In hu, this message translates to:
  /// **'Még nincs kulcs'**
  String get keysEmptyTitle;

  /// No description provided for @keysEmpty.
  ///
  /// In hu, this message translates to:
  /// **'Generálj egy új Ed25519-kulcsot, vagy importálj egy meglévőt. A privát kulcs a telefon titkosított tárolójában marad.'**
  String get keysEmpty;

  /// No description provided for @keyAdd.
  ///
  /// In hu, this message translates to:
  /// **'Új kulcs'**
  String get keyAdd;

  /// No description provided for @keyGenerateNew.
  ///
  /// In hu, this message translates to:
  /// **'Új kulcs generálása'**
  String get keyGenerateNew;

  /// No description provided for @keyGenerateHint.
  ///
  /// In hu, this message translates to:
  /// **'Ed25519, itt a telefonon készül'**
  String get keyGenerateHint;

  /// No description provided for @keyGenerated.
  ///
  /// In hu, this message translates to:
  /// **'Kész a kulcs. Másold a nyilvános felét a szerverre.'**
  String get keyGenerated;

  /// No description provided for @keyImport.
  ///
  /// In hu, this message translates to:
  /// **'Kulcs importálása'**
  String get keyImport;

  /// No description provided for @keyImportHint.
  ///
  /// In hu, this message translates to:
  /// **'OpenSSH, RSA vagy ECDSA privát kulcs'**
  String get keyImportHint;

  /// No description provided for @keyImportNote.
  ///
  /// In hu, this message translates to:
  /// **'A jelszóval védett kulcsot a ServerDeck egyszer feloldja, és a telefon titkosított tárolójába menti. A jelszót nem tárolja.'**
  String get keyImportNote;

  /// No description provided for @keyImportedName.
  ///
  /// In hu, this message translates to:
  /// **'Importált kulcs'**
  String get keyImportedName;

  /// No description provided for @keyName.
  ///
  /// In hu, this message translates to:
  /// **'Név'**
  String get keyName;

  /// No description provided for @keyPrivate.
  ///
  /// In hu, this message translates to:
  /// **'Privát kulcs'**
  String get keyPrivate;

  /// No description provided for @keyPassphrase.
  ///
  /// In hu, this message translates to:
  /// **'A kulcs jelszava'**
  String get keyPassphrase;

  /// No description provided for @keyCopy.
  ///
  /// In hu, this message translates to:
  /// **'Nyilvános kulcs másolása'**
  String get keyCopy;

  /// No description provided for @keyCopied.
  ///
  /// In hu, this message translates to:
  /// **'A nyilvános kulcs a vágólapon'**
  String get keyCopied;

  /// No description provided for @keyDeleteTitle.
  ///
  /// In hu, this message translates to:
  /// **'Törlöd: {name}?'**
  String keyDeleteTitle(String name);

  /// No description provided for @keyDeleteMessage.
  ///
  /// In hu, this message translates to:
  /// **'A privát kulcs végleg törlődik a telefonról.'**
  String get keyDeleteMessage;

  /// No description provided for @keyDeleteUsed.
  ///
  /// In hu, this message translates to:
  /// **'A privát kulcs végleg törlődik a telefonról. Ezek a szerverek használják, ezekhez új kulcs kell majd: {servers}'**
  String keyDeleteUsed(String servers);

  /// No description provided for @keyErrorNotAKey.
  ///
  /// In hu, this message translates to:
  /// **'Ez nem privát kulcs. A -----BEGIN kezdetű teljes szöveg kell.'**
  String get keyErrorNotAKey;

  /// No description provided for @keyErrorNeedsPassphrase.
  ///
  /// In hu, this message translates to:
  /// **'Ez a kulcs jelszóval védett. Add meg a jelszavát.'**
  String get keyErrorNeedsPassphrase;

  /// No description provided for @keyErrorWrongPassphrase.
  ///
  /// In hu, this message translates to:
  /// **'Hibás jelszó.'**
  String get keyErrorWrongPassphrase;

  /// No description provided for @keyErrorUnsupported.
  ///
  /// In hu, this message translates to:
  /// **'Ezt a kulcstípust a ServerDeck nem ismeri. Ed25519, RSA vagy ECDSA kulcs kell.'**
  String get keyErrorUnsupported;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
