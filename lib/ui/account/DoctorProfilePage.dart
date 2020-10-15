import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DoctorCreditWidget.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DoctorProfilePage extends StatefulWidget {
  final Function(String, dynamic) onPush;

  DoctorProfilePage({Key key, @required this.onPush}) : super(key: key);

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  @override
  Widget build(BuildContext context) => BlocBuilder<EntityBloc, EntityState>(
        builder: (context, state) {
          if (state is EntityLoaded) {
            if (state.entity.mEntity != null) {
              DoctorEntity doctorEntity = state.entity.mEntity;
              return SingleChildScrollView(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  PageTopLeftIcon(
                    topLeft: Icon(
                      Icons.menu,
                      size: 25,
                    ),
                    onTap: () {
                      /// TODO
                      widget.onPush(NavigatorRoutes.doctorProfileMenuPage, doctorEntity);
                    },
                    topRightFlag: false,
                    topLeftFlag: true,
                  ),
                  MediumVerticalSpace(),
                  GestureDetector(
                      onTap: () => widget.onPush(
                          NavigatorRoutes.doctorProfileMenuPage, doctorEntity),
                      child: DoctorCreditWidget(
                        credit: doctorEntity.user.credit,
                      )),
                  ALittleVerticalSpace(),
                  PolygonAvatar(user: doctorEntity.user),
                  ALittleVerticalSpace(),
                  DoctorData(
                      width: MediaQuery.of(context).size.width,
                      doctorEntity: doctorEntity),
                  MediumVerticalSpace(),
                  MapWidget(
                    clinic: doctorEntity.clinic,
                  ),
                  ALittleVerticalSpace(),
                  ALittleVerticalSpace(),
                  ActionButton(
                    color: IColors.themeColor,
                    width: MediaQuery.of(context).size.width * (70 / 100),
                    height: 60,
                    title: "اطلاعات ویزیت مجازی و حضوری",
//                    callBack: () => showNextVersionDialog(context),
                    callBack: () => widget.onPush(
                        NavigatorRoutes.visitConfig, doctorEntity),
                  )
                ],
              ));
            } else
              return Container();
          } else
            return Container();
        },
      );
}
