import 'package:docup/blocs/MedicalTestListBloc.dart';
import 'package:docup/constants/assets.dart';
import 'package:docup/models/MedicalTest.dart';
import 'package:docup/models/NoronioService.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/widgets/APICallError.dart';
import 'package:docup/ui/widgets/APICallLoading.dart';
import 'package:docup/ui/widgets/DocupHeader.dart';
import 'package:docup/ui/widgets/SquareBoxNoronioClinic.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NoronioServicePage extends StatefulWidget {
  final Function(String, dynamic) onPush;
  final Function(String, dynamic) globalOnPush;
  final int noronioClinicId = 4;

  NoronioServicePage(
      {Key key, @required this.onPush, @required this.globalOnPush})
      : super(key: key);

  @override
  _NoronioServicePageState createState() => _NoronioServicePageState();
}

class _NoronioServicePageState extends State<NoronioServicePage> {
  List<NoronioServicePage> services = [];

  List<NoronioService> convertToNoronioServiceList(
      List<MedicalTestItem> tests) {
    List<NoronioService> services = [];
    NoronioService doctorList = NoronioService(
        "مشاهده پزشکان",
        Assets.noronioServiceDoctorList,
        null,
        NoronioClinicServiceType.DoctorsList, () {
      // TODO

      widget.onPush(NavigatorRoutes.partnerSearchView, widget.noronioClinicId);
    }, true);
    services.insert(0, doctorList);

    tests.forEach((element) {
      NoronioService cognitiveTest = NoronioService(
          element.name,
          Assets.noronioServiceBrainTest,
          null,
          NoronioClinicServiceType.MultipleChoiceTest, () {
        /// TODO
        MedicalTestItem emptyTest = MedicalTestItem(element.id, element.name);
        widget.globalOnPush(NavigatorRoutes.cognitiveTest, emptyTest);
      }, true);
      services.insert(1, cognitiveTest);
    });

    NoronioService cognitiveGames = NoronioService("بازی های شناختی",
        Assets.noronioServiceGame, null, NoronioClinicServiceType.Game, () {
      // TODO
      toast(context, "در آینده آماده می شود");
    }, false);
    services.insert(services.length, cognitiveGames);

    return services;
  }

  @override
  void initState() {
    // var _state = BlocProvider.of<EntityBloc>(context).state;
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
          onRetryPressed: () {
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
        DocUpHeader(title: "نورونیو"),
        ALittleVerticalSpace(),
        DocUpSubHeader(
          title: "اولین کلینیک مجازی در حوزه شناختی",
        ),
        ALittleVerticalSpace(),
        _services(convertToNoronioServiceList(testsList))
      ],
    ));
  }

  Widget _services(List<NoronioService> serviceList) {
    List<Widget> serviceRows = [];
    for (int i = 0; i < serviceList.length; i += 2) {
      Widget ch1 = SquareBoxNoronioClinicService(serviceList[i]);
      Widget ch2 = (i == serviceList.length - 1)
          ? SquareBoxNoronioClinicService(NoronioService.empty())
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
