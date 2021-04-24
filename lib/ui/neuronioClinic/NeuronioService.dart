import 'package:Neuronio/blocs/MedicalTestListBloc.dart';
import 'package:Neuronio/constants/assets.dart';
import 'package:Neuronio/models/DoctorEntity.dart';
import 'package:Neuronio/models/MedicalTest.dart';
import 'package:Neuronio/models/NoronioService.dart';
import 'package:Neuronio/ui/mainPage/NavigatorView.dart';
import 'package:Neuronio/ui/widgets/APICallError.dart';
import 'package:Neuronio/ui/widgets/APICallLoading.dart';
import 'package:Neuronio/ui/widgets/DocupHeader.dart';
import 'package:Neuronio/ui/widgets/SquareBoxNeuronioClinic.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class NeuronioServicePage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final Function(int) selectPage;
  final Function(String, dynamic) globalOnPush;

  NeuronioServicePage(
      {Key key,
      @required this.onPush,
      @required this.selectPage,
      @required this.globalOnPush})
      : super(key: key);

  @override
  _NeuronioServicePageState createState() => _NeuronioServicePageState();
}

class _NeuronioServicePageState extends State<NeuronioServicePage> {
  List<NeuronioServiceItem> convertToNeuronioServiceList(
      List<MedicalTestItem> tests) {
    List<NeuronioServiceItem> services = [];

    NeuronioServiceItem doctorList = NeuronioServiceItem(
        "مشاهده متخصصان",
        Assets.neuronioServiceDoctorList,
        null,
        NeuronioClinicServiceType.DoctorsList, () {
      widget.onPush(NavigatorRoutes.partnerSearchView, NeuronioClinic.ClinicId);
    }, true);
    services.insert(0, doctorList);

    tests.forEach((element) {
      NeuronioServiceItem cognitiveTest = NeuronioServiceItem(
          element.name,
          Assets.neuronioServiceBrainTest,
          element.imageURL,
          NeuronioClinicServiceType.MultipleChoiceTest, () {
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

    // NeuronioServiceItem cognitiveGames = NeuronioServiceItem("بازی های شناختی",
    //     Assets.neuronioServiceGame, null, NeuronioClinicServiceType.Game, () {
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
    //   if(_state.entity.doctor.clinic !=null && _state.entity.doctor.clinic.id == widget.neuronioClinicId){
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
        _services(convertToNeuronioServiceList(testsList))
      ],
    ));
  }

  Widget _services(List<NeuronioServiceItem> serviceList) {
    List<Widget> serviceRows = [];
    for (int i = 0; i < serviceList.length; i += 2) {
      Widget ch1 = SquareBoxNeuronioClinicService(serviceList[i]);
      Widget ch2 = (i == serviceList.length - 1)
          ? SquareBoxNeuronioClinicService(NeuronioServiceItem.empty())
          : SquareBoxNeuronioClinicService(serviceList[i + 1]);

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
