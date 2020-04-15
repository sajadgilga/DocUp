import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:docup/constants/colors.dart';
import 'package:docup/models/DoctorResponseEntity.dart';
import 'package:docup/ui/widgets/ActionButton.dart';
import 'package:docup/ui/widgets/DoctorAvatar.dart';
import 'package:docup/ui/widgets/DoctorData.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:persian_datepicker/persian_datepicker.dart';

class VirtualReservationPage extends StatefulWidget {
  final DoctorEntity doctorEntity;

  VirtualReservationPage({Key key, this.doctorEntity}) : super(key: key);

  @override
  _VirtualReservationPageState createState() => _VirtualReservationPageState();
}

class _VirtualReservationPageState extends State<VirtualReservationPage> {

  // our text controller
  final TextEditingController textEditingController = TextEditingController();

  PersianDatePickerWidget persianDatePicker;

  @override
  void initState() {
    persianDatePicker = PersianDatePicker(
      controller: textEditingController,
      datetime: '1397/06/09',
    ).init();

    super.initState();
  }

  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 50),
      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
      child: Column(children: <Widget>[
        _headerWidget(),
        SizedBox(height: 10),
        _reservationTypeWidget("نوع مشاوره", ["تصویری", "متنی", "صوتی"]),
        SizedBox(height: 10),
        _reservationTypeWidget("مدت زمان مشاوره", ["پایه", "تکمیلی", "طولانی"]),
        SizedBox(height: 10),
        Text("ویزیت مجازی حداکثر ۳۰ دقیقه می‌باشد",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        _priceWidget(),
        SizedBox(height: 10),
        _timeSelectionWidget(),
//        SizedBox(height: 10),
//        _acceptPolicyWidget()
      ]),
    );
  }

  _headerWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          DoctorData(doctorEntity: widget.doctorEntity),
          SizedBox(width: 10),
          DoctorAvatar(doctorEntity: widget.doctorEntity),
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
              for (var item in items)
                ActionButton(
                  width: 120,
                  color: Colors.grey,
                  title: item,
                  callBack: () {},
                ),
            ],
          )
        ],
      );

  _priceWidget() => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("ریال", style: TextStyle( fontSize: 16)),
          SizedBox(width: 5),
          Text("۲۰,۰۰۰",
              style: TextStyle(
                  color: IColors.themeColor,fontSize: 18)),
          SizedBox(width: 5),
          Text("قیمت نهایی", style: TextStyle(fontSize: 16))
        ],
      );


  _timeSelectionWidget() => Column(
    children: <Widget>[
      Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("تعیین وقت قبلی ویزیت مجازی", textAlign: TextAlign.right, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),),
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
          Text("ساعت", textAlign: TextAlign.right,),
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
            width: MediaQuery.of(context).size.width * 0.3,
            child: DateTimeField(
              format: DateFormat("HH:mm"),
              onShowPicker: (context, currentValue) async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
                );
                return DateTimeField.convert(time);
              },
            ),
          ),
          SizedBox(width: 50),
          Container(
            width: MediaQuery.of(context).size.width * 0.3,
            child: DateTimeField(
              format: DateFormat("MM/dd"),
              onShowPicker: (context, currentValue) {
                return showDatePicker(
                    context: context,
                    firstDate: DateTime(1900),
                    initialDate: currentValue ?? DateTime.now(),
                    lastDate: DateTime(2100));
              },
            ),
          ),
        ],
      )
    ],
  );


  _acceptPolicyWidget() => Row(
    children: <Widget>[
      Checkbox(
        value: false,
        onChanged: (d) {},
      ),
      Text("من همه قوانین و مقررات رزرو ویزیت مجازی را خوانده و موافقت میکنم")
    ],
  );
}
