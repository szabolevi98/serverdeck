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
  /// **'offline'**
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

  /// No description provided for @sessionOnline.
  ///
  /// In hu, this message translates to:
  /// **'online'**
  String get sessionOnline;

  /// No description provided for @sessionConnecting.
  ///
  /// In hu, this message translates to:
  /// **'kapcsolódás'**
  String get sessionConnecting;

  /// No description provided for @sessionReconnect.
  ///
  /// In hu, this message translates to:
  /// **'Újrakapcsolódás'**
  String get sessionReconnect;

  /// No description provided for @sessionConnectingTo.
  ///
  /// In hu, this message translates to:
  /// **'Kapcsolódás…'**
  String get sessionConnectingTo;

  /// No description provided for @problemUnreachableTitle.
  ///
  /// In hu, this message translates to:
  /// **'A szerver nem érhető el'**
  String get problemUnreachableTitle;

  /// No description provided for @problemUnreachable.
  ///
  /// In hu, this message translates to:
  /// **'Nem sikerült kapcsolatot nyitni: {host}, {port}-es port. Ellenőrizd a címet, a portot és a telefon internetkapcsolatát.'**
  String problemUnreachable(String host, int port);

  /// No description provided for @problemTimeoutTitle.
  ///
  /// In hu, this message translates to:
  /// **'Nem válaszolt időben'**
  String get problemTimeoutTitle;

  /// No description provided for @problemTimeout.
  ///
  /// In hu, this message translates to:
  /// **'A szerver nem válaszolt 12 másodpercen belül. Lehet, hogy túlterhelt, vagy tűzfal nyeli el a kapcsolatot.'**
  String get problemTimeout;

  /// No description provided for @problemAuthTitle.
  ///
  /// In hu, this message translates to:
  /// **'Sikertelen bejelentkezés'**
  String get problemAuthTitle;

  /// No description provided for @problemAuthKey.
  ///
  /// In hu, this message translates to:
  /// **'A szerver nem fogadta el a kulcsot {user} felhasználóként. Tedd a kulcs nyilvános felét a szerveren a ~/.ssh/authorized_keys fájlba.'**
  String problemAuthKey(String user);

  /// No description provided for @problemAuthPassword.
  ///
  /// In hu, this message translates to:
  /// **'A szerver nem fogadta el a jelszót {user} felhasználóként.'**
  String problemAuthPassword(String user);

  /// No description provided for @problemHostKeyChangedTitle.
  ///
  /// In hu, this message translates to:
  /// **'Megváltozott a szerver kulcsa'**
  String get problemHostKeyChangedTitle;

  /// No description provided for @problemHostKeyChanged.
  ///
  /// In hu, this message translates to:
  /// **'A szerver más azonosító kulcsot mutatott, mint amit korábban elfogadtál. Ez lehet egy újratelepítés, de az is, hogy valaki beékelődött közétek. A ServerDeck ezért nem kapcsolódott.'**
  String get problemHostKeyChanged;

  /// No description provided for @problemHostKeyRefusedTitle.
  ///
  /// In hu, this message translates to:
  /// **'Elutasítottad a kulcsot'**
  String get problemHostKeyRefusedTitle;

  /// No description provided for @problemHostKeyRefused.
  ///
  /// In hu, this message translates to:
  /// **'A szerver kulcsát nem fogadtad el, ezért nem történt bejelentkezés.'**
  String get problemHostKeyRefused;

  /// No description provided for @problemMissingTitle.
  ///
  /// In hu, this message translates to:
  /// **'Hiányzik a bejelentkezési adat'**
  String get problemMissingTitle;

  /// No description provided for @problemMissing.
  ///
  /// In hu, this message translates to:
  /// **'Ehhez a szerverhez nincs kulcs vagy jelszó beállítva. Szerkeszd a szervert, és adj meg egyet.'**
  String get problemMissing;

  /// No description provided for @problemDisconnectedTitle.
  ///
  /// In hu, this message translates to:
  /// **'Megszakadt a kapcsolat'**
  String get problemDisconnectedTitle;

  /// No description provided for @problemDisconnected.
  ///
  /// In hu, this message translates to:
  /// **'A kapcsolat bontva: hálózatváltás, a szerver újraindult, vagy a telefon elaludt.'**
  String get problemDisconnected;

  /// No description provided for @problemOtherTitle.
  ///
  /// In hu, this message translates to:
  /// **'Nem sikerült kapcsolódni'**
  String get problemOtherTitle;

  /// No description provided for @hostKeyNewTitle.
  ///
  /// In hu, this message translates to:
  /// **'Új szerver'**
  String get hostKeyNewTitle;

  /// No description provided for @hostKeyNew.
  ///
  /// In hu, this message translates to:
  /// **'Most kapcsolódsz először ide: {host}. Ez a szerver azonosító kulcsa:'**
  String hostKeyNew(String host);

  /// No description provided for @hostKeyCheck.
  ///
  /// In hu, this message translates to:
  /// **'Ha biztosra akarsz menni, a szerveren ez a parancs ugyanezt az ujjlenyomatot írja ki:'**
  String get hostKeyCheck;

  /// No description provided for @hostKeyAccept.
  ///
  /// In hu, this message translates to:
  /// **'Elfogadom'**
  String get hostKeyAccept;

  /// No description provided for @hostKeyReject.
  ///
  /// In hu, this message translates to:
  /// **'Elutasítom'**
  String get hostKeyReject;

  /// No description provided for @hostKeyKnown.
  ///
  /// In hu, this message translates to:
  /// **'Elfogadott'**
  String get hostKeyKnown;

  /// No description provided for @hostKeyNow.
  ///
  /// In hu, this message translates to:
  /// **'Most'**
  String get hostKeyNow;

  /// No description provided for @hostKeyForget.
  ///
  /// In hu, this message translates to:
  /// **'Régi kulcs elfelejtése'**
  String get hostKeyForget;

  /// No description provided for @hostKeyForgetTitle.
  ///
  /// In hu, this message translates to:
  /// **'Elfelejted a régi kulcsot?'**
  String get hostKeyForgetTitle;

  /// No description provided for @hostKeyForgetMessage.
  ///
  /// In hu, this message translates to:
  /// **'Csak akkor tedd, ha tudod, miért változott a kulcs, például mert újratelepítetted a szervert. Utána a ServerDeck megkérdezi az új kulcsot.'**
  String get hostKeyForgetMessage;

  /// No description provided for @statsFailedTitle.
  ///
  /// In hu, this message translates to:
  /// **'Nem sikerült lekérdezni'**
  String get statsFailedTitle;

  /// No description provided for @statsFailed.
  ///
  /// In hu, this message translates to:
  /// **'A szerver nem adott értelmezhető választ. A statisztikákhoz Linux kell (/proc).'**
  String get statsFailed;

  /// No description provided for @statsStale.
  ///
  /// In hu, this message translates to:
  /// **'A legutóbbi frissítés nem sikerült. A fenti adatok korábbiak.'**
  String get statsStale;

  /// No description provided for @statCpu.
  ///
  /// In hu, this message translates to:
  /// **'CPU'**
  String get statCpu;

  /// No description provided for @statMemory.
  ///
  /// In hu, this message translates to:
  /// **'Memória'**
  String get statMemory;

  /// No description provided for @statDisk.
  ///
  /// In hu, this message translates to:
  /// **'Lemez'**
  String get statDisk;

  /// No description provided for @statCores.
  ///
  /// In hu, this message translates to:
  /// **'{count} mag'**
  String statCores(int count);

  /// No description provided for @statHistory.
  ///
  /// In hu, this message translates to:
  /// **'Az utolsó 3 perc'**
  String get statHistory;

  /// No description provided for @statHistoryHint.
  ///
  /// In hu, this message translates to:
  /// **'3 másodpercenként frissül, amíg ez a képernyő nyitva van.'**
  String get statHistoryHint;

  /// No description provided for @statNetIn.
  ///
  /// In hu, this message translates to:
  /// **'Bejövő'**
  String get statNetIn;

  /// No description provided for @statNetOut.
  ///
  /// In hu, this message translates to:
  /// **'Kimenő'**
  String get statNetOut;

  /// No description provided for @statLoad.
  ///
  /// In hu, this message translates to:
  /// **'Terhelés'**
  String get statLoad;

  /// No description provided for @statLoad1.
  ///
  /// In hu, this message translates to:
  /// **'1 perc'**
  String get statLoad1;

  /// No description provided for @statLoad5.
  ///
  /// In hu, this message translates to:
  /// **'5 perc'**
  String get statLoad5;

  /// No description provided for @statLoad15.
  ///
  /// In hu, this message translates to:
  /// **'15 perc'**
  String get statLoad15;

  /// No description provided for @statDisks.
  ///
  /// In hu, this message translates to:
  /// **'Lemezek'**
  String get statDisks;

  /// No description provided for @statSwap.
  ///
  /// In hu, this message translates to:
  /// **'Swap'**
  String get statSwap;

  /// No description provided for @statUptime.
  ///
  /// In hu, this message translates to:
  /// **'Fut'**
  String get statUptime;

  /// No description provided for @uptimeDays.
  ///
  /// In hu, this message translates to:
  /// **'{days} nap {hours} óra'**
  String uptimeDays(int days, int hours);

  /// No description provided for @uptimeHours.
  ///
  /// In hu, this message translates to:
  /// **'{hours} óra {minutes} perc'**
  String uptimeHours(int hours, int minutes);

  /// No description provided for @tabOverview.
  ///
  /// In hu, this message translates to:
  /// **'Áttekintés'**
  String get tabOverview;

  /// No description provided for @tabServices.
  ///
  /// In hu, this message translates to:
  /// **'Szolgáltatások'**
  String get tabServices;

  /// No description provided for @servicesFailedTitle.
  ///
  /// In hu, this message translates to:
  /// **'Nem sikerült listázni'**
  String get servicesFailedTitle;

  /// No description provided for @servicesSearch.
  ///
  /// In hu, this message translates to:
  /// **'Keresés név vagy leírás alapján'**
  String get servicesSearch;

  /// No description provided for @servicesRunning.
  ///
  /// In hu, this message translates to:
  /// **'Futó · {count}'**
  String servicesRunning(int count);

  /// No description provided for @servicesFailed.
  ///
  /// In hu, this message translates to:
  /// **'Hibás · {count}'**
  String servicesFailed(int count);

  /// No description provided for @servicesAll.
  ///
  /// In hu, this message translates to:
  /// **'Mind · {count}'**
  String servicesAll(int count);

  /// No description provided for @servicesNone.
  ///
  /// In hu, this message translates to:
  /// **'Nincs találat.'**
  String get servicesNone;

  /// No description provided for @servicesNoneFailed.
  ///
  /// In hu, this message translates to:
  /// **'Nincs hibás szolgáltatás.'**
  String get servicesNoneFailed;

  /// No description provided for @containersNone.
  ///
  /// In hu, this message translates to:
  /// **'Nincs konténer.'**
  String get containersNone;

  /// No description provided for @stateRunning.
  ///
  /// In hu, this message translates to:
  /// **'fut'**
  String get stateRunning;

  /// No description provided for @stateExited.
  ///
  /// In hu, this message translates to:
  /// **'lefutott'**
  String get stateExited;

  /// No description provided for @stateFailed.
  ///
  /// In hu, this message translates to:
  /// **'hibás'**
  String get stateFailed;

  /// No description provided for @stateActivating.
  ///
  /// In hu, this message translates to:
  /// **'indul'**
  String get stateActivating;

  /// No description provided for @stateInactive.
  ///
  /// In hu, this message translates to:
  /// **'áll'**
  String get stateInactive;

  /// No description provided for @stateUnhealthy.
  ///
  /// In hu, this message translates to:
  /// **'beteg'**
  String get stateUnhealthy;

  /// No description provided for @statePaused.
  ///
  /// In hu, this message translates to:
  /// **'szünetel'**
  String get statePaused;

  /// No description provided for @stateRestarting.
  ///
  /// In hu, this message translates to:
  /// **'újraindul'**
  String get stateRestarting;

  /// No description provided for @stateExitedContainer.
  ///
  /// In hu, this message translates to:
  /// **'leállt'**
  String get stateExitedContainer;

  /// No description provided for @stateCreated.
  ///
  /// In hu, this message translates to:
  /// **'létrehozva'**
  String get stateCreated;

  /// No description provided for @actionRestart.
  ///
  /// In hu, this message translates to:
  /// **'Újraindítás'**
  String get actionRestart;

  /// No description provided for @actionReload.
  ///
  /// In hu, this message translates to:
  /// **'Újratöltés'**
  String get actionReload;

  /// No description provided for @actionStop.
  ///
  /// In hu, this message translates to:
  /// **'Leállítás'**
  String get actionStop;

  /// No description provided for @actionStart.
  ///
  /// In hu, this message translates to:
  /// **'Indítás'**
  String get actionStart;

  /// No description provided for @actionConfirmTitle.
  ///
  /// In hu, this message translates to:
  /// **'{action}: {subject}?'**
  String actionConfirmTitle(String action, String subject);

  /// No description provided for @actionConfirmMessage.
  ///
  /// In hu, this message translates to:
  /// **'A szerveren ez fut le:\n{command}'**
  String actionConfirmMessage(String command);

  /// No description provided for @actionDone.
  ///
  /// In hu, this message translates to:
  /// **'{action} kész: {subject}'**
  String actionDone(String action, String subject);

  /// No description provided for @actionFailed.
  ///
  /// In hu, this message translates to:
  /// **'Nem sikerült (kilépési kód: {code}). {reason}'**
  String actionFailed(int code, String reason);

  /// No description provided for @actionNeedsSudo.
  ///
  /// In hu, this message translates to:
  /// **'Ehhez rendszergazdai jog kell. Lépj be rootként, vagy engedélyezd a sudo-t jelszó nélkül erre a parancsra.'**
  String get actionNeedsSudo;
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
