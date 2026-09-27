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
}
