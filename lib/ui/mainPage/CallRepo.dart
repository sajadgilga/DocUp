import 'package:docup/ui/panel/videoCallPage/call.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:permission_handler/permission_handler.dart';

bool isCallStarted = false;

Future<void> joinVideoCall(context, String channelName) async {
  if (isCallStarted) return;
  isCallStarted = true;
  await _handleCameraAndMic();
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => CallPage(
        channelName: channelName,
      ),
    ),
  );
}
Future<void> _handleCameraAndMic() async {
  await PermissionHandler().requestPermissions(
    [PermissionGroup.camera, PermissionGroup.microphone],
  );
}
