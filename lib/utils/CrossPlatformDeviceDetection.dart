import 'dart:io';

import 'package:flutter/foundation.dart';

class CrossPlatformDeviceDetection {
  static bool get isIOS {
    if (!kIsWeb && Platform.isIOS) {
      return true;
    }
    return false;
  }

  static bool get isAndroid {
    if (!kIsWeb && Platform.isAndroid) {
      return true;
    }
    return false;
  }

  static bool get isWeb {
    if (kIsWeb) {
      return true;
    }
    return false;
  }
}
