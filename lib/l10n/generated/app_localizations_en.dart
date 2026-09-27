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

  @override
  String get sessionOnline => 'online';

  @override
  String get sessionConnecting => 'connecting';

  @override
  String get sessionReconnect => 'Reconnect';

  @override
  String get sessionConnectingTo => 'Connecting…';

  @override
  String get problemUnreachableTitle => 'Server unreachable';

  @override
  String problemUnreachable(String host, int port) {
    return 'Couldn\'t open a connection to $host on port $port. Check the address, the port and the phone\'s connection.';
  }

  @override
  String get problemTimeoutTitle => 'No answer in time';

  @override
  String get problemTimeout =>
      'The server didn\'t answer within 12 seconds. It may be overloaded, or a firewall is dropping the connection.';

  @override
  String get problemAuthTitle => 'Sign-in failed';

  @override
  String problemAuthKey(String user) {
    return 'The server didn\'t accept the key for $user. Put the key\'s public half into ~/.ssh/authorized_keys on the server.';
  }

  @override
  String problemAuthPassword(String user) {
    return 'The server didn\'t accept the password for $user.';
  }

  @override
  String get problemHostKeyChangedTitle => 'The server\'s key changed';

  @override
  String get problemHostKeyChanged =>
      'The server showed a different identity key from the one you accepted before. That can be a reinstall, or someone in between. ServerDeck didn\'t connect.';

  @override
  String get problemHostKeyRefusedTitle => 'Key refused';

  @override
  String get problemHostKeyRefused =>
      'You didn\'t accept the server\'s key, so ServerDeck didn\'t sign in.';

  @override
  String get problemMissingTitle => 'No sign-in details';

  @override
  String get problemMissing =>
      'This server has no key or password set. Edit the server and add one.';

  @override
  String get problemDisconnectedTitle => 'Connection lost';

  @override
  String get problemDisconnected =>
      'The connection dropped: a network change, a server restart, or the phone went to sleep.';

  @override
  String get problemOtherTitle => 'Couldn\'t connect';

  @override
  String get hostKeyNewTitle => 'New server';

  @override
  String hostKeyNew(String host) {
    return 'This is the first time you connect to $host. This is the server\'s identity key:';
  }

  @override
  String get hostKeyCheck =>
      'To be sure, this command on the server prints the same fingerprint:';

  @override
  String get hostKeyAccept => 'Accept';

  @override
  String get hostKeyReject => 'Reject';

  @override
  String get hostKeyKnown => 'Accepted';

  @override
  String get hostKeyNow => 'Now';

  @override
  String get hostKeyForget => 'Forget the old key';

  @override
  String get hostKeyForgetTitle => 'Forget the old key?';

  @override
  String get hostKeyForgetMessage =>
      'Only do this if you know why the key changed, for example because you reinstalled the server. ServerDeck will then ask about the new key.';

  @override
  String get statsFailedTitle => 'Couldn\'t read the server';

  @override
  String get statsFailed =>
      'The server\'s answer made no sense. Stats need Linux (/proc).';

  @override
  String get statsStale =>
      'The last refresh failed. The figures above are older.';

  @override
  String get statCpu => 'CPU';

  @override
  String get statMemory => 'Memory';

  @override
  String get statDisk => 'Disk';

  @override
  String statCores(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cores',
      one: '1 core',
    );
    return '$_temp0';
  }

  @override
  String get statHistory => 'Last 3 minutes';

  @override
  String get statHistoryHint =>
      'Refreshes every 3 seconds while this screen is open.';

  @override
  String get statNetIn => 'In';

  @override
  String get statNetOut => 'Out';

  @override
  String get statLoad => 'Load';

  @override
  String get statLoad1 => '1 min';

  @override
  String get statLoad5 => '5 min';

  @override
  String get statLoad15 => '15 min';

  @override
  String get statDisks => 'Disks';

  @override
  String get statSwap => 'Swap';

  @override
  String get statUptime => 'Up';

  @override
  String uptimeDays(int days, int hours) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: '$days days',
      one: '1 day',
    );
    return '$_temp0, $hours h';
  }

  @override
  String uptimeHours(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get tabOverview => 'Overview';

  @override
  String get tabServices => 'Services';

  @override
  String get servicesFailedTitle => 'Couldn\'t list services';

  @override
  String get servicesSearch => 'Search by name or description';

  @override
  String servicesRunning(int count) {
    return 'Running · $count';
  }

  @override
  String servicesFailed(int count) {
    return 'Failed · $count';
  }

  @override
  String servicesAll(int count) {
    return 'All · $count';
  }

  @override
  String get servicesNone => 'Nothing matches.';

  @override
  String get servicesNoneFailed => 'No failed services.';

  @override
  String get containersNone => 'No containers.';

  @override
  String get stateRunning => 'running';

  @override
  String get stateExited => 'exited';

  @override
  String get stateFailed => 'failed';

  @override
  String get stateActivating => 'starting';

  @override
  String get stateInactive => 'stopped';

  @override
  String get stateUnhealthy => 'unhealthy';

  @override
  String get statePaused => 'paused';

  @override
  String get stateRestarting => 'restarting';

  @override
  String get stateExitedContainer => 'exited';

  @override
  String get stateCreated => 'created';

  @override
  String get actionRestart => 'Restart';

  @override
  String get actionReload => 'Reload';

  @override
  String get actionStop => 'Stop';

  @override
  String get actionStart => 'Start';

  @override
  String actionConfirmTitle(String action, String subject) {
    return '$action $subject?';
  }

  @override
  String actionConfirmMessage(String command) {
    return 'This runs on the server:\n$command';
  }

  @override
  String actionDone(String action, String subject) {
    return '$action done: $subject';
  }

  @override
  String actionFailed(int code, String reason) {
    return 'It didn\'t work (exit code $code). $reason';
  }

  @override
  String get actionNeedsSudo =>
      'This needs admin rights. Sign in as root, or allow sudo without a password for this command.';

  @override
  String get tabLogs => 'Logs';

  @override
  String get logsJournal => 'System journal';

  @override
  String get logsAdd => 'Source';

  @override
  String get logsAddTitle => 'New log source';

  @override
  String get logsKindUnit => 'Service';

  @override
  String get logsKindFile => 'File';

  @override
  String get logsUnitLabel => 'Service name';

  @override
  String get logsFileLabel => 'File path';

  @override
  String get logsFilter => 'Filter';

  @override
  String get logsErrorsOnly => 'Errors only';

  @override
  String get logsPause => 'Pause';

  @override
  String get logsResume => 'Resume';

  @override
  String get logsClear => 'Clear the screen';

  @override
  String logsNewLines(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new lines',
      one: '1 new line',
    );
    return '$_temp0';
  }

  @override
  String logsEnded(int code) {
    return 'Following the log stopped (exit code $code).';
  }

  @override
  String logsDeleteTitle(String name) {
    return 'Delete $name?';
  }

  @override
  String get logsDeleteMessage =>
      'Only the saved source goes, not the log on the server.';

  @override
  String get tabCommands => 'Commands';

  @override
  String get commandAdd => 'New command';

  @override
  String get commandEdit => 'Edit command';

  @override
  String get commandQuick => 'One-off command…';

  @override
  String get commandRun => 'Run';

  @override
  String commandRunTitle(String name) {
    return 'Run $name?';
  }

  @override
  String get commandSaved => 'Saved commands';

  @override
  String get commandTemplates => 'To start with';

  @override
  String get commandTemplatesHint =>
      'Tap one to add it to your saved commands. They only read.';

  @override
  String get commandLabel => 'Command';

  @override
  String get commandEverywhere => 'On every server';

  @override
  String get commandEverywhereHint => 'Shows up for all your servers';

  @override
  String get commandConfirm => 'Ask before running';

  @override
  String get commandCopy => 'Copy output';

  @override
  String get commandCopied => 'Output copied';

  @override
  String get commandError => 'error';

  @override
  String get commandStopped => 'stopped';

  @override
  String commandExit(int code) {
    return 'exit $code';
  }

  @override
  String get commandRunning => 'running';

  @override
  String get commandNoOutput => 'No output.';

  @override
  String get tplDisk => 'Disk usage';

  @override
  String get tplFolders => 'Biggest folders';

  @override
  String get tplUpdates => 'Pending updates';

  @override
  String get tplWho => 'Who is logged in';

  @override
  String get tplApache => 'Apache config test';

  @override
  String get tplNginx => 'Nginx config test';

  @override
  String get tplTop => 'Top CPU';

  @override
  String get tplPorts => 'Listening ports';

  @override
  String get tabTerminal => 'Terminal';

  @override
  String get terminalClosed => '[shell closed]';

  @override
  String get terminalReopen => 'New shell';
}
