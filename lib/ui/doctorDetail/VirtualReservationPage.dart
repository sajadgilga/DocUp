import 'package:docup/blocs/DoctorInfoBloc.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorEntity.dart';
import 'package:docup/networking/Response.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/DoctorAvatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:docup/utils/UiUtils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';
import 'package:shamsi_date/shamsi_date.dart';

class VirtualReservationPage extends StatefulWidget {
  final DoctorEntity doctorEntity;

  VirtualReservationPage({Key key, this.doctorEntity}) : super(key: key);

  @override
  _VirtualReservationPageState createState() => _VirtualReservationPageState();
}

class _VirtualReservationPageState extends State<VirtualReservationPage> {
  DoctorInfoBloc _bloc = DoctorInfoBloc();
  TextEditingController timeTextController = TextEditingController();
  TextEditingController dateTextController = TextEditingController();

  @override
  void initState() {
    _bloc.visitRequestStream.listen((data) {
      if (data.status == Status.COMPLETED) {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text('درخواست شما با موفقیت ثبت شد'),
          duration: Duration(seconds: 3),
        ));
      } else {
        Scaffold.of(context).showSnackBar(SnackBar(
          content: Text(data.message),
          duration: Duration(seconds: 3),
        ));
      }
    });
    super.initState();
  }

  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        margin: EdgeInsets.only(top: 50),
        constraints:
        BoxConstraints(maxWidth: MediaQuery
            .of(context)
            .size
            .width),
        child: Column(children: <Widget>[
          _headerWidget(),
          SizedBox(height: 10),
          _reservationTypeWidget("نوع مشاوره", ["متنی", "تصویری"]),
          SizedBox(height: 10),
          _reservationTypeWidget(
              "مدت زمان مشاوره", ["پایه", "تکمیلی", "طولانی"]),
          SizedBox(height: 10),
          Text(
              "ویزیت مجازی حداکثر ${replaceFarsiNumber(
                  (typeSelected["مدت زمان مشاوره"] * 30 + 10)
                      .toString())} دقیقه می‌باشد",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          _priceWidget(),
          SizedBox(height: 10),
          _timeSelectionWidget(),
          SizedBox(height: 10),
          _acceptPolicyWidget(),
          SizedBox(height: 10),
          _submitWidget(),
          SizedBox(height: 10),
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
          initial: '1399/02/01',
          type: "date",
          onSelect: (date) {
            dateTextController.text = date;
          },
        );
      },
    );
  }

  void _showTimePicker() {
    showDialog(
      context: context,
      builder: (BuildContext _) {
        return PersianDateTimePicker(
          color: IColors.themeColor,
          initial: '19:50',
          type: "time",
          onSelect: (time) {
            timeTextController.text = time;
            ;
          },
        );
      },
    );
  }

  _headerWidget() =>
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoctorData(doctorEntity: widget.doctorEntity),
          SizedBox(width: 10),
          DoctorAvatar(doctorEntity: widget.doctorEntity),
        ],
      );

  Map<String, int> typeSelected = {"نوع مشاوره": 2, "مدت زمان مشاوره": 2};

  _reservationTypeWidget(String title, List<String> items) =>
      Column(
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

  _priceWidget() =>
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("ریال", style: TextStyle(fontSize: 16)),
          SizedBox(width: 5),
          Text(
              replaceFarsiNumber((widget.doctorEntity.fee *
                  (typeSelected["نوع مشاوره"] + 1) *
                  (typeSelected["مدت زمان مشاوره"] + 1))
                  .toString()),
              style: TextStyle(color: IColors.themeColor, fontSize: 18)),
          SizedBox(width: 5),
          Text("قیمت نهایی", style: TextStyle(fontSize: 16))
        ],
      );

  _timeSelectionWidget() =>
      Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              Text(
                "تعیین وقت قبلی ویزیت مجازی",
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              Switch(
                value: true,
                activeColor: IColors.themeColor,
                onChanged: (d) {},
              )
            ],
          ),
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
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.35,
                child: TextField(
                  controller: timeTextController,
                  onTap: _showTimePicker,
                ),
              ),
              SizedBox(width: 50),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width * 0.35,
                child: TextField(
                    controller: dateTextController, onTap: _showDatePicker),
              ),
            ],
          )
        ],
      );

  bool policyChecked = false;

  _acceptPolicyWidget() =>
      Row(
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

  _submitWidget() =>
      ActionButton(
        color: policyChecked ? IColors.themeColor : Colors.grey,
        title: "شروع ویزیت مجازی",
        callBack: () {
          if (policyChecked) {
            _bloc.visitRequest(
                widget.doctorEntity.id,
                typeSelected["نوع مشاوره"],
                2,
                typeSelected["مدت زمان مشاوره"],
                convertToGeorgianDate(dateTextController.text) +
                    "T" +
                    timeTextController.text +
                    ":00Z");
          }
        },
      );

  String convertToGeorgianDate(String jalaliDate) {
    var array = jalaliDate.split("/");
    var georgianDate = Jalali(int.parse(array[0]), int.parse(array[1]), int.parse(array[2]))
        .toGregorian();
    return "${georgianDate.year}-${georgianDate.month}-${georgianDate.day}";
  }
}
