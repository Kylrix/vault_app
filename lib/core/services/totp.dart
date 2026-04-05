import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

class TotpService {
  String generate(String secret, {DateTime? at}) {
    final time = at ?? DateTime.now().toUtc();
    final counter = time.millisecondsSinceEpoch ~/ 30000;
    final key = _base32Decode(secret);
    final input = ByteData(8)..setInt64(0, counter, Endian.big);
    final hmac = Hmac(sha1, key);
    final digest = hmac.convert(input.buffer.asUint8List()).bytes;
    final offset = digest.last & 0x0f;
    final code = ((digest[offset] & 0x7f) << 24) |
        ((digest[offset + 1] & 0xff) << 16) |
        ((digest[offset + 2] & 0xff) << 8) |
        (digest[offset + 3] & 0xff);
    return (code % 1000000).toString().padLeft(6, '0');
  }

  int secondsRemaining({DateTime? at}) {
    final time = at ?? DateTime.now().toUtc();
    return 30 - (time.second % 30);
  }

  List<int> _base32Decode(String input) {
    const alphabet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567';
    final clean = input.replaceAll('=', '').replaceAll(' ', '').toUpperCase();
    var bits = 0;
    var value = 0;
    final output = <int>[];
    for (final rune in clean.runes) {
      final index = alphabet.indexOf(String.fromCharCode(rune));
      if (index < 0) continue;
      value = (value << 5) | index;
      bits += 5;
      if (bits >= 8) {
        bits -= 8;
        output.add((value >> bits) & 0xff);
      }
    }
    return output;
  }
}
