import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/MedicineBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/Medicine.dart';
import 'package:docup/models/UserEntity.dart';
import 'package:docup/ui/panel/chatPage/PartnerInfo.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateMedicinePage extends StatefulWidget {
  final Entity entity;
  final Function(String, dynamic) onPush;
  final Function() goBackToMainPage;

  CreateMedicinePage(
      {Key key,
      @required this.entity,
      @required this.onPush,
      @required this.goBackToMainPage})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _CreateMedicinePageState();
  }
}

class _CreateMedicinePageState extends State<CreateMedicinePage> {
  final TextEditingController _drugNameController = TextEditingController();
  final TextEditingController _countController = TextEditingController();
  final TextEditingController _periodController = TextEditingController();
  final List<FocusNode> nodes = [FocusNode(), FocusNode()];
  final AlertDialog _loading = getLoadingDialog();

  @override
  initState() {
    BlocProvider.of<CreateMedicineBloc>(context).listen((data) {
      if (data == MedicineCreationStates.SENT) {
        showPicUploadedDialog(context, "دارو با موفقیت ذخیره شد", () {
          Navigator.of(context, rootNavigator: true).maybePop();
          widget.goBackToMainPage();
        });
      } else if (data == MedicineCreationStates.ERROR) {
        showPicUploadedDialog(
            context, "مشکلی در ثبت دارو پیش آمد، دوباره تلاش کنید", () {
          Navigator.of(context, rootNavigator: true).maybePop();
        });
      }
    });
    super.initState();
  }

  Widget _drugNameField(context) => TextField(
        controller: _drugNameController,
        onSubmitted: (text) {
          FocusScope.of(context).requestFocus(nodes[0]);
        },
        textAlign: TextAlign.end,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: Strings.drugNameTextFieldHint,
        ),
      );

  Widget _countField(context) => TextField(
        controller: _countController,
        focusNode: nodes[0],
        onSubmitted: (text) {
          FocusScope.of(context).requestFocus(nodes[1]);
        },
        textAlign: TextAlign.end,
        textDirection: TextDirection.ltr,
        textInputAction: TextInputAction.next,
        decoration: InputDecoration(
          hintText: Strings.countTextFieldHint,
        ),
      );

  Widget _periodField(context) => TextField(
        controller: _periodController,
        focusNode: nodes[1],
        textAlign: TextAlign.end,
        textDirection: TextDirection.ltr,
        decoration: InputDecoration(
          hintText: Strings.periodTextFieldHint,
        ),
      );

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

    int patientId = BlocProvider.of<EntityBloc>(context).state.entity.pId;

    if (BlocProvider.of<CreateMedicineBloc>(context).state ==
        MedicineCreationStates.SENDING) return;
    BlocProvider.of<CreateMedicineBloc>(context).add(MedicineCreate(
        medicine: Medicine(drugName: name, usage: count, patient: patientId)));
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return _loading;
        });
  }

  Widget _submitButton(context) => Container(
      alignment: Alignment.center,
      child: InkWell(
        child: GestureDetector(
          onTap: () {
            _submit();
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                color: IColors.themeColor),
            padding: EdgeInsets.only(top: 10, bottom: 10, right: 20, left: 20),
            margin: EdgeInsets.only(top: 60, bottom: 30),
            child: Text(
              Strings.submitDrugLabel,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ));

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        widget.goBackToMainPage();
        return false;
      },
      child: Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              _drugNameField(context),
              _countField(context),
              _periodField(context),
              _submitButton(context)
            ],
          )),
    );
  }
}
