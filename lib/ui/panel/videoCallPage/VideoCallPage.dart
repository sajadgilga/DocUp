import 'package:docup/blocs/VideoCallBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/AgoraChannelEntity.dart';
import 'package:docup/models/Doctor.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/repository/VideoCallRepository.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/ui/panel/videoCallPage/call.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/utils/UiUtils.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class VideoCallPage extends StatefulWidget {
  final Entity entity;
  final Function(String, UserEntity) onPush;

  VideoCallPage({Key key, this.entity, @required this.onPush})
      : super(key: key);

  @override
  _VideoCallPageState createState() {
    return _VideoCallPageState();
  }
}

class _VideoCallPageState extends State<VideoCallPage> {
  AlertDialog _loadingDialog = getLoadingDialog();

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(10)),
          boxShadow: <BoxShadow>[BoxShadow(color: Colors.grey, blurRadius: 1)]),
      child: Column(
        children: <Widget>[
          PartnerInfo(
            entity: widget.entity,
            onPush: widget.onPush,
          ),
          _videoCallPane()
        ],
      ),
    );
  }

  _videoCallPane() => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text(
              "در صورت تایید پزشک، امکان برقراری ارتباط از طریق تماس تصویری امکان پذیر است",
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          ActionButton(
            color: IColors.themeColor,
            icon: Icon(Icons.videocam),
            title: "تماس تصویری",
            callBack: () {
              showLoadingDialog();
//              onJoin().then((value) {
//                Navigator.push(
//                  context,
//                  MaterialPageRoute(
//                    builder: (context) => CallPage(
//                      channelName: value,
//                    ),
//                  ),
//                );
//              });
            },
          )
        ],
      );

  showLoadingDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          Future.delayed(Duration(seconds: 6), () {
            Navigator.of(context).pop(true);
          });
          return _loadingDialog;
        });
  }

//  Future<String> onJoin() async {
//     await for camera and mic permissions before pushing video page
//    await _handleCameraAndMic();
//     push video page with given channel name
//
//    AgoraChannel channel =
//        await VideoCallRepository().getChannelName(widget.entity.pId);
//
//    return channel.channelName;
//  }
//
//  Future<void> _handleCameraAndMic() async {
//    await PermissionHandler().requestPermissions(
//      [PermissionGroup.camera, PermissionGroup.microphone],
//    );
//  }
}
