import 'package:Neuronio/blocs/MedicineBloc.dart';
import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/visit/calendar/persian_datetime_picker2.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/medicines/ReminderList.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DateCalender extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;

  const DateCalender({Key key, this.entity, this.onPush}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _DateCalenderState();
  }
}

class _DateCalenderState extends State<DateCalender> {
  MedicineBloc _medicineBloc = MedicineBloc();

  @override
  void initState() {
    _medicineBloc.add(MedicineGet());
    super.initState();
  }

  @override
  void dispose() {
    try {
      _medicineBloc.close();
    } catch (e) {}
    super.dispose();
  }

  Widget _reminderList() {
    return BlocBuilder<MedicineBloc, MedicineState>(
        bloc: _medicineBloc,
        builder: (context, state) {
          return ReminderList(
            medicines: state.medicines,
          );
        });
  }

  Widget _today() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        AutoText(
          'امروز',
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        _reminderList()
      ],
    );
  }

  // Widget _nextWeek() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: <Widget>[
  //       AutoText(
  //         'تا هفته آینده',
  //         textAlign: TextAlign.right,
  //         style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
  //       ),
  //       ReminderList(
  //         medicines: [],
  //       )
  //     ],
  //   );
  // }

  // Widget _mainPage() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.end,
  //     children: <Widget>[_today(), _nextWeek()],
  //   );
  // }

  // Widget _getCurrentPage() {
  //   if (_currentPage == _MedicinePage.MAIN)
  //     return _mainPage();
  //   else if (_currentPage == _MedicinePage.CREATION)
  //     return CreateMedicinePage(
  //       entity: widget.entity,
  //       onPush: widget.onPush,
  //       goBackToMainPage: _goBack,
  //     );
  //   return Container();
  // }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(minWidth: double.infinity),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                PartnerInfo(
                  entity: widget.entity.partnerEntity,
                  onPush: widget.onPush,
                ),
                Container(
                  color: IColors.grey,
                  child: PersianDateTimePicker2(
                    color: IColors.themeColor,
                    type: "date",
                    initial: DateTimeService.getTomorrowInJalali(),
                    min: DateTimeService.getTodayInJalaliString(),
                    availableDates: null,
                    onSelect: (date) {},
                  ),
                )
              ]),
        ),
      ),
    );
  }
}
