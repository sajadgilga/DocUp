import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/NotificationBlocV2.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/NewestNotificationResponse.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/repository/DoctorRepository.dart';
import 'package:docup/repository/PatientRepository.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/start/RoleType.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:docup/utils/Utils.dart';
import 'package:docup/utils/customPainter/DrawerPainter.dart';

//import 'package:docup/ui/home/notification/DrawerPainter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icon_shadow/icon_shadow.dart';

class NotificationPage extends StatefulWidget {
  final Function(String, dynamic) onPush;

  const NotificationPage({Key key, this.onPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  NotificationBlocV2 _notificationBloc = NotificationBlocV2();

  @override
  initState() {
    _notificationBloc.get();
    super.initState();
  }

  Widget _notificationCountCircle(int count) => Positioned(
        right: 150,
        top: 110,
        child: Container(
            alignment: Alignment.centerRight,
            child: Wrap(children: <Widget>[
              Container(
                  padding: EdgeInsets.only(left: 5, right: 5),
                  child: AutoText(replaceFarsiNumber("$count"),
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  decoration: BoxDecoration(
                      color: IColors.themeColor,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      boxShadow: [
                        BoxShadow(
                            color: IColors.themeColor,
                            offset: Offset(1, 3),
                            blurRadius: 10)
                      ])),
            ])),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IColors.background,
      body: StreamBuilder<Response<NewestNotificationResponse>>(
        stream: _notificationBloc.stream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data.status) {
              case Status.LOADING:
                return DocUpAPICallLoading2();
                break;
              case Status.COMPLETED:
                return _widget(context, snapshot.data.data);
                break;
              case Status.ERROR:
                return APICallError(
                  errorMessage: snapshot.data.error.toString(),
                  onRetryPressed: () => _notificationBloc.get(),
                );
                break;
            }
          }
          return Waiting();
        },
      ),
    );
  }

  _widget(context, NewestNotificationResponse data) => Stack(
        children: <Widget>[
          Image(
            image: AssetImage('assets/backgroundHome.png'),
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fitWidth,
          ),
          CustomPaint(
              painter: DrawerPainter(arcStart: 20),
              child: Stack(
                children: <Widget>[
                  Positioned(
                    right: 55,
                    top: 75,
                    child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.close,
                          color: Colors.grey,
                          size: 30,
                        )),
                  ),
                  Positioned(
                    right: 70,
                    top: 120,
                    child: AutoText(
                      "اعلانات",
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                  _notificationCountCircle(
                      data.newestEventsCounts + data.newestVisitsCounts),
                  _notificationsWidget(context, data),
                ],
              )),
          Container(
            width: 100,
            height: 90,
            child: Icon(
              Icons.notifications,
              size: 35,
              color: IColors.themeColor,
            ),
          ),
        ],
      );

  _notificationsWidget(buildContext, NewestNotificationResponse notifications) {
    return (notifications.newestEventsCounts +
                notifications.newestVisitsCounts) ==
            0
        ? Expanded(
            child: Positioned(
                right: MediaQuery.of(buildContext).size.width * 0.4,
                top: 180,
                child: AutoText("اعلانی موجود نیست")),
          )
        : Expanded(
            child: Positioned(
              right: MediaQuery.of(buildContext).size.width * 0.15,
              top: 180,
              child: Container(
                width: MediaQuery.of(buildContext).size.width * 0.85,
                height: MediaQuery.of(buildContext).size.height * 0.7 - 80,
                child: ListView.builder(
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: notifications.newestVisitsCounts,
                    itemBuilder: (BuildContext context, int index) =>
                        NotificationItem(
                          title: notifications.newestVisits[index]
                              .getNotificationTitle(),
                          description: notifications.newestVisits[index]
                              .getNotificationDescription(),
                          time: notifications.newestVisits[index]
                              .getNotificationTime(),
                          color: notifications.newestVisits[index]
                              .getNotificationColor(),
                          onTap: () {
                            /// TODO amir: loading is not working here check it out later
                            LoadingAlertDialog loadingAlertDialog =
                                LoadingAlertDialog(context);
                            loadingAlertDialog.showLoading();
                            getPartnerEntity(notifications.newestVisits[index])
                                .then((partner) {
                              loadingAlertDialog.disposeDialog();
                              widget.onPush(NavigatorRoutes.panel, partner);
                            });
                          },
                        )),
              ),
            ),
          );
  }

  Future<UserEntity> getPartnerEntity(NewestVisit visit) async {
    var state = BlocProvider.of<EntityBloc>(context).state;
    UserEntity uEntity;
    if (state.entity.type == RoleType.PATIENT) {
      uEntity = await DoctorRepository().getDoctor(visit.doctor);
    } else if (state.entity.type == RoleType.DOCTOR) {
      uEntity = await PatientRepository().getPatient(visit.patient);
    }
    return uEntity;
  }
}

class NotificationItem extends StatelessWidget {
  final String time;
  final String title;
  final String description;
  final String location;
  final Color color;
  final Function() onTap;

  const NotificationItem(
      {Key key,
      this.time,
      this.title,
      this.description,
      this.location,
      this.color,
      this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Material(
              color: IColors.grey,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16))),
              child: Padding(
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(right: 20.0),
                      child: AutoText(
                        time == null
                            ? "هم اکنون"
                            : replaceFarsiNumber(
                                normalizeDateAndTime(time, cutSeconds: true)),
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      textDirection: TextDirection.rtl,
                      children: <Widget>[
                        IconShadowWidget(
                            Icon(
                              Icons.brightness_1,
                              size: 16,
                              color: color ?? IColors.black,
                            ),
                            showShadow: true,
                            shadowColor: color ?? IColors.black),
                        SizedBox(width: 5),
                        AutoText(
                          title == null ? "اعلان جدید" : title,
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                              color: color ?? IColors.black, fontSize: 16),
                        ),
                        SizedBox(width: 10),
                      ],
                    ),
                    AutoText(
                      description == null ? "" : description,
                      textDirection: TextDirection.rtl,
                      style: TextStyle(color: IColors.darkGrey, fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Visibility(
                      visible: location != null,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Row(
                          children: <Widget>[
                            AutoText(
                              location != null ? location : "",
                              style: TextStyle(color: IColors.darkGrey),
                            ),
                            Icon(
                              Icons.location_on,
                              size: 16,
                              color: IColors.darkGrey,
                            )
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
