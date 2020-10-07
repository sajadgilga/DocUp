import 'package:docup/constants/assets.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientNoronioService extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final Function(String, dynamic) globalOnPush;

  PatientNoronioService({Key key, @required this.onPush, @required this.globalOnPush})
      : super(key: key);

  @override
  _PatientNoronioServiceState createState() => _PatientNoronioServiceState();
}

class _PatientNoronioServiceState extends State<PatientNoronioService> {
  @override
  Widget build(BuildContext context) => SingleChildScrollView(
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          DocUpHeader(title: "نورونیو"),
          ALittleVerticalSpace(),
          DocUpSubHeader(
            title: "اولین کلینیک مجازی در حوزه شناختی",
          ),
          ALittleVerticalSpace(),
          _services()
        ],
      ));

  Widget _services() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SquareBoxNoronioClinicService(Assets.noronioServiceDoctorList,
                    () {
                  widget.onPush(NavigatorRoutes.partnerSearchView, null);
                }, "مشاهده پزشکان"),
                SquareBoxNoronioClinicService(Assets.noronioServiceBrainTest,
                    () {
                  widget.globalOnPush(NavigatorRoutes.cognitiveTest, null);
                }, "تست رایگان آلزایمر")
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SquareBoxNoronioClinicService(Assets.noronioServiceGame, () {
                  // TODO
                  toast(context, "در آینده آماده می شود");
                }, "بازی های شناختی", opacity: 0.5),
                SquareBoxNoronioClinicService(null, null, null,
                    bgColor: Color.fromARGB(0, 0, 0, 0))
              ],
            )
          ],
        ),
      ),
    );
  }
}
