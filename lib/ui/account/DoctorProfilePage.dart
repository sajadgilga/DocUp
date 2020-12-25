import 'dart:async';

import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/ContactUsAndPolicy.dart';
import 'package:docup/ui/widgets/DoctorCreditWidget.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/MapWidget.dart';
import 'package:docup/ui/widgets/PageTopLeftIcon.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/ui/widgets/Waiting.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_tooltip/simple_tooltip.dart';

import 'EditProfileAvatarDialog.dart';
import 'EditProfileDataDialog.dart';

class DoctorProfilePage extends StatefulWidget {
  final Function(String, dynamic) onPush;

  DoctorProfilePage({Key key, @required this.onPush}) : super(key: key);

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  bool _tooltip = false;

  @override
  void initState() {
    checkDoctorBillingDescription();
    super.initState();
  }

  Future<void> checkDoctorBillingDescription(
      {bool changeTooltip = true}) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasShown = false;
    if (prefs.containsKey("doctorBillingDescription")) {
      hasShown = prefs.getBool("doctorBillingDescription");
    }
    prefs.setBool("doctorBillingDescription", true);
    if (changeTooltip) {
      _tooltip = !hasShown;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<EntityBloc, EntityState>(
      builder: (context, state) {
        if ((state is EntityLoaded || state.entity.mEntity != null) &&
            !(state is EntityError)) {
          return _widget(state);
        } else if (state is EntityError) {
          return APICallError(() {
            EntityBloc entityBloc = BlocProvider.of<EntityBloc>(context);
            entityBloc.add(EntityGet());
          });
        } else
          return Waiting();
      },
    );
  }

  _widget(EntityState state) {
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
          onTap: () {
            checkDoctorBillingDescription(changeTooltip: false);

            setState(() {
              _tooltip = true;
            });

            /// TODO
            Timer(Duration(seconds: 10), () {
              _tooltip = false;
            });
          },
          child: SimpleTooltip(
            hideOnTooltipTap: true,
            show: _tooltip,
            animationDuration: Duration(milliseconds: 460),
            tooltipDirection: TooltipDirection.down,
            backgroundColor: IColors.whiteTransparent,
            borderColor: IColors.themeColor,
            tooltipTap: () {
              checkDoctorBillingDescription();
            },
            content: AutoText(
              Strings.doctorBillingDescription,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.black87,
                fontSize: 12,
                decoration: TextDecoration.none,
              ),
            ),
            child: DoctorCreditWidget(
              credit: doctorEntity.user.credit,
              doctorEntity: doctorEntity,
              onTakeMoney: () => widget.onPush(
                  NavigatorRoutes.doctorProfileMenuPage, doctorEntity),
            ),
          ),
        ),
        ALittleVerticalSpace(),
        GestureDetector(
            onTap: () {
              EditProfileAvatarDialog dialog = EditProfileAvatarDialog(
                  context, state.entity, () {}, setState);
              dialog.showEditableAvatarDialog();
            },
            child: EditingCircularAvatar(user: doctorEntity.user)),
        ALittleVerticalSpace(),
        DoctorData(
            width: MediaQuery.of(context).size.width,
            doctorEntity: doctorEntity),
        ActionButton(
          title: "اطلاعات",
          color: IColors.themeColor,
          callBack: () {
            EditProfileDataDialog editProfileData =
                EditProfileDataDialog(context, state.entity, () {
              BlocProvider.of<EntityBloc>(context).add(EntityGet());
            });
            editProfileData.showEditableDataDialog();
          },
        ),
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
          callBack: () =>
              widget.onPush(NavigatorRoutes.visitConfig, doctorEntity),
        ),
        // suggestionsAndCriticism()
      ],
    ));
  }
}
