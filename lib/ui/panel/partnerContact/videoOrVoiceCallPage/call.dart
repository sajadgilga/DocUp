import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:docup/blocs/timer/TimerBloc.dart';
import 'package:docup/blocs/timer/TimerEvent.dart';
import 'package:docup/blocs/timer/Tricker.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitResponseEntity.dart';
import 'package:docup/services/VibrateAndSoundService.dart';
import 'package:docup/ui/mainPage/NotifNavigationRepo.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/Timer.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:wakelock/wakelock.dart';

import 'utils/settings.dart';

class CallPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  final String channelName;

  /// determine if call is video call to enable video
  final bool videoCall;

  /// user PartnerProfile
  final User user;
  final VisitEntity visit;
  final Entity entity;

  /// Creates a call page with given channel name.
  const CallPage(
      {Key key,
      this.channelName,
      this.videoCall = false,
      this.user,
      this.visit,
      this.entity})
      : super(key: key);

  @override
  _CallPageState createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  TimerBloc _timerBloc = TimerBloc(ticker: Ticker());
  static final Set<int> _users = {};
  final _infoStrings = <String>[];
  bool muted = false;
  bool speaker = true;
  RtcEngine engine;
  bool postponed;

  @override
  void dispose() {
    try {
      // clear users
      _users.clear();
      // destroy sdk
      engine.leaveChannel();
      engine.destroy();
    } catch (e) {}
    try {
      _timerBloc.dispose();
    } catch (e) {}
    try {
      Wakelock.disable();
    } catch (e) {}

    NotificationNavigationRepo.isCallStarted = false;

    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  bool get visitTimerFlag {
    return widget.visit != null && widget.entity.isDoctor;
  }

  @override
  void initState() {
    _timerBloc = TimerBloc(
        ticker: Ticker(),
        duration: widget.visit.visitEndTimeDiffFromNow <= 0
            ? 0
            : widget.visit.visitEndTimeDiffFromNow);

    /// TODO set duration later just for test i set it to 60 secs
    if (visitTimerFlag) {
      Future.delayed(Duration(seconds: 6), () {
        int remainingTime = widget.visit.visitEndTimeDiffFromNow;
        if (remainingTime <= 0) {
          showOneButtonDialog(
              context, Strings.endedVisitCallAlertToCloseCall, "تایید", () {
            _onCallEnd(context);
          }, barrierDismissible: false, callCallBackAfterDialogDispose: true);
        } else {
          _timerBloc.add(Start(duration: widget.visit.visitEndTimeDiffFromNow));
          _timerBloc.listen((time) {
            if (time.duration <= 0) {
              VibrateAndRingtoneService.playSoundAndVibrate(
                  miliSecDuration: 600);
              _onCallEnd(context);
            }
            if (postponed == null && time.duration <= 120) {
              postponed = false;
              VibrateAndRingtoneService.playSoundAndVibrate(
                  miliSecDuration: 400);
              showTwoButtonDialog(
                  context, Strings.doctorWarningVisitEnding, "تایید", "ادامه",
                  () {
                _timerBloc.add(ExtendTime(duration: 120));
                postponed = true;
              }, () {
                postponed = false;
              }, barrierDismissible: false);
            }
          });
        }
      });
    }

    // initialize agora sdk
    if(widget.visit.visitEndTimeDiffFromNow >=0){
      initialize();
    }
    super.initState();
  }

  Future<void> initialize() async {
    if (APP_ID.isEmpty) {
      setState(() {
        _infoStrings.add(
          'APP_ID missing, please provide your APP_ID in settings.dart',
        );
        _infoStrings.add('Agora Engine is not starting');
      });
      return;
    }
    print("inititlizing Agora RTC engine ...");
    this.engine = await RtcEngine.create(APP_ID);
    if (widget.videoCall) {
      await engine.enableVideo();
    }
    engine.setEnableSpeakerphone(true);
    _addAgoraEventHandlers();
    await engine.enableWebSdkInteroperability(true);
    await engine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await engine.joinChannel(null, widget.channelName, null, 0);

    print("Agora RTC engine inititlized!");
    setState(() {});
    try {
      /// for preventing screen off
      await Wakelock.enable();
    } catch (e) {}
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    engine.setEventHandler(RtcEngineEventHandler(
      error: (dynamic code) {
        setState(() {
          final info = 'onError: $code';
          _infoStrings.add(info);
        });
      },
      joinChannelSuccess: (
        String channel,
        int uid,
        int elapsed,
      ) {
        setState(() {
          final info = 'onJoinChannel: $channel, uid: $uid';
          _infoStrings.add(info);
        });
      },
      leaveChannel: (stat) {
        /// TODO check it later
        setState(() {
          _infoStrings.add('onLeaveChannel');
          _users.clear();
        });
      },
      userJoined: (int uid, int elapsed) {
        setState(() {
          final info = 'userJoined: $uid';
          _infoStrings.add(info);
          _users.add(uid);
          VibrateAndRingtoneService.playSoundAndVibrate(miliSecDuration: 200);
        });
      },
      userOffline: (int uid, UserOfflineReason reason) {
        setState(() {
          final info = 'userOffline: $uid';
          _infoStrings.add(info);
          _users.remove(uid);
          VibrateAndRingtoneService.playSoundAndVibrate(miliSecDuration: 200);
        });
      },
      firstRemoteVideoFrame: (
        int uid,
        int width,
        int height,
        int elapsed,
      ) {
        setState(() {
          final info = 'firstRemoteVideo: $uid ${width}x $height';
          _infoStrings.add(info);
        });
      },
    ));
  }

  Widget partnerInfoWidget({double opacity}) {
    return Stack(alignment: Alignment.center, children: [
      _users.length > 0
          ? SizedBox()
          : SpinKitRipple(
              color: IColors.darkGrey,
              size: 200,
            ),
      Opacity(
        opacity: opacity ?? (_users.length > 0 ? 1 : 0.4),
        child: Column(
          children: [
            PolygonAvatar(user: widget.user),
            AutoText(
              widget.user?.fullName,
              color: IColors.darkGrey,
              fontWeight: FontWeight.bold,
            )
          ],
        ),
      ),
    ]);
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<Widget> list = [RtcLocalView.SurfaceView()];
    _users.forEach((element) {
      list.add(RtcRemoteView.SurfaceView(uid: element));
    });
    return list;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    return Expanded(child: Container(child: view));
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  /// Video layout wrapper
  Widget otherPeopleViews(List<Widget> views) {
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[_videoView(views[0])],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
        return Container();
    }
  }

  Widget _viewRows() {
    if (widget.videoCall) {
      final views = _getRenderViews();
      if (views.length == 1) {
        return Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
                child: Column(
              children: <Widget>[_videoView(views[0])],
            )),
            Container(
                alignment: Alignment.center,
                height: 300,
                margin: EdgeInsets.only(top: 50),
                child: Padding(
                    padding: EdgeInsets.all(10),
                    child: partnerInfoWidget(opacity: 0.9)))
          ],
        );
      } else {
        return Stack(
          children: [
            otherPeopleViews(views.sublist(1)),
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: MediaQuery.of(context).size.width / 3,
                height: MediaQuery.of(context).size.height / 4,
                margin: EdgeInsets.all(8),
                child: views[0],
              ),
            )
          ],
        );
      }
    } else {
      /// voice call
      return Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        color: Colors.white,
        alignment: Alignment.topCenter,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.5,
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AutoText(
                "تماس صوتی",
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: IColors.darkGrey,
              ),
              partnerInfoWidget()
            ],
          ),
        ),
      );
    }
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          !widget.videoCall
              ? RawMaterialButton(
                  onPressed: _onSwitchSpeaker,
                  child: Icon(
                    Icons.speaker_phone,
                    color: speaker ? Colors.blueAccent : Colors.grey,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
              : RawMaterialButton(
                  onPressed: _onSwitchCamera,
                  child: Icon(
                    Icons.switch_camera,
                    color: Colors.blueAccent,
                    size: 20.0,
                  ),
                  shape: CircleBorder(),
                  elevation: 2.0,
                  fillColor: Colors.white,
                  padding: const EdgeInsets.all(12.0),
                )
        ],
      ),
    );
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: AutoText(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
    NotificationNavigationRepo.isCallStarted = false;
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    engine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    engine.switchCamera();
  }

  void _onSwitchSpeaker() async {
    speaker = !speaker;
    await engine.setEnableSpeakerphone(speaker);

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      floatingActionButtonLocation: FloatingActionButtonLocation.startTop,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Visibility(
          visible: visitTimerFlag,
          child: FloatingActionButton.extended(
            onPressed: () {},
            backgroundColor: IColors.whiteTransparent,
            label: BlocProvider(
                create: (context) => _timerBloc,
                child: Timer(
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                )),
          ),
        ),
      ),
      body: Center(
        child: Stack(
          children: <Widget>[
            _viewRows(),
            // _panel(),
            _toolbar(),
          ],
        ),
      ),
    );
  }
}
