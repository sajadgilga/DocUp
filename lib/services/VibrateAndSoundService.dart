import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import 'package:vibration/vibration.dart';

class VibrateAndRingtoneService {

  static void playSoundAndVibrate({int miliSecDuration = 500}){
    VibrateAndRingtoneService.vibrate(miliSecDuration: miliSecDuration);
    VibrateAndRingtoneService.playNotifSound();
  }

  static void vibrate({int miliSecDuration = 500}) async {
    if (!await Vibration.hasVibrator()) return;
    if (await Vibration.hasCustomVibrationsSupport()) {
      Vibration.vibrate(duration: miliSecDuration);
    } else {
      Vibration.vibrate();
      await Future.delayed(Duration(milliseconds: miliSecDuration));
      Vibration.vibrate();
    }
  }

  static void playNotifSound(){
    FlutterRingtonePlayer.playNotification();
  }
}
