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
}
