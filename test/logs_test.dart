import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/data/models.dart';
import 'package:serverdeck/probes/logs.dart';

void main() {
  test('each source follows with the right command', () {
    const unit = LogSource(
      id: 'a',
      serverId: 's',
      name: 'nginx',
      kind: LogKind.unit,
      target: 'nginx.service',
    );
    const file = LogSource(
      id: 'b',
      serverId: 's',
      name: 'err',
      kind: LogKind.file,
      target: "/var/log/it's.log",
    );
    expect(
      followCommand(unit, root: true),
      "journalctl -u 'nginx.service' -n 200 -f --no-pager -o short-iso",
    );
    expect(
      followCommand(file, root: false),
      r"sudo -n tail -n 200 -F '/var/log/it'\''s.log'",
    );
    expect(
      followCommand(journalSource('s', 'J'), root: true),
      'journalctl -n 200 -f --no-pager -o short-iso',
    );
  });

  test('lines are coloured by the words in them', () {
    expect(
      levelOf('[Sat Sep 27 10:00:01] [php:error] [pid 123] PHP Fatal error'),
      LineLevel.error,
    );
    expect(
      levelOf('sshd[42]: Failed password for root from 1.2.3.4'),
      LineLevel.error,
    );
    expect(levelOf('kernel: segfault at 0 ip 000055'), LineLevel.error);
    expect(
      levelOf('[warn] mod_ssl: certificate expires soon'),
      LineLevel.warning,
    );
    expect(levelOf('upstream timed out while reading'), LineLevel.warning);
    expect(levelOf('Started Daily apt download activities.'), LineLevel.normal);
    // Words that only contain an alarming one are not alarming.
    expect(
      levelOf('terrorbird started; interrupted nothing'),
      LineLevel.normal,
    );
  });

  test('journal lines lose the date and host name, others stay whole', () {
    expect(
      splitJournalLine(
        '2026-09-27T20:32:12+02:00 web-1 systemd[1]: Started cron.service.',
      ),
      ('20:32:12', 'systemd[1]: Started cron.service.'),
    );
    expect(splitJournalLine('[Sat Sep 27 10:00:01 2026] [core:error] boom'), (
      null,
      '[Sat Sep 27 10:00:01 2026] [core:error] boom',
    ));
  });
}
