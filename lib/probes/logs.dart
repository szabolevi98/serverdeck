/// Following logs: the command for each kind of source, and how bad a line
/// looks.
library;

import '../data/models.dart';
import 'services.dart';

/// How many lines a source starts with before following.
const logBacklog = 200;

/// The command that prints the last [logBacklog] lines of [source] and then
/// keeps printing new ones until it is stopped.
String followCommand(LogSource source, {required bool root}) {
  final command = switch (source.kind) {
    LogKind.journal => 'journalctl -n $logBacklog -f --no-pager -o short-iso',
    LogKind.unit =>
      'journalctl -u ${shellQuote(source.target)} -n $logBacklog -f '
          '--no-pager -o short-iso',
    LogKind.file => 'tail -n $logBacklog -F ${shellQuote(source.target)}',
  };
  // Most logs are readable only by root or the adm group.
  return privileged(command, root: root);
}

/// The whole system journal, offered on every server without saving it.
LogSource journalSource(String serverId, String name) => LogSource(
  id: 'journal:$serverId',
  serverId: serverId,
  name: name,
  kind: LogKind.journal,
  target: '',
);

enum LineLevel { normal, warning, error }

final _error = RegExp(
  r'\b(error|err|crit|critical|fatal|emerg|emergency|alert|panic|failed|failure|segfault|exception|denied)\b|\[(error|crit|alert|emerg)\]',
  caseSensitive: false,
);
final _warning = RegExp(
  r'\b(warn|warning|deprecated|timeout|timed out|retry|retrying)\b|\[warn(ing)?\]',
  caseSensitive: false,
);

/// A guess from the words in [line]; good enough to colour it.
LineLevel levelOf(String line) {
  if (_error.hasMatch(line)) return LineLevel.error;
  if (_warning.hasMatch(line)) return LineLevel.warning;
  return LineLevel.normal;
}

final _journalLine = RegExp(
  r'^\d{4}-\d{2}-\d{2}T(\d{2}:\d{2}:\d{2})\S*\s+\S+\s+(.*)$',
);

/// A `journalctl -o short-iso` line as its time of day and the rest, without
/// the date and the host name every line repeats. Other lines come back
/// whole, with no time.
(String?, String) splitJournalLine(String line) {
  final m = _journalLine.firstMatch(line);
  return m == null ? (null, line) : (m.group(1), m.group(2)!);
}
