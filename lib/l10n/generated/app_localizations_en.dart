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
  String get ok => 'OK';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get rename => 'Rename';

  @override
  String get paste => 'Paste';

  @override
  String get fieldRequired => 'Required';

  @override
  String get serversTitle => 'Servers';

  @override
  String get serversEmptyTitle => 'No servers yet';

  @override
  String get serversEmpty =>
      'Add a server by its address and your user name. ServerDeck connects over SSH; nothing needs installing on the server.';

  @override
  String get serverAdd => 'Add server';

  @override
  String get serverEditTitle => 'Edit server';

  @override
  String serverDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get serverDeleteMessage =>
      'Its saved password, commands and log sources go too. Keys are kept.';

  @override
  String get serverSectionConnection => 'Connection';

  @override
  String get serverSectionAuth => 'Sign-in';

  @override
  String get serverHost => 'Address';

  @override
  String get serverUser => 'User';

  @override
  String get serverPort => 'Port';

  @override
  String get serverPortInvalid => '1–65535';

  @override
  String get serverName => 'Name';

  @override
  String get serverNameHint => 'The address, if left empty';

  @override
  String get statusChecking => '…';

  @override
  String get statusDown => 'offline';

  @override
  String get authKey => 'Key';

  @override
  String get authPassword => 'Password';

  @override
  String get authKeyPick => 'SSH key';

  @override
  String get authKeyMissing => 'Pick a key';

  @override
  String get authKeyNone =>
      'No keys yet. Generate one and put its public half into the server\'s ~/.ssh/authorized_keys.';

  @override
  String get authPasswordKept => 'Saved. Leave empty to keep it.';

  @override
  String get keysTitle => 'SSH keys';

  @override
  String get keysEmptyTitle => 'No keys yet';

  @override
  String get keysEmpty =>
      'Generate a new Ed25519 key or import one you have. The private key stays in the phone\'s encrypted storage.';

  @override
  String get keyAdd => 'Add key';

  @override
  String get keyGenerateNew => 'Generate a new key';

  @override
  String get keyGenerateHint => 'Ed25519, made here on the phone';

  @override
  String get keyGenerated => 'Key ready. Copy its public half to the server.';

  @override
  String get keyImport => 'Import a key';

  @override
  String get keyImportHint => 'OpenSSH, RSA or ECDSA private key';

  @override
  String get keyImportNote =>
      'A passphrase-protected key is unlocked once and saved to the phone\'s encrypted storage. The passphrase is not kept.';

  @override
  String get keyImportedName => 'Imported key';

  @override
  String get keyName => 'Name';

  @override
  String get keyPrivate => 'Private key';

  @override
  String get keyPassphrase => 'Key passphrase';

  @override
  String get keyCopy => 'Copy public key';

  @override
  String get keyCopied => 'Public key copied';

  @override
  String keyDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get keyDeleteMessage =>
      'The private key is deleted from the phone for good.';

  @override
  String keyDeleteUsed(String servers) {
    return 'The private key is deleted from the phone for good. These servers use it and will need another key: $servers';
  }

  @override
  String get keyErrorNotAKey =>
      'This is not a private key. Paste the whole text starting with -----BEGIN.';

  @override
  String get keyErrorNeedsPassphrase =>
      'This key is protected. Enter its passphrase.';

  @override
  String get keyErrorWrongPassphrase => 'Wrong passphrase.';

  @override
  String get keyErrorUnsupported =>
      'ServerDeck does not know this key type. Use an Ed25519, RSA or ECDSA key.';
}
