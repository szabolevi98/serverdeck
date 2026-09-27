import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/ssh/reach.dart';

void main() {
  test('describeBanner keeps the software and the distribution', () {
    expect(
      describeBanner('SSH-2.0-OpenSSH_9.6p1 Ubuntu-3ubuntu13.5'),
      'OpenSSH 9.6p1 Ubuntu',
    );
    expect(
      describeBanner('SSH-2.0-OpenSSH_9.2p1 Debian-2+deb12u3'),
      'OpenSSH 9.2p1 Debian',
    );
    expect(describeBanner('SSH-2.0-OpenSSH_8.7'), 'OpenSSH 8.7');
    expect(describeBanner('SSH-2.0-dropbear_2022.83'), 'dropbear 2022.83');
    expect(describeBanner('HTTP/1.1 400 Bad Request'), isNull);
    expect(describeBanner(null), isNull);
  });
}
