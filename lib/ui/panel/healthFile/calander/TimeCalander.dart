import 'package:Neuronio/blocs/MedicineBloc.dart';
import 'package:Neuronio/models/Medicine.dart';
import 'package:Neuronio/models/UserEntity.dart';
import 'package:Neuronio/ui/panel/partnerContact/chatPage/PartnerInfo.dart';
import 'package:Neuronio/ui/widgets/TimeSelectorWidget.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TimeCalender extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;

  TimeCalender({Key key, @required this.entity, @required this.onPush})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _TimeCalenderState();
  }
}

class _TimeCalenderState extends State<TimeCalender> {
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final List<FocusNode> nodes = [FocusNode(), FocusNode()];
  final AlertDialog _loading = getLoadingDialog();
  final CreateMedicineBloc _createMedicineBloc = CreateMedicineBloc();

  @override
  initState() {
    super.initState();
  }

  @override
  dispose() {
    try {
      _createMedicineBloc.close();
    } catch (e) {}
    super.dispose();
  }

  // Widget _drugNameField(context) => TextField(
  //       controller: _drugNameController,
  //       onSubmitted: (text) {
  //         FocusScope.of(context).requestFocus(nodes[0]);
  //       },
  //       textAlign: TextAlign.end,
  //       textDirection: TextDirection.ltr,
  //       textInputAction: TextInputAction.next,
  //       decoration: InputDecoration(
  //         hintText: InAppStrings.drugNameTextFieldHint,
  //       ),
  //     );

  // Widget _countField(context) => TextField(
  //       controller: _countController,
  //       focusNode: nodes[0],
  //       onSubmitted: (text) {
  //         FocusScope.of(context).requestFocus(nodes[1]);
  //       },
  //       textAlign: TextAlign.end,
  //       textDirection: TextDirection.ltr,
  //       textInputAction: TextInputAction.next,
  //       decoration: InputDecoration(
  //         hintText: InAppStrings.countTextFieldHint,
  //       ),
  //     );
  //
  // Widget _periodField(context) => TextField(
  //       controller: _periodController,
  //       focusNode: nodes[1],
  //       textAlign: TextAlign.end,
  //       textDirection: TextDirection.ltr,
  //       decoration: InputDecoration(
  //         hintText: InAppStrings.periodTextFieldHint,
  //       ),
  //     );

  void _submit() {
    String name = _drugNameController.text;
    if (name == null || name == '') {
      showAlertDialog(context, 'نام دارو خالی است', () {});
      return;
    }
    String count = _countController.text;
    if (count == null || count == '') {
      showAlertDialog(context, 'تعداد دارو خالی است', () {});
      return;
    }
    String period = _periodController.text;
    if (period == null || period == '') {
      showAlertDialog(context, 'ساعت تکرار دارو خالی است', () {});
      return;
    }

    if (_createMedicineBloc.state == MedicineCreationStates.SENDING) return;
    _createMedicineBloc.add(MedicineCreate(
        medicine: Medicine(
            drugName: name,
            usage: count,
            patient: widget.entity.pId,
            usagePeriod: int.parse(period),
            numbers: int.parse(count))));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _loading;
        });
  }

  // Widget _submitButton(context) => Container(
  //     alignment: Alignment.center,
  //     child: InkWell(
  //       child: GestureDetector(
  //         onTap: () {
  //           _submit();
  //         },
  //         child: Container(
  //           decoration: BoxDecoration(
  //               borderRadius: BorderRadius.all(Radius.circular(8)),
  //               color: IColors.themeColor),
  //           padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
  //           margin: EdgeInsets.only(top: 60, bottom: 30),
  //           child: AutoText(
  //             InAppStrings.submitDrugLabel,
  //             textAlign: TextAlign.center,
  //             style: TextStyle(
  //                 fontSize: 14,
  //                 color: Colors.white,
  //                 fontWeight: FontWeight.bold),
  //           ),
  //         ),
  //       ),
  //     ));

  @override
  Widget build(BuildContext context) {
    // TODO amir:
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
                ALittleVerticalSpace(
                  height: 15,
                ),
                CircularTimeSelector()
              ]),
        ),
      ),
    );
  }
}
