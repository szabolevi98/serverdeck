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
  String get ok => 'OK';

  @override
  String get cancel => 'Mégse';

  @override
  String get save => 'Mentés';

  @override
  String get delete => 'Törlés';

  @override
  String get edit => 'Szerkesztés';

  @override
  String get rename => 'Átnevezés';

  @override
  String get paste => 'Beillesztés';

  @override
  String get fieldRequired => 'Kötelező';

  @override
  String get serversTitle => 'Szerverek';

  @override
  String get serversEmptyTitle => 'Még nincs szerver';

  @override
  String get serversEmpty =>
      'Adj hozzá egy szervert a címével és a felhasználóneveddel. A ServerDeck SSH-n kapcsolódik, a szerverre semmit nem kell telepíteni.';

  @override
  String get serverAdd => 'Új szerver';

  @override
  String get serverEditTitle => 'Szerver szerkesztése';

  @override
  String serverDeleteTitle(String name) {
    return 'Törlöd: $name?';
  }

  @override
  String get serverDeleteMessage =>
      'A szerver mentett jelszava, parancsai és naplóforrásai is törlődnek. A kulcsok megmaradnak.';

  @override
  String get serverSectionConnection => 'Kapcsolat';

  @override
  String get serverSectionAuth => 'Bejelentkezés';

  @override
  String get serverHost => 'Cím';

  @override
  String get serverUser => 'Felhasználó';

  @override
  String get serverPort => 'Port';

  @override
  String get serverPortInvalid => '1–65535';

  @override
  String get serverName => 'Név';

  @override
  String get serverNameHint => 'Ha üres, a cím lesz';

  @override
  String get statusChecking => '…';

  @override
  String get statusDown => 'offline';

  @override
  String get authKey => 'Kulcs';

  @override
  String get authPassword => 'Jelszó';

  @override
  String get authKeyPick => 'SSH-kulcs';

  @override
  String get authKeyMissing => 'Válassz kulcsot';

  @override
  String get authKeyNone =>
      'Még nincs kulcsod. Generálj egyet, és a nyilvános felét tedd a szerver ~/.ssh/authorized_keys fájljába.';

  @override
  String get authPasswordKept => 'Mentve. Hagyd üresen, ha nem változik.';

  @override
  String get keysTitle => 'SSH-kulcsok';

  @override
  String get keysEmptyTitle => 'Még nincs kulcs';

  @override
  String get keysEmpty =>
      'Generálj egy új Ed25519-kulcsot, vagy importálj egy meglévőt. A privát kulcs a telefon titkosított tárolójában marad.';

  @override
  String get keyAdd => 'Új kulcs';

  @override
  String get keyGenerateNew => 'Új kulcs generálása';

  @override
  String get keyGenerateHint => 'Ed25519, itt a telefonon készül';

  @override
  String get keyGenerated =>
      'Kész a kulcs. Másold a nyilvános felét a szerverre.';

  @override
  String get keyImport => 'Kulcs importálása';

  @override
  String get keyImportHint => 'OpenSSH, RSA vagy ECDSA privát kulcs';

  @override
  String get keyImportNote =>
      'A jelszóval védett kulcsot a ServerDeck egyszer feloldja, és a telefon titkosított tárolójába menti. A jelszót nem tárolja.';

  @override
  String get keyImportedName => 'Importált kulcs';

  @override
  String get keyName => 'Név';

  @override
  String get keyPrivate => 'Privát kulcs';

  @override
  String get keyPassphrase => 'A kulcs jelszava';

  @override
  String get keyCopy => 'Nyilvános kulcs másolása';

  @override
  String get keyCopied => 'A nyilvános kulcs a vágólapon';

  @override
  String keyDeleteTitle(String name) {
    return 'Törlöd: $name?';
  }

  @override
  String get keyDeleteMessage => 'A privát kulcs végleg törlődik a telefonról.';

  @override
  String keyDeleteUsed(String servers) {
    return 'A privát kulcs végleg törlődik a telefonról. Ezek a szerverek használják, ezekhez új kulcs kell majd: $servers';
  }

  @override
  String get keyErrorNotAKey =>
      'Ez nem privát kulcs. A -----BEGIN kezdetű teljes szöveg kell.';

  @override
  String get keyErrorNeedsPassphrase =>
      'Ez a kulcs jelszóval védett. Add meg a jelszavát.';

  @override
  String get keyErrorWrongPassphrase => 'Hibás jelszó.';

  @override
  String get keyErrorUnsupported =>
      'Ezt a kulcstípust a ServerDeck nem ismeri. Ed25519, RSA vagy ECDSA kulcs kell.';

  @override
  String get sessionOnline => 'online';

  @override
  String get sessionConnecting => 'kapcsolódás';

  @override
  String get sessionReconnect => 'Újrakapcsolódás';

  @override
  String get sessionConnectingTo => 'Kapcsolódás…';

  @override
  String get problemUnreachableTitle => 'A szerver nem érhető el';

  @override
  String problemUnreachable(String host, int port) {
    return 'Nem sikerült kapcsolatot nyitni: $host, $port-es port. Ellenőrizd a címet, a portot és a telefon internetkapcsolatát.';
  }

  @override
  String get problemTimeoutTitle => 'Nem válaszolt időben';

  @override
  String get problemTimeout =>
      'A szerver nem válaszolt 12 másodpercen belül. Lehet, hogy túlterhelt, vagy tűzfal nyeli el a kapcsolatot.';

  @override
  String get problemAuthTitle => 'Sikertelen bejelentkezés';

  @override
  String problemAuthKey(String user) {
    return 'A szerver nem fogadta el a kulcsot $user felhasználóként. Tedd a kulcs nyilvános felét a szerveren a ~/.ssh/authorized_keys fájlba.';
  }

  @override
  String problemAuthPassword(String user) {
    return 'A szerver nem fogadta el a jelszót $user felhasználóként.';
  }

  @override
  String get problemHostKeyChangedTitle => 'Megváltozott a szerver kulcsa';

  @override
  String get problemHostKeyChanged =>
      'A szerver más azonosító kulcsot mutatott, mint amit korábban elfogadtál. Ez lehet egy újratelepítés, de az is, hogy valaki beékelődött közétek. A ServerDeck ezért nem kapcsolódott.';

  @override
  String get problemHostKeyRefusedTitle => 'Elutasítottad a kulcsot';

  @override
  String get problemHostKeyRefused =>
      'A szerver kulcsát nem fogadtad el, ezért nem történt bejelentkezés.';

  @override
  String get problemMissingTitle => 'Hiányzik a bejelentkezési adat';

  @override
  String get problemMissing =>
      'Ehhez a szerverhez nincs kulcs vagy jelszó beállítva. Szerkeszd a szervert, és adj meg egyet.';

  @override
  String get problemDisconnectedTitle => 'Megszakadt a kapcsolat';

  @override
  String get problemDisconnected =>
      'A kapcsolat bontva: hálózatváltás, a szerver újraindult, vagy a telefon elaludt.';

  @override
  String get problemOtherTitle => 'Nem sikerült kapcsolódni';

  @override
  String get hostKeyNewTitle => 'Új szerver';

  @override
  String hostKeyNew(String host) {
    return 'Most kapcsolódsz először ide: $host. Ez a szerver azonosító kulcsa:';
  }

  @override
  String get hostKeyCheck =>
      'Ha biztosra akarsz menni, a szerveren ez a parancs ugyanezt az ujjlenyomatot írja ki:';

  @override
  String get hostKeyAccept => 'Elfogadom';

  @override
  String get hostKeyReject => 'Elutasítom';

  @override
  String get hostKeyKnown => 'Elfogadott';

  @override
  String get hostKeyNow => 'Most';

  @override
  String get hostKeyForget => 'Régi kulcs elfelejtése';

  @override
  String get hostKeyForgetTitle => 'Elfelejted a régi kulcsot?';

  @override
  String get hostKeyForgetMessage =>
      'Csak akkor tedd, ha tudod, miért változott a kulcs, például mert újratelepítetted a szervert. Utána a ServerDeck megkérdezi az új kulcsot.';

  @override
  String get statsFailedTitle => 'Nem sikerült lekérdezni';

  @override
  String get statsFailed =>
      'A szerver nem adott értelmezhető választ. A statisztikákhoz Linux kell (/proc).';

  @override
  String get statsStale =>
      'A legutóbbi frissítés nem sikerült. A fenti adatok korábbiak.';

  @override
  String get statCpu => 'CPU';

  @override
  String get statMemory => 'Memória';

  @override
  String get statDisk => 'Lemez';

  @override
  String statCores(int count) {
    return '$count mag';
  }

  @override
  String get statHistory => 'Az utolsó 3 perc';

  @override
  String get statHistoryHint =>
      '3 másodpercenként frissül, amíg ez a képernyő nyitva van.';

  @override
  String get statNetIn => 'Bejövő';

  @override
  String get statNetOut => 'Kimenő';

  @override
  String get statLoad => 'Terhelés';

  @override
  String get statLoad1 => '1 perc';

  @override
  String get statLoad5 => '5 perc';

  @override
  String get statLoad15 => '15 perc';

  @override
  String get statDisks => 'Lemezek';

  @override
  String get statSwap => 'Swap';

  @override
  String get statUptime => 'Fut';

  @override
  String uptimeDays(int days, int hours) {
    return '$days nap $hours óra';
  }

  @override
  String uptimeHours(int hours, int minutes) {
    return '$hours óra $minutes perc';
  }

  @override
  String get tabOverview => 'Áttekintés';

  @override
  String get tabServices => 'Szolgáltatások';

  @override
  String get servicesFailedTitle => 'Nem sikerült listázni';

  @override
  String get servicesSearch => 'Keresés név vagy leírás alapján';

  @override
  String servicesRunning(int count) {
    return 'Futó · $count';
  }

  @override
  String servicesFailed(int count) {
    return 'Hibás · $count';
  }

  @override
  String servicesAll(int count) {
    return 'Mind · $count';
  }

  @override
  String get servicesNone => 'Nincs találat.';

  @override
  String get servicesNoneFailed => 'Nincs hibás szolgáltatás.';

  @override
  String get containersNone => 'Nincs konténer.';

  @override
  String get stateRunning => 'fut';

  @override
  String get stateExited => 'lefutott';

  @override
  String get stateFailed => 'hibás';

  @override
  String get stateActivating => 'indul';

  @override
  String get stateInactive => 'áll';

  @override
  String get stateUnhealthy => 'beteg';

  @override
  String get statePaused => 'szünetel';

  @override
  String get stateRestarting => 'újraindul';

  @override
  String get stateExitedContainer => 'leállt';

  @override
  String get stateCreated => 'létrehozva';

  @override
  String get actionRestart => 'Újraindítás';

  @override
  String get actionReload => 'Újratöltés';

  @override
  String get actionStop => 'Leállítás';

  @override
  String get actionStart => 'Indítás';

  @override
  String actionConfirmTitle(String action, String subject) {
    return '$action: $subject?';
  }

  @override
  String actionConfirmMessage(String command) {
    return 'A szerveren ez fut le:\n$command';
  }

  @override
  String actionDone(String action, String subject) {
    return '$action kész: $subject';
  }

  @override
  String actionFailed(int code, String reason) {
    return 'Nem sikerült (kilépési kód: $code). $reason';
  }

  @override
  String get actionNeedsSudo =>
      'Ehhez rendszergazdai jog kell. Lépj be rootként, vagy engedélyezd a sudo-t jelszó nélkül erre a parancsra.';

  @override
  String get tabLogs => 'Naplók';

  @override
  String get logsJournal => 'Rendszernapló';

  @override
  String get logsAdd => 'Forrás';

  @override
  String get logsAddTitle => 'Új naplóforrás';

  @override
  String get logsKindUnit => 'Szolgáltatás';

  @override
  String get logsKindFile => 'Fájl';

  @override
  String get logsUnitLabel => 'Szolgáltatás neve';

  @override
  String get logsFileLabel => 'Fájl elérési útja';

  @override
  String get logsFilter => 'Szűrés';

  @override
  String get logsErrorsOnly => 'Csak a hibák';

  @override
  String get logsPause => 'Szünet';

  @override
  String get logsResume => 'Folytatás';

  @override
  String get logsClear => 'Törlés a képernyőről';

  @override
  String logsNewLines(int count) {
    return '$count új sor';
  }

  @override
  String logsEnded(int code) {
    return 'A napló követése leállt (kilépési kód: $code).';
  }

  @override
  String logsDeleteTitle(String name) {
    return 'Törlöd: $name?';
  }

  @override
  String get logsDeleteMessage =>
      'Csak a mentett forrás törlődik, a szerveren lévő napló nem.';

  @override
  String get tabCommands => 'Parancsok';

  @override
  String get commandAdd => 'Új parancs';

  @override
  String get commandEdit => 'Parancs szerkesztése';

  @override
  String get commandQuick => 'Egyszeri parancs…';

  @override
  String get commandRun => 'Futtatás';

  @override
  String commandRunTitle(String name) {
    return 'Futtatod: $name?';
  }

  @override
  String get commandSaved => 'Mentett parancsok';

  @override
  String get commandTemplates => 'Kezdésnek';

  @override
  String get commandTemplatesHint =>
      'Koppints egyre, és bekerül a mentett parancsok közé. Mindegyik csak olvas.';

  @override
  String get commandLabel => 'Parancs';

  @override
  String get commandEverywhere => 'Minden szerveren';

  @override
  String get commandEverywhereHint => 'Az összes szervernél megjelenik';

  @override
  String get commandConfirm => 'Kérdezzen futtatás előtt';

  @override
  String get commandCopy => 'Kimenet másolása';

  @override
  String get commandCopied => 'A kimenet a vágólapon';

  @override
  String get commandError => 'hiba';

  @override
  String get commandStopped => 'leállítva';

  @override
  String commandExit(int code) {
    return 'kilépési kód: $code';
  }

  @override
  String get commandRunning => 'fut';

  @override
  String get commandNoOutput => 'Nem írt ki semmit.';

  @override
  String get tplDisk => 'Lemezhasználat';

  @override
  String get tplFolders => 'Legnagyobb mappák';

  @override
  String get tplUpdates => 'Frissítések';

  @override
  String get tplWho => 'Ki van belépve';

  @override
  String get tplApache => 'Apache configtest';

  @override
  String get tplNginx => 'Nginx configtest';

  @override
  String get tplTop => 'Legtöbb CPU';

  @override
  String get tplPorts => 'Nyitott portok';

  @override
  String get tabTerminal => 'Terminál';

  @override
  String get terminalClosed => '[a shell bezárult]';

  @override
  String get terminalReopen => 'Új shell';

  @override
  String get lockReason => 'ServerDeck feloldása';

  @override
  String get lockTitle => 'A ServerDeck zárolva van';

  @override
  String get lockUnlock => 'Feloldás';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get settingsSecurity => 'Biztonság';

  @override
  String get settingsLock => 'Alkalmazászár';

  @override
  String get settingsLockHint =>
      'Ujjlenyomat, arc vagy a telefon PIN-kódja kell indításkor és 1 perc háttérben töltött idő után.';

  @override
  String get settingsLockUnsupported =>
      'Ehhez be kell állítani a telefonon képernyőzárat.';

  @override
  String get settingsKnownHosts => 'Ismert szerverkulcsok';

  @override
  String get settingsKnownHostsEmpty => 'Még nincs elfogadott szerverkulcs.';

  @override
  String get settingsKnownHostsHint =>
      'Az első kapcsolódáskor elfogadott azonosító kulcsok. Ha egy szerver kulcsa megváltozik, a ServerDeck nem kapcsolódik, amíg itt el nem felejted a régit.';

  @override
  String get settingsAbout => 'Névjegy';

  @override
  String get settingsAboutText =>
      'SSH-szerverkezelő. Nyílt forrású, MIT-licenc. Adatot nem gyűjt, minden a telefonon marad.';

  @override
  String get installKey => 'Kulcs telepítése jelszóval';

  @override
  String get installKeyAction => 'Telepítés';

  @override
  String installKeyHint(String user) {
    return 'A ServerDeck egyszer bejelentkezik $user jelszavával, és hozzáadja a kulcs nyilvános felét a ~/.ssh/authorized_keys fájlhoz. A jelszót nem menti el.';
  }

  @override
  String get installKeyDone =>
      'A kulcs a szerveren van. Kapcsolódás a kulccsal…';

  @override
  String get sessionError => 'hiba';

  @override
  String get themeTitle => 'Megjelenés';

  @override
  String get themeSystem => 'Rendszer';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeDark => 'Sötét';

  @override
  String monitorDownTitle(String name) {
    return '$name nem elérhető';
  }

  @override
  String monitorUpTitle(String name) {
    return '$name újra elérhető';
  }

  @override
  String get monitorUpBody => 'Az ellenőrzés újra sikerült.';

  @override
  String monitorUpBodyFor(String duration) {
    return '$duration volt elérhetetlen.';
  }

  @override
  String monitorHostKeyTitle(String name) {
    return '$name: megváltozott a szerver kulcsa';
  }

  @override
  String get monitorHostKeyBody =>
      'A ServerDeck nem jelentkezett be. Nézd meg a szervert, mielőtt elfogadod az új kulcsot.';

  @override
  String get monitorProblemUnreachable => 'Nem sikerült kapcsolatot nyitni.';

  @override
  String get monitorProblemTimeout => 'Nem válaszolt időben.';

  @override
  String get monitorProblemAuth =>
      'Válaszol, de nem fogadta el a bejelentkezést.';

  @override
  String get monitorProblemDisconnected =>
      'Bejelentkezés előtt bontotta a kapcsolatot.';

  @override
  String get monitorProblemHostKeyChanged => 'Megváltozott a kulcsa.';

  @override
  String get monitorProblemHostKeyUnknown =>
      'A kulcsát még nem fogadtad el: nyisd meg egyszer az appban.';

  @override
  String get monitorProblemMissing => 'Nincs hozzá kulcs vagy jelszó.';

  @override
  String get monitorProblemOther => 'Az ellenőrzés nem sikerült.';

  @override
  String durationSeconds(int n) {
    return '$n másodpercig';
  }

  @override
  String durationMinutes(int n) {
    return '$n percig';
  }

  @override
  String durationHours(int h, int m) {
    return '$h óra $m percig';
  }

  @override
  String durationDays(int d, int h) {
    return '$d nap $h óráig';
  }
}
