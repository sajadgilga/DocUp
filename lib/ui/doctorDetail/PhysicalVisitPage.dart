import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/constants/strings.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/models/PatientEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/mainPage/NavigatorView.dart';
import 'package:docup/ui/panel/Panel.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/Avatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/ui/widgets/PatientData.dart';
import 'package:docup/ui/widgets/VerticalSpace.dart';
import 'package:docup/utils/Utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter/material.dart';

const VISIT_METHOD = "نوع مشاوره";
const VISIT_DURATION_PLAN = "مدت زمان مشاوره";

enum VisitMethod { TEXT, VOICE, VIDEO }

enum VisitDurationPlan { BASE, SUPPLEMENTARY, LONG }

class PhysicalVisitPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  PhysicalVisitPage({Key key, this.doctorEntity, this.onPush})
      : super(key: key);

  @override
  _PhysicalVisitPageState createState() => _PhysicalVisitPageState();
}

class _PhysicalVisitPageState extends State<PhysicalVisitPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  TextEditingController timeTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();

  Map<String, int> typeSelected = {
    VISIT_METHOD: VisitMethod.TEXT.index,
    VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  bool visitTimeChecked = false;

  @override
  void initState() {
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        showOneButtonDialog(context, Strings.visitRequestedMessage,
            Strings.understandAction, () => Navigator.pop(context));
      } else if (data.status == Status.ERROR) {
        if (data.message.startsWith("Unauthorised")) {
          showOneButtonDialog(
              context,
              Strings.notEnoughCreditMessage,
              Strings.addCreditAction,
              () => widget.onPush(
                  NavigatorRoutes.account, _calculateVisitCost()));
        } else {
          toast(context, data.message);
        }
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
        child: Column(children: <Widget>[
          _headerWidget(),
          ALittleVerticalSpace(),
          _visitTypeWidget(VISIT_METHOD, ["متنی", "تصویری"]),
          ALittleVerticalSpace(),
          _visitTypeWidget(VISIT_DURATION_PLAN, ["پایه", "تکمیلی", "طولانی"]),
          ALittleVerticalSpace(),
          _visitDurationTimeWidget(),
          ALittleVerticalSpace(),
          _priceWidget(),
          ALittleVerticalSpace(),
          _enableVisitTimeWidget(),
          _timeSelectionWidget(),
          ALittleVerticalSpace(),
          _acceptPolicyWidget(),
          ALittleVerticalSpace(),
          _submitWidget(),
          ALittleVerticalSpace(),
        ]),
      ),
    );
  }

  Text _visitDurationTimeWidget() {
    return Text(
            "ویزیت مجازی حداکثر ${replaceFarsiNumber((typeSelected[VISIT_DURATION_PLAN] * 30 + 10).toString())} دقیقه می‌باشد",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold));
  }

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext _) {
        return PersianDateTimePicker(
          color: IColors.themeColor,
          type: "date",
          onSelect: (date) {
            dateTextController.text = date;
          },
        );
      },
    );
  }

  _headerWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoctorData(
              width: MediaQuery.of(context).size.width * 0.7,
              doctorEntity: widget.doctorEntity),
          SizedBox(width: 10),
          Avatar(user: widget.doctorEntity.user),
        ],
      );

  _visitTypeWidget(String title, List<String> items) => Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.right,
                ),
              ],
            ),
          ),
          ALittleVerticalSpace(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              for (var index = 0; index < items.length; index++)
                ActionButton(
                  width: 120,
                  color: typeSelected[title] == index
                      ? IColors.themeColor
                      : Colors.grey,
                  title: items[index],
                  callBack: () {
                    setState(() {
                      typeSelected[title] = index;
                    });
                  },
                ),
            ],
          )
        ],
      );

  _priceWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("ریال", style: TextStyle(fontSize: 16)),
          SizedBox(width: 5),
          Text(replaceFarsiNumber(_calculateVisitCost()),
              style: TextStyle(color: IColors.themeColor, fontSize: 18)),
          SizedBox(width: 5),
          Text("قیمت نهایی", style: TextStyle(fontSize: 16))
        ],
      );

  String _calculateVisitCost() {
    int cost = 0;
    if (typeSelected[VISIT_METHOD] == VisitMethod.TEXT.index) {
      cost = widget.doctorEntity.plan.baseTextPrice;
    } else if (typeSelected[VISIT_METHOD] == VisitMethod.VIDEO.index) {
      cost = widget.doctorEntity.plan.baseVideoPrice;
    }
    cost *= (typeSelected[VISIT_DURATION_PLAN] + 1);
    return cost.toString();
  }

  _timeSelectionWidget() => Visibility(
        visible: visitTimeChecked,
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Text(
                  "ساعت",
                  textAlign: TextAlign.right,
                ),
                Icon(Icons.access_time, size: 30),
                SizedBox(width: 50),
                Text("تاریخ"),
                Icon(Icons.calendar_today),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: DateTimeField(
                    controller: timeTextController,
                    format: DateFormat("HH:mm"),
                    onShowPicker: (context, currentValue) async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(
                            currentValue ?? DateTime.now()),
                      );
                      return DateTimeField.convert(time);
                    },
                  ),
                ),
                SizedBox(width: 50),
                Container(
                  width: MediaQuery.of(context).size.width * 0.35,
                  child: TextField(
                      controller: dateTextController, onTap: _showDatePicker),
                ),
              ],
            )
          ],
        ),
      );

  Row _enableVisitTimeWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          "تعیین وقت قبلی ویزیت مجازی",
          textAlign: TextAlign.right,
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
        ),
        Switch(
          value: visitTimeChecked,
          activeColor: IColors.themeColor,
          onChanged: (bool value) {
            setState(() {
              visitTimeChecked = !visitTimeChecked;
            });
          },
        )
      ],
    );
  }

  bool policyChecked = false;

  _acceptPolicyWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text(
            Strings.privacyPolicyMessage,
            textAlign: TextAlign.right,
            style: TextStyle(fontSize: 10),
          ),
          Checkbox(
            activeColor: IColors.themeColor,
            value: policyChecked,
            onChanged: (d) {
              setState(() {
                policyChecked = !policyChecked;
              });
            },
          ),
        ],
      );

  _submitWidget() => ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: "شروع ویزیت مجازی",
        callBack: _submit,
      );

  _isDoctorOnline() => widget.doctorEntity.user.online == 1;

  void _submit() {
    if (!policyChecked) return;
    if (visitTimeChecked) {
      if (dateTextController.text.isEmpty || timeTextController.text.isEmpty) {
        showOneButtonDialog(
            context, Strings.enterVisitTimeMessage, Strings.okAction, () {});
      } else {
        sendVisitRequest();
      }
    } else {
      if (_isDoctorOnline()) {
        sendVisitRequest();
      } else {
        showOneButtonDialog(
            context, Strings.offlineDoctorMessage, Strings.okAction, () {});
      }
    }
  }

  void sendVisitRequest() {
    _bloc.visitRequest(
        widget.doctorEntity.id,
        _isDoctorOnline() ? 1 : 0,
        typeSelected[VISIT_METHOD],
        typeSelected[VISIT_DURATION_PLAN],
        convertToGeorgianDate(dateTextController.text) +
            "T" +
            timeTextController.text +
            ":00Z");
  }
}
