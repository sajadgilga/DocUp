import 'package:docup/constants/colors.dart';
import 'package:docup/ui/widgets/AutoText.dart';
import 'package:flutter/material.dart';

class BlueTable2Data {
  List<B2DayPlan> daysSchedule = [
    B2DayPlan(0),
    B2DayPlan(1),
    B2DayPlan(2),
    B2DayPlan(3),
    B2DayPlan(4),
    B2DayPlan(5),
    B2DayPlan(6)
  ];

  BlueTable2Data();

  factory BlueTable2Data.fromJson(Map<String, dynamic> jsonData) {
    BlueTable2Data c = BlueTable2Data();
    for (int i = 0; i < jsonData['daysSchedule'].length; i++) {
      c.daysSchedule[i] = B2DayPlan.fromJson(jsonData['daysSchedule'][i]);
    }
    return c;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {};
    List<Map<String, dynamic>> days = [];
    for (int i = 0; i < daysSchedule.length; i++) {
      days.add(daysSchedule[i].toJson());
    }
    res['daysSchedule'] = days;
    return res;
  }

  BlueTable2Data.initialData(this.daysSchedule);
}

class B2DayPlan {
  int dayNumber;
  List<List<String>> dayPlan = []; //put the day lesson keys in there

  B2DayPlan(this.dayNumber);

  B2DayPlan.initialData(this.dayNumber);

  B2DayPlan.getEmptyInitial(this.dayNumber) {
    setEmptyDayPlan();
  }

  void setEmptyDayPlan() {
    List<List<String>> res = [];
    for (int hour = 0; hour < 24; hour++) {
      List<String> emptyHour = [];
      for (int tenMin = 0; tenMin < 4; tenMin++) {
        emptyHour.add(null);
      }
      res.add(emptyHour);
    }
    dayPlan = res;
  }

  Map<String, double> getDedicatedTimeForAllLessons() {
    Map<String, double> result = {};
    for (int hour = 0; hour < dayPlan.length; hour++) {
      for (int hourPart = 0; hourPart < dayPlan[hourPart].length; hourPart++) {
        if (dayPlan[hour][hourPart] != null) {
          result[dayPlan[hour][hourPart]] =
              (result[dayPlan[hour][hourPart]] ?? 0) + 15;
        }
      }
    }
    return result;
  }

  factory B2DayPlan.fromJson(dynamic json) {
    B2DayPlan d = B2DayPlan(json['dayNumber']);
    List<List<String>> daysLesson = [];
    for (int hour = 0; hour < json['dayPlan'].length; hour++) {
      List<String> emptyHour = [];
      for (int tenMin = 0; tenMin < json['dayPlan'][hour].length; tenMin++) {
        emptyHour.add(json['dayPlan'][hour][tenMin]);
      }
      daysLesson.add(emptyHour);
    }
    d.dayPlan = daysLesson;
    return d;
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> res = {'dayNumber': dayNumber, 'dayPlan': dayPlan};
    return res;
  }
}

class DailyTimeTable extends StatefulWidget {
  @override
  _DailyTimeTableState createState() => _DailyTimeTableState();
}

class _DailyTimeTableState extends State<DailyTimeTable> {
  double cellWidth;
  double cellHeight;
  BlueTable2Data blueTable2Data;
  int selectedDay;

  @override
  Widget build(BuildContext context) {
    cellWidth = MediaQuery.of(context).size.width * (19 / 100);
    cellHeight = MediaQuery.of(context).size.width * (13 / 100);
    return getColoredTable();
  }

  Widget getColoredTable() {
    List<Widget> allRows = [];
    List<List<String>> dayPlan =
        blueTable2Data.daysSchedule[selectedDay].dayPlan;
    for (int i = 0; i < dayPlan.length; i++) {
      allRows.add(getColoredRow(i, dayPlan[i]));
    }
    return Expanded(
        child: new SingleChildScrollView(
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: allRows,
        ),
      ),
      scrollDirection: Axis.vertical,
    ));
  }

  Widget getColoredRow(int rowNumber, List<String> hourPlanList) {
    List<Widget> res = [];
    B2DayPlan b2dayPlan = blueTable2Data.daysSchedule[selectedDay];
    List<List<String>> dayPlan = b2dayPlan.dayPlan;
    res.add(getRowNumberText(rowNumber));
    for (int i = 0; i < hourPlanList.length; i++) {
      /// TODO amir
      // Widget w = GestureDetector(
      //   key: ValueKey(selectedDay.toString() +
      //       "-" +
      //       (rowNumber).toString() +
      //       i.toString()),
      //   child: null,
      //   onTap: () {
      //     /// TODO amir
      //   },
      //   onLongPress: () {
      //     /// TODO amir
      //   },
      // );
      // res.add(w);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: res.reversed.toList(),
    );
  }

  void setCellValue(int rowIndex, int columnIndex, cellValue) async {
    //TODO amir
  }

  Widget getOneCell(int rowNumber, int columnNumber, key) {
    BorderRadius tr = BorderRadius.only(topLeft: Radius.circular(25));
    BorderRadius br = BorderRadius.only(bottomLeft: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == 0 && columnNumber == 3) {
      res = tr;
    } else if (rowNumber == 23 && columnNumber == 3) {
      res = br;
    } else {
      res = new BorderRadius.only();
    }

    ///  TODO amir: color
    Color lessonColor = IColors.red;
    return Container(
      width: cellWidth,
      height: cellHeight,
      child: key == "..."
          ? Container(
              width: cellHeight,
              height: cellHeight,
              child: Padding(
                padding: EdgeInsets.all(10),
                child: CircleAvatar(
                  backgroundColor: Color.fromARGB(0, 0, 0, 0),
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: new AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                  radius: 10,
                ),
              ),
            )
          : SizedBox(),
      decoration: BoxDecoration(
          borderRadius: res,
          color: lessonColor,
          border: BoxBorder.lerp(
              Border.all(color: IColors.darkGrey, width: 0.1),
              Border.all(color: IColors.darkGrey, width: 0.1),
              1)),
    );
  }

  Widget getRowNumberText(int rowNumber) {
    BorderRadius tl = BorderRadius.only(topRight: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomRight: Radius.circular(25));
    BorderRadius res;
    if (rowNumber == 0) {
      res = tl;
    } else if (rowNumber == 23) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    return Container(
      width: cellHeight,
      height: cellHeight,
      alignment: Alignment.center,
      child: AutoText(
        rowNumber < 10 ? "0" + rowNumber.toString() : rowNumber.toString(),
        style: TextStyle(fontSize: 15, color: IColors.darkGrey),
      ),
      decoration: BoxDecoration(
          color: IColors.background,
          borderRadius: res,
          border: BoxBorder.lerp(
              Border.all(color: IColors.darkGrey, width: 0.1),
              Border.all(color: IColors.darkGrey, width: 0.01),
              0)),
    );
  }
}
