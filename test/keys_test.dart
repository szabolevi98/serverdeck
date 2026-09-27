import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:serverdeck/ssh/keys.dart';

String fixture(String name) => File('test/fixtures/$name').readAsStringSync();

void main() {
  group('generateEd25519', () {
    test('makes a key that loads back and signs', () {
      final key = generateEd25519('me@phone');
      expect(key.type, 'ssh-ed25519');
      expect(key.publicKey, startsWith('ssh-ed25519 AAAAC3NzaC1lZDI1NTE5'));
      expect(key.publicKey, endsWith(' me@phone'));
      expect(key.fingerprint, startsWith('SHA256:'));
      expect(key.fingerprint, isNot(contains('=')));

      final pair = loadKeyPair(key.privatePem);
      expect(pair.name, 'ssh-ed25519');
      expect(pair.sign(Uint8List.fromList([1, 2, 3])).encode(), isNotEmpty);
    });

    test('never makes the same key twice', () {
      expect(
        generateEd25519('').fingerprint,
        isNot(generateEd25519('').fingerprint),
      );
    });
  });

  group('importPrivateKey', () {
    // Fingerprints as `ssh-keygen -lf` printed them for the fixtures.
    test('reads an encrypted OpenSSH Ed25519 key', () {
      final key = importPrivateKey(
        fixture('enc_ed25519'),
        passphrase: 'titok123',
      );
      expect(key.type, 'ssh-ed25519');
      expect(
        key.fingerprint,
        'SHA256:JvfLqHbF+Rfu6hFt9mBkaGrM0d+4NOQs+ItsfwXn72Q',
      );
      // Kept decrypted: it loads with no passphrase.
      expect(loadKeyPair(key.privatePem).name, 'ssh-ed25519');
    });

    test('reads a PKCS#1 RSA key', () {
      final key = importPrivateKey(fixture('rsa_pem'));
      expect(key.type, 'ssh-rsa');
      expect(
        key.fingerprint,
        'SHA256:1nMzejRteoYPiaMjHQhxkjLhrIHs3I49PkwWH/cuYqg',
      );
    });

    test('reads an OpenSSH ECDSA key', () {
      final key = importPrivateKey(fixture('ec_openssh'));
      expect(key.type, 'ecdsa-sha2-nistp256');
      expect(
        key.fingerprint,
        'SHA256:IZui7CG2OcxMcE4wB6qfkHvJnjalw4rBflt96yI/uYQ',
      );
    });

    KeyImportProblem problem(String pem, {String? passphrase}) {
      try {
        importPrivateKey(pem, passphrase: passphrase);
      } on KeyImportException catch (e) {
        return e.problem;
      }
      fail('accepted');
    }

    test('says why a key is refused', () {
      expect(problem(fixture('enc_ed25519')), KeyImportProblem.needsPassphrase);
      expect(
        problem(fixture('enc_ed25519'), passphrase: 'rossz'),
        KeyImportProblem.wrongPassphrase,
      );
      expect(problem('ssh-ed25519 AAAA... me@host'), KeyImportProblem.notAKey);
      expect(problem(''), KeyImportProblem.notAKey);
      expect(
        problem(
          '-----BEGIN DSA PRIVATE KEY-----\nAAAA\n-----END DSA PRIVATE KEY-----',
        ),
        KeyImportProblem.unsupported,
      );
    });
  });
}
