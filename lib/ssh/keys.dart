import 'dart:convert';
import 'dart:typed_data';

import 'package:dartssh2/dartssh2.dart';
import 'package:pinenacl/digests.dart';
import 'package:pinenacl/ed25519.dart' as ed25519;

/// A key pair ready to be stored: the private half as an unencrypted PEM (it
/// goes into secure storage, which is encrypted on its own), the public half
/// as the `authorized_keys` line.
class KeyMaterial {
  const KeyMaterial({
    required this.type,
    required this.publicKey,
    required this.fingerprint,
    required this.privatePem,
  });

  final String type;
  final String publicKey;
  final String fingerprint;
  final String privatePem;
}

/// Why a pasted private key was not taken.
enum KeyImportProblem { notAKey, needsPassphrase, wrongPassphrase, unsupported }

class KeyImportException implements Exception {
  const KeyImportException(this.problem);
  final KeyImportProblem problem;

  @override
  String toString() => 'KeyImportException(${problem.name})';
}

/// `SHA256:<base64 without padding>`, the way `ssh-keygen -l` prints it.
String fingerprintOf(Uint8List publicKeyBlob) =>
    'SHA256:${base64.encode(Hash.sha256(publicKeyBlob)).replaceAll('=', '')}';

/// A fresh Ed25519 key pair. [comment] ends up at the end of the public key
/// line, where it tells the server's owner whose key it is.
KeyMaterial generateEd25519(String comment) {
  final signing = ed25519.SigningKey.generate();
  final pair = OpenSSHEd25519KeyPair(
    Uint8List.fromList(signing.verifyKey.asTypedList),
    Uint8List.fromList(signing.asTypedList),
    comment,
  );
  return _material(pair, comment);
}

/// Reads a pasted private key: OpenSSH, PKCS#1 RSA or SEC1 EC, encrypted or
/// not. An encrypted one is decrypted here and kept decrypted.
KeyMaterial importPrivateKey(
  String pem, {
  String? passphrase,
  String comment = '',
}) {
  final text = pem.trim();
  final bool encrypted;
  try {
    encrypted = SSHKeyPair.isEncryptedPem(text);
  } on UnsupportedError {
    throw const KeyImportException(KeyImportProblem.unsupported);
  } catch (_) {
    throw const KeyImportException(KeyImportProblem.notAKey);
  }
  if (encrypted && (passphrase == null || passphrase.isEmpty)) {
    throw const KeyImportException(KeyImportProblem.needsPassphrase);
  }

  final List<SSHKeyPair> pairs;
  try {
    pairs = SSHKeyPair.fromPem(text, encrypted ? passphrase : null);
  } on SSHKeyDecryptError {
    throw const KeyImportException(KeyImportProblem.wrongPassphrase);
  } on UnsupportedError {
    throw const KeyImportException(KeyImportProblem.unsupported);
  } on ArgumentError {
    // The bcrypt KDF reports a wrong passphrase as a bad check value.
    throw KeyImportException(
      encrypted ? KeyImportProblem.wrongPassphrase : KeyImportProblem.notAKey,
    );
  } catch (_) {
    throw KeyImportException(
      encrypted ? KeyImportProblem.wrongPassphrase : KeyImportProblem.notAKey,
    );
  }
  if (pairs.isEmpty) throw const KeyImportException(KeyImportProblem.notAKey);
  final pair = pairs.first;
  return _material(pair, comment.isNotEmpty ? comment : (pair.comment ?? ''));
}

/// Turns stored PEM text back into something that can sign.
SSHKeyPair loadKeyPair(String privatePem) =>
    SSHKeyPair.fromPem(privatePem).first;

KeyMaterial _material(SSHKeyPair pair, String comment) {
  final blob = pair.toPublicKey().encode();
  final line = [
    pair.name,
    base64.encode(blob),
    if (comment.trim().isNotEmpty) comment.trim(),
  ].join(' ');
  return KeyMaterial(
    type: pair.name,
    publicKey: line,
    fingerprint: fingerprintOf(blob),
    privatePem: pair.toPem(),
  );
}
