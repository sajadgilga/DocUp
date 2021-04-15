import 'dart:convert';
import 'dart:math';

class CryptoService {
  static String generateRandomString({int length = 10}) {
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    Random _rnd = Random();
    return String.fromCharCodes(Iterable.generate(
        length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  }

  static String codeWithSHA256(String str) {
    print(str);
    var bytes = utf8.encode(str);
    print(utf8.decode(base64Decode(base64Encode(bytes))));
    print(base64Encode(bytes));
    return base64Encode(bytes);
  }
}
