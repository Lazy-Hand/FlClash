import 'dart:convert';

import 'package:fl_clash/common/subscription_decrypt.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isSubscriptionEncrypted', () {
    test('only the true marker counts', () {
      expect(isSubscriptionEncrypted('true'), isTrue);
      expect(isSubscriptionEncrypted(' TRUE '), isTrue);
      expect(isSubscriptionEncrypted('false'), isFalse);
      expect(isSubscriptionEncrypted('age'), isFalse);
      expect(isSubscriptionEncrypted(''), isFalse);
      expect(isSubscriptionEncrypted(null), isFalse);
    });
  });

  group('tryDecryptSubscription', () {
    // openssl enc -aes-128-cbc -K md5("test-password") \
    //   -iv 00112233445566778899aabbccddeeff over the yaml below
    const encrypted =
        'ABEiM0RVZneImaq7zN3u/05jG3v3/eAwS7CjDry74nIlxpwb2R+iCDIt6eN/NkVR'
        '8twIRD1xeGylKSXpgScRH4u9blL7dHwqLtBtCnSX3Og/iC9v9VeEwYEojgvIwPwt';
    const yaml =
        'mixed-port: 7890\nallow-lan: false\nmode: rule\nproxies:\n'
        '  - name: test\n';

    test('decrypts the v2rayN layout', () {
      final decrypted = tryDecryptSubscription('test-password', encrypted);
      expect(utf8.decode(decrypted!), yaml);
    });

    test('tolerates whitespace in the base64 body', () {
      final wrapped =
          '${encrypted.substring(0, 40)}\n'
          '${encrypted.substring(40)}\r\n';
      final decrypted = tryDecryptSubscription('test-password', wrapped);
      expect(utf8.decode(decrypted!), yaml);
    });

    test('a wrong password and non-base64 input both return null', () {
      expect(tryDecryptSubscription('wrong', encrypted), isNull);
      expect(tryDecryptSubscription('test-password', '!!!'), isNull);
      expect(tryDecryptSubscription('test-password', ''), isNull);
      expect(tryDecryptSubscription('', encrypted), isNull);
    });
  });
}
