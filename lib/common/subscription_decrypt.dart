import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';

/// A subscription body the panel AES-encrypts is announced by the
/// `subscription-encryption: true` response header (the v2rayN convention).
const String subscriptionEncryptionHeader = 'subscription-encryption';
const String _encryptedValue = 'true';

bool isSubscriptionEncrypted(String? headerValue) {
  return headerValue?.trim().toLowerCase() == _encryptedValue;
}

/// AES-128-CBC: key is the raw MD5 of [password], the IV is the first 16
/// bytes of the base64-decoded body, the ciphertext is the rest.
Uint8List? tryDecryptSubscription(String password, String base64Data) {
  if (base64Data.isEmpty || password.isEmpty) return null;

  final passHash = md5.convert(utf8.encode(password)).toString();
  final keyBytes = Uint8List.fromList(
    List.generate(
      16,
      (i) => int.parse(passHash.substring(i * 2, i * 2 + 2), radix: 16),
    ),
  );

  final Uint8List raw;
  try {
    final normalized = base64Data
        .trim()
        .replaceAll('\n', '')
        .replaceAll('\r', '');
    raw = base64Decode(normalized);
  } catch (_) {
    return null;
  }
  if (raw.length <= 16) return null;

  final iv = IV(raw.sublist(0, 16));
  final cipher = Encrypted(Uint8List.fromList(raw.sublist(16)));
  try {
    final encrypter = Encrypter(AES(Key(keyBytes), mode: AESMode.cbc));
    final decrypted = encrypter.decryptBytes(cipher, iv: iv);
    return decrypted.isNotEmpty ? Uint8List.fromList(decrypted) : null;
  } catch (e) {
    commonPrint.log(
      'Subscription decrypt error: $e',
      logLevel: LogLevel.warning,
    );
    return null;
  }
}
