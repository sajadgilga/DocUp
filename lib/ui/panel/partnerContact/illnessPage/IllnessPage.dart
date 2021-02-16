import 'package:Neuronio/blocs/EntityBloc.dart';
import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/blocs/SingleMedicalTestBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/TextPlan.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/models/VisitTime.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/panel/PanelAlert.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/panel/partnerContact/illnessPage/PanelTestList.dart';
import 'package:Neuronio/ui/widgets/VisitBox.dart';
import 'package:Neuronio/utils/CrossPlatformSvg.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

import 'SendTestPage.dart';

class IllnessPage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, dynamic) globalOnPush;
  final TextPlanRemainedTraffic textPlanRemainedTraffic;

  IllnessPage(
      {Key key,
      this.entity,
        this.textPlanRemainedTraffic,
      @required this.onPush,
      @required this.selectPage,
      @required this.globalOnPush})
      : super(key: key);

  @override
  _IllnessPageState createState() => _IllnessPageState();
}

class _IllnessPageState extends State<IllnessPage> {
  // List<VisitTime> times;
  SingleMedicalTestBloc _singleTestBloc = SingleMedicalTestBloc();
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  bool noronioClinicTestsAvailable = true;

  @override
  void initState() {
    _initialApiCallBack();
    // times = [];
    // times.add(VisitTime(Month.ESF, '۷', '۱۳۹۸', true));
    // times.add(VisitTime(Month.DAY, '۱۶', '۱۳۹۸', false));
    // times.add(VisitTime(Month.ABN, '۷', '۱۳۹۸', false));
    // times.add(VisitTime(Month.TIR, '۱۲', '۱۳۹۸', false));
    // times.add(VisitTime(Month.FAR, '۲۱', '۱۳۹۸', false));

    super.initState();
  }

  void _initialApiCallBack() {
    var _state = BlocProvider.of<EntityBloc>(context).state;
    if (_state.entity.isDoctor) {
      if (_state.entity.doctor.clinic == null ||
          _state.entity.doctor.clinic.id != NeuronioClinic.ClinicId) {
        noronioClinicTestsAvailable = false;
      }
    }
    if (noronioClinicTestsAvailable) {
      BlocProvider.of<MedicalTestListBloc>(context)
          .add(GetPanelMedicalTest(panelId: this.widget.entity.panel.id));
    } else {
      BlocProvider.of<MedicalTestListBloc>(context).add(EmptyMedicalTestList());
    }

    _singleTestBloc.listen((event) {
      if (event is AddTestToPatientLoaded) {
        toast(context, "تست مورد نظر با موفقیت فرستاده شد");
      } else if (event is AddTestToPatientError) {
        toast(context, "خطایی رخ داده است");
      }
    });
  }

  Widget _IllnessPage() {
    if (widget.entity.isDoctor &&
        (widget.entity.doctor.clinic == null ||
            widget.entity.doctor.clinic.id != NeuronioClinic.ClinicId)) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        alignment: Alignment.center,
        child: AutoText(
            "تست های ارسالی فقط برای دکتران کلینیک نورونیو در دسترس هستند."),
      );
    } else
      return SingleChildScrollView(
          child: Container(
        child: Column(children: <Widget>[
          PartnerInfo(
            entity: widget.entity.partnerEntity,
            onPush: widget.onPush,
            bgColor: IColors.background,
          ),
          // VisitBox(
          //   visitTimes: times,
          // ),
          BlocBuilder<MedicalTestListBloc, MedicalTestListState>(
              builder: (context, state) {
            if (state is TestsListLoaded ||
                (state is TestsListLoading && state.result != null)) {
              return PanelTestList(
                patient: widget.entity.patient,
                panelId: widget.entity.panel.id,
                globalOnPush: widget.globalOnPush,
                previousTest: getTestsWithDone(state.result, true),
                waitingTest: getTestsWithDone(state.result, false),
                listId: widget.entity.sectionId(Strings.cognitiveTests),
                uploadAvailable: widget.entity.isPatient,
                picLabel: widget.entity.isPatient
                    ? "تست های دریافتی"
                    : "تست های ارسالی",
                recentLabel: Strings.illnessInfoLastPicsLabel,
                uploadLabel: "شما ۱ تست از سوی پزشک دارید",
                asset: CrossPlatformSvg.asset(
                  "assets/cloud.svg",
                  height: 35,
                  width: 35,
                  color: IColors.themeColor,
                ),
                tapCallback: () => widget.onPush(
                    NavigatorRoutes.cognitiveTest, widget.entity.partnerEntity),
              );
            } else if (state is TestsListError) {
              return APICallError(
                () {
                  _initialApiCallBack();
                },
                tightenPage: true,
              );
            } else {
              return DocUpAPICallLoading2(
                height: MediaQuery.of(context).size.height / 2,
              );
            }
          })
        ]),
      ));
  }

  List<PanelMedicalTestItem> getTestsWithDone(
      List<PanelMedicalTestItem> tests, bool done) {
    List<PanelMedicalTestItem> res = [];
    tests.forEach((element) {
      if (element.done == done) {
        res.add(element);
      }
    });
    return res;
  }

  _addTestDialog(context) {
    SendNoronioTestDialog dialog =
        SendNoronioTestDialog(widget.entity.patient, context, _scaffoldKey);
    dialog.showSendTestDialog(() {
      BlocProvider.of<MedicalTestListBloc>(context)
          .add(GetPanelMedicalTest(panelId: this.widget.entity.panel.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButton: Visibility(
        visible: widget.entity.isDoctor && noronioClinicTestsAvailable,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _addTestDialog(context),
                    child: Icon(Icons.add),
                    backgroundColor: IColors.themeColor,
                  ),
                  AutoText("تست جدید", style: TextStyle(fontSize: 12))
                ],
              ),
            ),
          ],
        ),
      ),
      body: body(),
    );
  }

  Widget body() {
    if ((widget.entity.panel.status == 0 || widget.entity.panel.status == 1) &&
        false) {
      if (widget.entity.isPatient) {
        return Stack(children: <Widget>[
          _IllnessPage(),
          PanelAlert(
            label: Strings.requestSentLabel,
            buttonLabel: Strings.waitingForApproval,
            btnColor: IColors.disabledButton,
          )
        ]);
      } else {
        return Stack(children: <Widget>[
          _IllnessPage(),
          PanelAlert(
            label: Strings.requestSentLabelDoctorSide,
            buttonLabel: Strings.waitingForApprovalDoctorSide,
            callback: () {
              widget.onPush(
                  NavigatorRoutes.patientDialogue, widget.entity.partnerEntity);
            },
          )
        ]);
      }
    } else {
      return _IllnessPage();
    }
  }
}
