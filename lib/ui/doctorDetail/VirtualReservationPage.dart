import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/blocs/EntityBloc.dart';
import 'package:docup/blocs/TabSwitchBloc.dart';
import 'package:docup/constants/colors.dart';
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

class VirtualReservationPage extends StatefulWidget {
  final DoctorEntity doctorEntity;
  final Function(String, dynamic) onPush;

  VirtualReservationPage({Key key, this.doctorEntity, this.onPush})
      : super(key: key);

  @override
  _VirtualReservationPageState createState() => _VirtualReservationPageState();
}

class _VirtualReservationPageState extends State<VirtualReservationPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  TextEditingController timeTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();

  Map<String, int> typeSelected = {
    VISIT_METHOD: VisitMethod.TEXT.index,
    VISIT_DURATION_PLAN: VisitDurationPlan.BASE.index
  };

  @override
  void initState() {
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        showOneButtonDialog(
            context,
            "درخواست شما برای پزشک فرستاده شد. لطفا منتظر تایید باشید",
            "متوجه شدم", () {
          Navigator.pop(context);
        });
      } else if (data.status == Status.ERROR) {
        if (data.message.startsWith("Unauthorised")) {
          showOneButtonDialog(
              context,
              "حساب شما اعتبار کافی ندارد. لطفا حساب تان را شارژ کنید",
              "افزایش اعتبار", () {
            widget.onPush(NavigatorRoutes.account, _calculateVisitCost());
          });
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
          _reservationTypeWidget(VISIT_METHOD, ["متنی", "تصویری"]),
          ALittleVerticalSpace(),
          _reservationTypeWidget(
              VISIT_DURATION_PLAN, ["پایه", "تکمیلی", "طولانی"]),
          SizedBox(height: 10),
          Text(
              "ویزیت مجازی حداکثر ${replaceFarsiNumber((typeSelected[VISIT_DURATION_PLAN] * 30 + 10).toString())} دقیقه می‌باشد",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
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

  void _showDatePicker() {
    showDialog(
      context: context,
      builder: (BuildContext _) {
        return PersianDateTimePicker(
          color: IColors.themeColor,
          type: "date",
          disable: ,
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

  _reservationTypeWidget(String title, List<String> items) => Column(
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
          SizedBox(height: 10),
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

  bool visitTimeChecked = false;

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
            "من همه قوانین و مقررات رزرو ویزیت مجازی را خوانده و موافقت میکنم",
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
            context, "لطفا زمان ویزیت را وارد کنید", "باشه", () {});
      } else {
        sendVisitRequest();
      }
    } else {
      if (_isDoctorOnline()) {
        sendVisitRequest();
      } else {
        showOneButtonDialog(
            context,
            " پزشک آنلاین نیست لطفا زمانی را برای ویزیت ویزیت مشخص کنید",
            "باشه",
            () {});
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
