// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'ServerDeck';

  @override
  String get ok => 'OK';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get save => 'Speichern';

  @override
  String get delete => 'Löschen';

  @override
  String get edit => 'Bearbeiten';

  @override
  String get rename => 'Umbenennen';

  @override
  String get paste => 'Einfügen';

  @override
  String get fieldRequired => 'Pflichtfeld';

  @override
  String get serversTitle => 'Server';

  @override
  String get serversEmptyTitle => 'Noch keine Server';

  @override
  String get serversEmpty =>
      'Füge einen Server mit seiner Adresse und deinem Benutzernamen hinzu. ServerDeck verbindet sich über SSH; auf dem Server muss nichts installiert werden.';

  @override
  String get serverAdd => 'Server hinzufügen';

  @override
  String get serverEditTitle => 'Server bearbeiten';

  @override
  String serverDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get serverDeleteMessage =>
      'Das gespeicherte Passwort, die Befehle und die Logquellen werden mitgelöscht. Die Schlüssel bleiben.';

  @override
  String get serverSectionConnection => 'Verbindung';

  @override
  String get serverSectionAuth => 'Anmeldung';

  @override
  String get serverHost => 'Adresse';

  @override
  String get serverUser => 'Benutzer';

  @override
  String get serverPort => 'Port';

  @override
  String get serverPortInvalid => '1–65535';

  @override
  String get serverName => 'Name';

  @override
  String get serverNameHint => 'Leer lassen für die Adresse';

  @override
  String get statusChecking => '…';

  @override
  String get statusDown => 'offline';

  @override
  String get authKey => 'Schlüssel';

  @override
  String get authPassword => 'Passwort';

  @override
  String get authKeyPick => 'SSH-Schlüssel';

  @override
  String get authKeyMissing => 'Wähle einen Schlüssel';

  @override
  String get authKeyNone =>
      'Noch keine Schlüssel. Erzeuge einen und trage seinen öffentlichen Teil in ~/.ssh/authorized_keys auf dem Server ein.';

  @override
  String get authPasswordKept => 'Gespeichert. Leer lassen, um es zu behalten.';

  @override
  String get keysTitle => 'SSH-Schlüssel';

  @override
  String get keysEmptyTitle => 'Noch keine Schlüssel';

  @override
  String get keysEmpty =>
      'Erzeuge einen neuen Ed25519-Schlüssel oder importiere einen vorhandenen. Der private Schlüssel bleibt im verschlüsselten Speicher des Telefons.';

  @override
  String get keyAdd => 'Schlüssel hinzufügen';

  @override
  String get keyGenerateNew => 'Neuen Schlüssel erzeugen';

  @override
  String get keyGenerateHint => 'Ed25519, direkt auf dem Telefon erzeugt';

  @override
  String get keyGenerated =>
      'Schlüssel bereit. Kopiere seinen öffentlichen Teil auf den Server.';

  @override
  String get keyImport => 'Schlüssel importieren';

  @override
  String get keyImportHint => 'Privater OpenSSH-, RSA- oder ECDSA-Schlüssel';

  @override
  String get keyImportNote =>
      'Ein passwortgeschützter Schlüssel wird einmal entsperrt und im verschlüsselten Speicher des Telefons abgelegt. Die Passphrase wird nicht gespeichert.';

  @override
  String get keyImportedName => 'Importierter Schlüssel';

  @override
  String get keyName => 'Name';

  @override
  String get keyPrivate => 'Privater Schlüssel';

  @override
  String get keyPassphrase => 'Passphrase des Schlüssels';

  @override
  String get keyCopy => 'Öffentlichen Schlüssel kopieren';

  @override
  String get keyCopied => 'Öffentlicher Schlüssel kopiert';

  @override
  String keyDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get keyDeleteMessage =>
      'Der private Schlüssel wird endgültig vom Telefon gelöscht.';

  @override
  String keyDeleteUsed(String servers) {
    return 'Der private Schlüssel wird endgültig vom Telefon gelöscht. Diese Server nutzen ihn und brauchen dann einen anderen Schlüssel: $servers';
  }

  @override
  String get keyErrorNotAKey =>
      'Das ist kein privater Schlüssel. Füge den ganzen Text ein, der mit -----BEGIN beginnt.';

  @override
  String get keyErrorNeedsPassphrase =>
      'Dieser Schlüssel ist geschützt. Gib seine Passphrase ein.';

  @override
  String get keyErrorWrongPassphrase => 'Falsche Passphrase.';

  @override
  String get keyErrorUnsupported =>
      'ServerDeck kennt diesen Schlüsseltyp nicht. Verwende einen Ed25519-, RSA- oder ECDSA-Schlüssel.';

  @override
  String get sessionOnline => 'online';

  @override
  String get sessionConnecting => 'verbinde';

  @override
  String get sessionReconnect => 'Neu verbinden';

  @override
  String get sessionConnectingTo => 'Verbinde…';

  @override
  String get problemUnreachableTitle => 'Server nicht erreichbar';

  @override
  String problemUnreachable(String host, int port) {
    return 'Keine Verbindung zu $host auf Port $port möglich. Prüfe die Adresse, den Port und die Verbindung des Telefons.';
  }

  @override
  String get problemTimeoutTitle => 'Keine Antwort';

  @override
  String get problemTimeout =>
      'Der Server hat nicht innerhalb von 12 Sekunden geantwortet. Vielleicht ist er überlastet, oder eine Firewall verwirft die Verbindung.';

  @override
  String get problemAuthTitle => 'Anmeldung fehlgeschlagen';

  @override
  String problemAuthKey(String user) {
    return 'Der Server hat den Schlüssel für $user nicht akzeptiert. Trage den öffentlichen Teil des Schlüssels in ~/.ssh/authorized_keys auf dem Server ein.';
  }

  @override
  String problemAuthPassword(String user) {
    return 'Der Server hat das Passwort für $user nicht akzeptiert.';
  }

  @override
  String get problemHostKeyChangedTitle =>
      'Der Schlüssel des Servers hat sich geändert';

  @override
  String get problemHostKeyChanged =>
      'Der Server hat einen anderen Identitätsschlüssel gezeigt als den, den du zuvor akzeptiert hast. Das kann eine Neuinstallation sein oder jemand dazwischen. ServerDeck hat sich nicht verbunden.';

  @override
  String get problemHostKeyRefusedTitle => 'Schlüssel abgelehnt';

  @override
  String get problemHostKeyRefused =>
      'Du hast den Schlüssel des Servers nicht akzeptiert, deshalb hat sich ServerDeck nicht angemeldet.';

  @override
  String get problemMissingTitle => 'Keine Anmeldedaten';

  @override
  String get problemMissing =>
      'Für diesen Server ist weder Schlüssel noch Passwort festgelegt. Bearbeite den Server und füge eines hinzu.';

  @override
  String get problemDisconnectedTitle => 'Verbindung verloren';

  @override
  String get problemDisconnected =>
      'Die Verbindung ist abgebrochen: ein Netzwechsel, ein Neustart des Servers, oder das Telefon war im Ruhemodus.';

  @override
  String get problemOtherTitle => 'Verbindung fehlgeschlagen';

  @override
  String get hostKeyNewTitle => 'Neuer Server';

  @override
  String hostKeyNew(String host) {
    return 'Du verbindest dich zum ersten Mal mit $host. Das ist der Identitätsschlüssel des Servers:';
  }

  @override
  String get hostKeyCheck =>
      'Zur Sicherheit gibt dieser Befehl auf dem Server denselben Fingerabdruck aus:';

  @override
  String get hostKeyAccept => 'Akzeptieren';

  @override
  String get hostKeyReject => 'Ablehnen';

  @override
  String get hostKeyKnown => 'Akzeptiert';

  @override
  String get hostKeyNow => 'Jetzt';

  @override
  String get hostKeyForget => 'Alten Schlüssel vergessen';

  @override
  String get hostKeyForgetTitle => 'Alten Schlüssel vergessen?';

  @override
  String get hostKeyForgetMessage =>
      'Tu das nur, wenn du weißt, warum sich der Schlüssel geändert hat, zum Beispiel weil du den Server neu installiert hast. ServerDeck fragt dann nach dem neuen Schlüssel.';

  @override
  String get statsFailedTitle => 'Server konnte nicht gelesen werden';

  @override
  String get statsFailed =>
      'Die Antwort des Servers ergab keinen Sinn. Die Statistiken brauchen Linux (/proc).';

  @override
  String get statsStale =>
      'Die letzte Aktualisierung ist fehlgeschlagen. Die Werte oben sind älter.';

  @override
  String get statCpu => 'CPU';

  @override
  String get statMemory => 'Speicher';

  @override
  String get statDisk => 'Festplatte';

  @override
  String statCores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count Kerne',
      one: '1 Kern',
    );
    return '$_temp0';
  }

  @override
  String get statHistory => 'Letzte 3 Minuten';

  @override
  String get statHistoryHint =>
      'Wird alle 3 Sekunden aktualisiert, solange dieser Bildschirm offen ist.';

  @override
  String get statNetIn => 'Ein';

  @override
  String get statNetOut => 'Aus';

  @override
  String get statLoad => 'Last';

  @override
  String get statLoad1 => '1 Min.';

  @override
  String get statLoad5 => '5 Min.';

  @override
  String get statLoad15 => '15 Min.';

  @override
  String get statDisks => 'Festplatten';

  @override
  String get statSwap => 'Swap';

  @override
  String get statUptime => 'Läuft seit';

  @override
  String uptimeDays(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days Tage',
      one: '1 Tag',
    );
    return '$_temp0, $hours Std.';
  }

  @override
  String uptimeHours(int hours, int minutes) {
    return '$hours Std. $minutes Min.';
  }

  @override
  String get tabOverview => 'Übersicht';

  @override
  String get tabServices => 'Dienste';

  @override
  String get servicesFailedTitle => 'Dienste konnten nicht aufgelistet werden';

  @override
  String get servicesSearch => 'Nach Name oder Beschreibung suchen';

  @override
  String servicesRunning(int count) {
    return 'Laufend · $count';
  }

  @override
  String servicesFailed(int count) {
    return 'Fehlgeschlagen · $count';
  }

  @override
  String servicesAll(int count) {
    return 'Alle · $count';
  }

  @override
  String get servicesNone => 'Keine Treffer.';

  @override
  String get servicesNoneFailed => 'Keine fehlgeschlagenen Dienste.';

  @override
  String get containersNone => 'Keine Container.';

  @override
  String get stateRunning => 'läuft';

  @override
  String get stateExited => 'beendet';

  @override
  String get stateFailed => 'fehlgeschlagen';

  @override
  String get stateActivating => 'startet';

  @override
  String get stateInactive => 'gestoppt';

  @override
  String get stateUnhealthy => 'fehlerhaft';

  @override
  String get statePaused => 'pausiert';

  @override
  String get stateRestarting => 'startet neu';

  @override
  String get stateExitedContainer => 'beendet';

  @override
  String get stateCreated => 'erstellt';

  @override
  String get actionRestart => 'Neu starten';

  @override
  String get actionReload => 'Neu laden';

  @override
  String get actionStop => 'Stoppen';

  @override
  String get actionStart => 'Starten';

  @override
  String actionConfirmTitle(String action, String subject) {
    return '$action: $subject?';
  }

  @override
  String actionConfirmMessage(String command) {
    return 'Das wird auf dem Server ausgeführt:\n$command';
  }

  @override
  String actionDone(String action, String subject) {
    return '$action erledigt: $subject';
  }

  @override
  String actionFailed(int code, String reason) {
    return 'Das hat nicht geklappt (Exit-Code $code). $reason';
  }

  @override
  String get actionNeedsSudo =>
      'Dafür sind Administratorrechte nötig. Melde dich als root an oder erlaube sudo ohne Passwort für diesen Befehl.';

  @override
  String get tabLogs => 'Logs';

  @override
  String get logsJournal => 'Systemjournal';

  @override
  String get logsAdd => 'Quelle';

  @override
  String get logsAddTitle => 'Neue Logquelle';

  @override
  String get logsKindUnit => 'Dienst';

  @override
  String get logsKindFile => 'Datei';

  @override
  String get logsUnitLabel => 'Name des Dienstes';

  @override
  String get logsFileLabel => 'Dateipfad';

  @override
  String get logsFilter => 'Filter';

  @override
  String get logsErrorsOnly => 'Nur Fehler';

  @override
  String get logsPause => 'Pause';

  @override
  String get logsResume => 'Fortsetzen';

  @override
  String get logsClear => 'Bildschirm leeren';

  @override
  String logsNewLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count neue Zeilen',
      one: '1 neue Zeile',
    );
    return '$_temp0';
  }

  @override
  String logsEnded(int code) {
    return 'Das Verfolgen des Logs wurde beendet (Exit-Code $code).';
  }

  @override
  String logsDeleteTitle(String name) {
    return '$name löschen?';
  }

  @override
  String get logsDeleteMessage =>
      'Nur die gespeicherte Quelle wird gelöscht, nicht das Log auf dem Server.';

  @override
  String get tabCommands => 'Befehle';

  @override
  String get commandAdd => 'Neuer Befehl';

  @override
  String get commandEdit => 'Befehl bearbeiten';

  @override
  String get commandQuick => 'Einmaliger Befehl…';

  @override
  String get commandRun => 'Ausführen';

  @override
  String commandRunTitle(String name) {
    return '$name ausführen?';
  }

  @override
  String get commandSaved => 'Gespeicherte Befehle';

  @override
  String get commandTemplates => 'Für den Anfang';

  @override
  String get commandTemplatesHint =>
      'Tippe auf einen, um ihn zu deinen gespeicherten Befehlen hinzuzufügen. Sie lesen nur.';

  @override
  String get commandLabel => 'Befehl';

  @override
  String get commandEverywhere => 'Auf allen Servern';

  @override
  String get commandEverywhereHint => 'Erscheint bei all deinen Servern';

  @override
  String get commandConfirm => 'Vor dem Ausführen fragen';

  @override
  String get commandCopy => 'Ausgabe kopieren';

  @override
  String get commandCopied => 'Ausgabe kopiert';

  @override
  String get commandError => 'Fehler';

  @override
  String get commandStopped => 'gestoppt';

  @override
  String commandExit(int code) {
    return 'Exit $code';
  }

  @override
  String get commandRunning => 'läuft';

  @override
  String get commandNoOutput => 'Keine Ausgabe.';

  @override
  String get tplDisk => 'Speicherbelegung';

  @override
  String get tplFolders => 'Größte Ordner';

  @override
  String get tplUpdates => 'Ausstehende Updates';

  @override
  String get tplWho => 'Wer ist angemeldet';

  @override
  String get tplApache => 'Apache-Konfiguration testen';

  @override
  String get tplNginx => 'Nginx-Konfiguration testen';

  @override
  String get tplTop => 'Top-CPU';

  @override
  String get tplPorts => 'Offene Ports';

  @override
  String get tabTerminal => 'Terminal';

  @override
  String get terminalClosed => '[Shell geschlossen]';

  @override
  String get terminalReopen => 'Neue Shell';

  @override
  String get lockReason => 'ServerDeck entsperren';

  @override
  String get lockTitle => 'ServerDeck ist gesperrt';

  @override
  String get lockUnlock => 'Entsperren';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get settingsSecurity => 'Sicherheit';

  @override
  String get settingsLock => 'App-Sperre';

  @override
  String get settingsLockHint =>
      'Fingerabdruck, Gesicht oder die PIN des Telefons beim Start und nach einer Minute im Hintergrund.';

  @override
  String get settingsLockUnsupported =>
      'Richte zuerst eine Displaysperre auf dem Telefon ein.';

  @override
  String get settingsKnownHosts => 'Bekannte Serverschlüssel';

  @override
  String get settingsKnownHostsEmpty =>
      'Noch keine Serverschlüssel akzeptiert.';

  @override
  String get settingsKnownHostsHint =>
      'Beim ersten Kontakt akzeptierte Identitätsschlüssel. Ändert sich der Schlüssel eines Servers, verbindet sich ServerDeck erst wieder, wenn du den alten hier vergisst.';

  @override
  String get settingsAbout => 'Über';

  @override
  String get settingsAboutText =>
      'SSH-Serververwaltung. Open Source, MIT-Lizenz. Sammelt nichts; alles bleibt auf dem Telefon.';

  @override
  String get installKey => 'Schlüssel mit Passwort installieren';

  @override
  String get installKeyAction => 'Installieren';

  @override
  String installKeyHint(String user) {
    return 'ServerDeck meldet sich einmal mit dem Passwort von $user an und fügt den öffentlichen Teil des Schlüssels zu ~/.ssh/authorized_keys hinzu. Das Passwort wird nicht gespeichert.';
  }

  @override
  String get installKeyDone =>
      'Der Schlüssel ist auf dem Server. Verbinde damit…';

  @override
  String get sessionError => 'Fehler';

  @override
  String get themeTitle => 'Darstellung';

  @override
  String get themeSystem => 'System';

  @override
  String get themeLight => 'Hell';

  @override
  String get themeDark => 'Dunkel';

  @override
  String get languageTitle => 'Sprache';

  @override
  String get languageSystem => 'Sprache des Telefons';

  @override
  String monitorDownTitle(String name) {
    return '$name ist ausgefallen';
  }

  @override
  String monitorUpTitle(String name) {
    return '$name ist wieder erreichbar';
  }

  @override
  String get monitorUpBody => 'Die Prüfung klappt wieder.';

  @override
  String monitorUpBodyFor(String duration) {
    return 'Ausgefallen für $duration.';
  }

  @override
  String monitorHostKeyTitle(String name) {
    return '$name: Der Schlüssel des Servers hat sich geändert';
  }

  @override
  String get monitorHostKeyBody =>
      'ServerDeck hat sich nicht angemeldet. Sieh dir den Server an, bevor du den neuen Schlüssel akzeptierst.';

  @override
  String get monitorProblemUnreachable => 'Keine Verbindung möglich.';

  @override
  String get monitorProblemTimeout => 'Keine Antwort.';

  @override
  String get monitorProblemAuth =>
      'Er antwortet, hat die Anmeldung aber nicht akzeptiert.';

  @override
  String get monitorProblemDisconnected =>
      'Er hat vor der Anmeldung aufgelegt.';

  @override
  String get monitorProblemHostKeyChanged =>
      'Sein Schlüssel hat sich geändert.';

  @override
  String get monitorProblemHostKeyUnknown =>
      'Sein Schlüssel ist noch nicht akzeptiert: Öffne ihn einmal in der App.';

  @override
  String get monitorProblemMissing => 'Er hat weder Schlüssel noch Passwort.';

  @override
  String get monitorProblemOther => 'Die Prüfung ist fehlgeschlagen.';

  @override
  String durationSeconds(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Sekunden',
      one: '1 Sekunde',
    );
    return '$_temp0';
  }

  @override
  String durationMinutes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Minuten',
      one: '1 Minute',
    );
    return '$_temp0';
  }

  @override
  String durationHours(int h, int m) {
    return '$h Std. $m Min.';
  }

  @override
  String durationDays(int d, int h) {
    String _temp0 = intl.Intl.pluralLogic(
      d,
      locale: localeName,
      other: '$d Tage',
      one: '1 Tag',
    );
    return '$_temp0 $h Std.';
  }

  @override
  String get monitorSection => 'Hintergrundüberwachung';

  @override
  String get monitorEnable => 'Im Hintergrund überwachen';

  @override
  String get monitorEnableHint =>
      'Benachrichtigung, wenn er ausfällt und wenn er wieder da ist.';

  @override
  String get monitorEvery => 'Wie oft';

  @override
  String get monitorHow => 'Wie';

  @override
  String get monitorModeSsh => 'Anmelden';

  @override
  String get monitorModePort => 'Nur Port';

  @override
  String get monitorModeSshHint =>
      'Meldet sich über SSH an und führt einen leeren Befehl aus. So wird auch geprüft, ob der Schlüssel noch funktioniert, und fail2ban zählt es nie als Angriff.';

  @override
  String get monitorModePortHint =>
      'Öffnet und schließt nur den Port. Schneller, aber ein strenges fail2ban zählt eine Verbindung ohne Anmeldung vielleicht mit.';

  @override
  String everyMinutes(int n) {
    return '$n Min.';
  }

  @override
  String everyHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Stunden',
      one: '1 Stunde',
    );
    return '$_temp0';
  }

  @override
  String get monitorTitle => 'Überwachung';

  @override
  String get monitorClear => 'Protokoll leeren';

  @override
  String get monitorClearTitle => 'Überwachungsprotokoll leeren?';

  @override
  String get monitorClearMessage =>
      'Die Prüfungen und Ausfälle werden gelöscht. Die Überwachung läuft weiter.';

  @override
  String get monitorEmptyTitle => 'Keine Server überwacht';

  @override
  String get monitorEmpty =>
      'Schalte die Hintergrundüberwachung ein, wenn du einen Server bearbeitest. ServerDeck prüft ihn im Hintergrund und sagt dir, wenn er ausfällt.';

  @override
  String get monitorServers => 'Server';

  @override
  String get monitorIncidents => 'Ausfälle';

  @override
  String get monitorNoIncidents => 'Noch keine Ausfälle.';

  @override
  String get monitorTimingHint =>
      'Android führt Hintergrundarbeit höchstens alle 15 Minuten aus, und nur mit Netz. Energiesparmodus oder Tiefschlaf können sie verzögern; fehlen Prüfungen, nimm ServerDeck aus der Akkuoptimierung heraus.';

  @override
  String get agoNow => 'gerade eben';

  @override
  String agoMinutes(int n) {
    return 'vor $n Min.';
  }

  @override
  String agoHours(int n) {
    return 'vor $n Std.';
  }

  @override
  String get monitorWaiting => 'Noch keine Prüfung';

  @override
  String monitorSomeDown(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Server sind ausgefallen',
      one: '1 Server ist ausgefallen',
    );
    return '$_temp0';
  }

  @override
  String get monitorAllUp => 'Alle Server sind erreichbar';

  @override
  String monitorCount(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n Server überwacht',
      one: '1 Server überwacht',
    );
    return '$_temp0';
  }

  @override
  String monitorLast(String when) {
    return 'zuletzt $when';
  }

  @override
  String get monitorChecking => 'Prüfe…';

  @override
  String get monitorCheckNow => 'Jetzt prüfen';

  @override
  String get monitorChecked => 'Geprüft';

  @override
  String get monitorStateUnknown => 'noch keine Daten';

  @override
  String monitorDownFor(String d) {
    return 'ausgefallen · $d';
  }

  @override
  String get window24h => '24 Stunden';

  @override
  String get window7d => '7 Tage';

  @override
  String get window30d => '30 Tage';

  @override
  String shortMinutes(int n) {
    return '$n Min.';
  }

  @override
  String shortHours(int n) {
    return '$n Std.';
  }

  @override
  String shortDays(int n) {
    return '$n T.';
  }

  @override
  String get monitorOngoing => 'andauernd';

  @override
  String everyNMinutes(int n) {
    return 'alle $n Min.';
  }

  @override
  String everyNHours(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'alle $n Std.',
      one: 'stündlich',
    );
    return '$_temp0';
  }

  @override
  String get monitorPhoneOffline =>
      'Das Telefon ist nicht mit dem Internet verbunden, deshalb kann gerade nichts geprüft werden.';

  @override
  String get monitorForgetTitle => 'Diesen Ausfall löschen?';

  @override
  String get monitorForgetMessage =>
      'Wenn es kein echter Ausfall war (das Telefon war zum Beispiel offline), werden der Eintrag und seine fehlgeschlagenen Prüfungen gelöscht und die Verfügbarkeit neu berechnet.';

  @override
  String get monitorIncidentsHint =>
      'Lange auf einen beendeten Ausfall drücken, um ihn zu löschen.';
}
