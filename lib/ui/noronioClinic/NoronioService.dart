import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class NoronioServicePage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, dynamic) globalOnPush;

  NoronioServicePage(
      {Key key,
      @required this.onPush,
      @required this.selectPage,
      @required this.globalOnPush})
      : super(key: key);

  @override
  _NoronioServicePageState createState() => _NoronioServicePageState();
}

class _NoronioServicePageState extends State<NoronioServicePage> {
  List<NoronioServiceItem> convertToNoronioServiceList(
      List<MedicalTestItem> tests) {
    List<NoronioServiceItem> services = [];

    NoronioServiceItem doctorList = NoronioServiceItem(
        "مشاهده متخصصان",
        Assets.noronioServiceDoctorList,
        null,
        NoronioClinicServiceType.DoctorsList, () {
      widget.onPush(NavigatorRoutes.partnerSearchView, NeuronioClinic.ClinicId);
    }, true);
    services.insert(0, doctorList);

    tests.forEach((element) {
      NoronioServiceItem cognitiveTest = NoronioServiceItem(
          element.name,
          Assets.noronioServiceBrainTest,
          element.imageURL,
          NoronioClinicServiceType.MultipleChoiceTest, () {
        if (element.isGoogleDocTest) {
          launch(element.testLink);
        } else if (element.isInAppTest) {
          MedicalTestPageData medicalTestPageData = MedicalTestPageData(
              MedicalPageDataType.Usual,
              patientEntity: null, onDone: () {
            widget.selectPage(1);
          },
              medicalTestItem: MedicalTestItem(element.testId, element.name),
              editableFlag: true,
              sendableFlag: true);

          widget.globalOnPush(
              NavigatorRoutes.cognitiveTest, medicalTestPageData);
        }
      }, true);
      services.add(cognitiveTest);
    });

    // NoronioServiceItem cognitiveGames = NoronioServiceItem("بازی های شناختی",
    //     Assets.noronioServiceGame, null, NoronioClinicServiceType.Game, () {
    //   // TODO
    //   toast(context, "در آینده آماده می شود");
    // }, false);
    // services.add(cognitiveGames);

    return services;
  }

  @override
  void initState() {
    // if(_state.entity.isPatient){
    BlocProvider.of<MedicalTestListBloc>(context).add(GetClinicMedicalTest());
    // }else if(_state.entity.isDoctor){
    //   if(_state.entity.doctor.clinic !=null && _state.entity.doctor.clinic.id == widget.noronioClinicId){
    //     _medicalTestListBloc.add(GetClinicMedicalTest());
    //   }else{
    //     _medicalTestListBloc.add(EmptyMedicalTestList());
    //   }
    // }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MedicalTestListBloc, MedicalTestListState>(
        builder: (context, state) {
      if (state is TestsListLoaded) {
        return _widget(state.result);
      } else if (state is TestsListError) {
        return APICallError(
          () {
            BlocProvider.of<MedicalTestListBloc>(context)
                .add(GetClinicMedicalTest());
          },
        );
      }
      return DocUpAPICallLoading2();
    });
  }

  Widget _widget(List<MedicalTestItem> testsList) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        NeuronioHeader(
          title: "نورونیو",
          docUpLogo: false,
        ),
        ALittleVerticalSpace(),
        DocUpSubHeader(
          title: "اولین کلینیک مجازی در حوزه شناختی",
        ),
        ALittleVerticalSpace(),
        _services(convertToNoronioServiceList(testsList))
      ],
    ));
  }

  Widget _services(List<NoronioServiceItem> serviceList) {
    List<Widget> serviceRows = [];
    for (int i = 0; i < serviceList.length; i += 2) {
      Widget ch1 = SquareBoxNoronioClinicService(serviceList[i]);
      Widget ch2 = (i == serviceList.length - 1)
          ? SquareBoxNoronioClinicService(NoronioServiceItem.empty())
          : SquareBoxNoronioClinicService(serviceList[i + 1]);

      serviceRows.add(Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [ch1, ch2],
      ));
    }
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: serviceRows,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
