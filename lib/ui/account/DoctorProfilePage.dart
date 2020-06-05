import 'dart:async';
import 'dart:typed_data';

import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DoctorCreditWidget.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/blocs/CreditBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart' show PlatformException;

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
                  DocUpHeader(),
                  MediumVerticalSpace(),
                  GestureDetector(
                      onTap: () => widget.onPush(
                          NavigatorRoutes.profileMenuPage, doctorEntity),
                      child: DoctorCreditWidget(
                        credit: doctorEntity.user.credit,
                      )),
                  Avatar(user: doctorEntity.user),
                  ALittleVerticalSpace(),
                  DoctorData(
                      width: MediaQuery.of(context).size.width,
                      doctorEntity: doctorEntity),
                  MediumVerticalSpace(),
                  MapWidget(
                    latitude: doctorEntity.clinic.latitude,
                    longitude: doctorEntity.clinic.longitude,
                  ),
                  ALittleVerticalSpace(),
                  ActionButton(
                    color: IColors.themeColor,
                    title: "اطلاعات ویزیت مجازی و حضوری",
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
