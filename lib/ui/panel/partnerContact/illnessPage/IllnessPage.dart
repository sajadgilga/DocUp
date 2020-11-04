import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/blocs/PictureBloc.dart';
import 'package:docup/blocs/SingleMedicalTestBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/models/VisitTime.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/PanelAlert.dart';
import 'package:docup/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:docup/ui/widgets/PanelTestList.dart';
import 'package:docup/ui/widgets/VisitBox.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class IllnessPage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, dynamic) globalOnPush;

  IllnessPage(
      {Key key,
      this.entity,
      @required this.onPush,
      @required this.selectPage,
      @required this.globalOnPush})
      : super(key: key);

  @override
  _IllnessPageState createState() => _IllnessPageState();
}

class _IllnessPageState extends State<IllnessPage> {
  final PictureBloc _pictureBloc = PictureBloc();
  List<VisitTime> times;
  SingleMedicalTestBloc _singleTestBloc = SingleMedicalTestBloc();

  @override
  void initState() {
    var _medicalTestListBloc = BlocProvider.of<MedicalTestListBloc>(context);
    _medicalTestListBloc
        .add(GetPanelMedicalTest(panelId: this.widget.entity.panel.id));
    _singleTestBloc.listen((event) {
      if (event is AddTestToPatientLoaded) {
        toast(context, "تست مورد نظر با موفقیت فرستاده شد");
      } else if (event is AddTestToPatientError) {
        toast(context, "خطایی رخ داده است");
      }
    });
    times = [];
    times.add(VisitTime(Month.ESF, '۷', '۱۳۹۸', true));
    times.add(VisitTime(Month.DAY, '۱۶', '۱۳۹۸', false));
    times.add(VisitTime(Month.ABN, '۷', '۱۳۹۸', false));
    times.add(VisitTime(Month.TIR, '۱۲', '۱۳۹۸', false));
    times.add(VisitTime(Month.FAR, '۲۱', '۱۳۹۸', false));

    _pictureBloc.add(PictureListGet(
        listId: widget.entity.sectionId(Strings.cognitiveTests)));
    super.initState();
  }

  Widget _IllnessPage(times) {
    if (widget.entity.isDoctor &&
        (widget.entity.doctor.clinic == null ||
            widget.entity.doctor.clinic.id != NoronioClinic.ClinicId)) {
      return Container(
        padding: EdgeInsets.symmetric(vertical: 50,horizontal: 20),
        alignment: Alignment.center,
        child: AutoText(
            "تست های ارسالی فقط برای دکتران کلینیک نورونیو در دسترس هستند."),
      );
    } else
      return MultiBlocProvider(
          providers: [
            BlocProvider<PictureBloc>.value(
              value: _pictureBloc,
            ),
          ],
          child: SingleChildScrollView(
              child: Container(
            child: Column(children: <Widget>[
              PartnerInfo(
                entity: widget.entity,
                onPush: widget.onPush,
                bgColor: IColors.background,
              ),
              VisitBox(
                visitTimes: times,
              ),
              BlocBuilder<MedicalTestListBloc, MedicalTestListState>(
                  builder: (context, state) {
                if (state is TestsListLoaded ||
                    (state is TestsListLoading && state.result != null)) {
                  return PanelTestList(
                    patient: widget.entity.patient,
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
                    asset: SvgPicture.asset(
                      "assets/cloud.svg",
                      height: 35,
                      width: 35,
                      color: IColors.themeColor,
                    ),
                    tapCallback: () => widget.onPush(
                        NavigatorRoutes.cognitiveTest,
                        widget.entity.partnerEntity),
                  );
                } else if (state is TestsListError) {
                  return APICallError(
                    tightenPage: true,
                  );
                } else {
                  return DocUpAPICallLoading2(
                    height: MediaQuery.of(context).size.height / 2,
                  );
                }
              })
            ]),
          )));
  }

  List<MedicalTestItem> getTestsWithDone(
      List<MedicalTestItem> tests, bool done) {
    List<MedicalTestItem> res = [];
    tests.forEach((element) {
      if (element.done == done) {
        res.add(element);
      }
    });
    return res;
  }

  _addTest(context) {
    // final tests = ["تست حافظه", "GDS تست ", "تست غربال گری"];
    // showListDialog(context, tests, "فرستادن برای سلامت‌جو", (selectedIndex) {
    //   _bloc.add(AddTestToPatient(
    //       testId: selectedIndex, patientId: entity.partnerEntity.id));
    // });
    widget.selectPage(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Visibility(
        visible: widget.entity.isDoctor,
        child: Row(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  FloatingActionButton(
                    mini: true,
                    onPressed: () => _addTest(context),
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
      body: body(times),
    );
  }

  Widget body(times) {
    if (widget.entity.panel.status == 0 ||
        widget.entity.panel.status == 1) if (widget.entity.isPatient) {
      return Stack(children: <Widget>[
        _IllnessPage(times),
        PanelAlert(
          label: Strings.requestSentLabel,
          buttonLabel: Strings.waitingForApproval,
          btnColor: IColors.disabledButton,
        )
      ]);
    } else {
      return Stack(children: <Widget>[
        _IllnessPage(times),
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
    else {
      return _IllnessPage(times);
    }
  }
}
