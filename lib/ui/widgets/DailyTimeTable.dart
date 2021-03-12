import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/SnackBar.dart';
import 'package:Neuronio/ui/widgets/VerticalSpace.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';

class LegendItem {
  final String name;
  final Color color;

  LegendItem(this.name, this.color);
}

class WeeklyTimeTable extends StatefulWidget {
  final List<List<List<int>>> daysPlanTable;
  final int startTableHour;
  final int endTableHour;
  final bool editable;

  /// for later info
  double tableHeight;
  double cellWidth;
  double cellHeight;
  double tabHeight = 50;
  double gapHeight = 20;
  int cellRows;

  WeeklyTimeTable(BuildContext parentContext, this.daysPlanTable,
      {this.startTableHour = 0, this.endTableHour = 24, this.editable = true}) {
    cellRows = this.endTableHour - this.startTableHour;
    cellWidth = MediaQuery.of(parentContext).size.width * (15 / 100);
    cellHeight = MediaQuery.of(parentContext).size.width * (8 / 100);
    this.tableHeight = cellRows * cellHeight + 55 + tabHeight + gapHeight;
  }

  @override
  _WeeklyTimeTableState createState() => _WeeklyTimeTableState();
}

class _WeeklyTimeTableState extends State<WeeklyTimeTable>
    with TickerProviderStateMixin {
  TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: 7, //TODO
      initialIndex: 6,
      vsync: this,
    );
    tabController.addListener(() {
      try {
        /// TODO
      } catch (e) {}
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> coloredTableList = [
      for (int i = DoctorPlan.daysCount - 1; i >= 0; i--)
        DailyWorkTimesTable(
          cellHeight: widget.cellHeight,
          cellWidth: widget.cellWidth,
          endTableHour: widget.endTableHour,
          startTableHour: widget.startTableHour,
          dayPlanTable: widget.daysPlanTable[i],
          editable: widget.editable,
        )
    ];
    List<Widget> tabsTable = [
      for (int i = DoctorPlan.daysCount - 1; i >= 0; i--)
        Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(vertical: 10),
          child: AutoText(
            Strings.persianDaysSigns[i],
            style: TextStyle(fontSize: 18, color: IColors.themeColor),
            maxLines: 1,
          ),
        ),
    ];

    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Column(
        children: [
          Container(
            height: 50,
            child: TabBar(
              controller: tabController,
              tabs: tabsTable,
              isScrollable: true,
            ),
          ),
          ALittleVerticalSpace(
            height: widget.gapHeight,
          ),
          Container(
            height: widget.cellRows * widget.cellHeight + 55,
            alignment: Alignment.center,
            child: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: tabController,
              children: coloredTableList,
            ),
          ),
        ],
      ),
    );
  }
}

class DailyWorkTimesTable extends StatefulWidget {
  final List<List<int>> dayPlanTable;
  final int startTableHour;
  final int endTableHour;
  final bool editable;
  final double cellWidth;
  final double cellHeight;

  const DailyWorkTimesTable(
      {Key key,
      this.dayPlanTable,
      this.startTableHour,
      this.endTableHour,
      this.editable,
      this.cellHeight,
      this.cellWidth})
      : super(key: key);

  @override
  _DailyWorkTimesTableState createState() => _DailyWorkTimesTableState();
}

class _DailyWorkTimesTableState extends State<DailyWorkTimesTable> {
  Tween<int> lastHoverCell = Tween(begin: -1, end: -1);
  final LegendItem availableLegendItem = LegendItem("فعال", IColors.themeColor);
  final LegendItem unavailableLegendItem =
      LegendItem("غیر فعال", Color.fromARGB(255, 180, 180, 180));

  @override
  Widget build(BuildContext context) {
    List<Widget> allRows = [];
    for (int i = 0; i < widget.dayPlanTable.length; i++) {
      if (widget.startTableHour <= i && widget.endTableHour - 1 >= i) {
        allRows.add(getColoredRow(i, widget.dayPlanTable[i]));
      }
    }
    return Container(
      child: Column(
        children: [
          _legend(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: allRows,
          ),
        ],
      ),
    );
  }

  Widget _legend() {
    Widget legendItem(String title, Widget widget) {
      return Row(children: [
        AutoText(
          title,
        ),
        SizedBox(
          width: 5,
        ),
        widget
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          legendItem(
            unavailableLegendItem.name,
            Container(
              width: 20,
              height: 20,
              child: Icon(
                Icons.circle,
                color: unavailableLegendItem.color,
              ),
              color: Color.fromARGB(0, 0, 0, 0),
            ),
          ),
          SizedBox(
            width: 15,
          ),
          legendItem(
            availableLegendItem.name,
            Container(
              width: 20,
              height: 20,
              child: Icon(
                Icons.circle,
                color: availableLegendItem.color,
              ),
              color: Color.fromARGB(0, 0, 0, 0),
            ),
          ),
          SizedBox(
            width: 30,
          ),
        ],
      ),
    );
  }

  Widget getColoredRow(int rowNumber, List<int> hourPlanList) {
    List<Widget> res = [];
    res.add(getRowNumberText(rowNumber));
    for (int i = 0; i < hourPlanList.length; i++) {
      Widget w = GestureDetector(
        key: ValueKey((rowNumber).toString() + i.toString()),
        child: getOneCell(rowNumber, i, hourPlanList[i]),
        // onTap: () {
        //   cellToggle(rowNumber, i);
        // },
        // onPointerMove: (m) {
        //   onPointerMove(rowNumber, i, m.localPosition);
        // },
        // onPointerDown: (d) {
        //   onPointerDown(rowNumber, i, d);
        // },
        // onPointerUp: (u) {
        //   onPointerUp(rowNumber, i, u);
        // },
        onTap: () {
          cellToggle(rowNumber, i);
        },
        onHorizontalDragUpdate: (DragUpdateDetails dragUpdateDetails) {
          onPointerHorizontalMove(
              rowNumber, i, dragUpdateDetails.localPosition);
        },
        onVerticalDragUpdate: (DragUpdateDetails dragUpdateDetails) {
          onPointerVerticalMove(rowNumber, i, dragUpdateDetails.localPosition);
        },
      );
      res.add(w);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: res.reversed.toList(),
    );
  }

  Tween<int> convertLocalPositionOffsetToLocalPositionShift(Offset offset) {
    int xGap;
    int yGap;
    double x = offset.dx / widget.cellWidth;
    double y = offset.dy / widget.cellHeight;
    if (x > 0) {
      xGap = x.floor();
    } else {
      xGap = x.ceil() - 1;
    }

    if (y > 0) {
      yGap = y.floor();
    } else {
      yGap = y.ceil() - 1;
    }
    return Tween(begin: xGap, end: yGap);
  }

  void onPointerDown(int rowNumber, int index, Offset offset) {
    lastHoverCell = null;
  }

  void onPointerUp(int rowNumber, int index, Offset offset) {
    onPointerHorizontalMove(rowNumber, index, offset);
    lastHoverCell = null;
  }

  void onPointerHorizontalMove(int rowNumber, int index, Offset offset) {
    Tween<int> cellGap = convertLocalPositionOffsetToLocalPositionShift(offset);
    int cellRowNumber = rowNumber + 0;
    int cellIndex = index - cellGap.begin;
    Tween<int> current = Tween(begin: cellIndex, end: cellRowNumber);
    if (lastHoverCell == null ||
        current.begin != lastHoverCell.begin ||
        current.end != lastHoverCell.end) {
      try {
        cellToggle(current.end, current.begin);
        lastHoverCell = current;
      } catch (e) {}
    }
  }

  void onPointerVerticalMove(int rowNumber, int index, Offset offset) {
    Tween<int> cellGap = convertLocalPositionOffsetToLocalPositionShift(offset);
    int cellRowNumber = rowNumber + cellGap.end;
    Tween<int> current = Tween(begin: 0, end: cellRowNumber);
    if (lastHoverCell == null || current.end != lastHoverCell.end) {
      try {
        for (int i = 0; i < DoctorPlan.hourParts; i++) {
          cellToggle(current.end, i, withoutSetState: true);
        }
        lastHoverCell = current;
        setState(() {});
      } catch (e) {}
    }
  }

  void cellToggle(int rowNumber, int index, {bool withoutSetState = false}) {
    if (withoutSetState) {
      widget.dayPlanTable[rowNumber][index] =
          widget.dayPlanTable[rowNumber][index] == 0 ? 1 : 0;
    } else {
      setState(() {
        widget.dayPlanTable[rowNumber][index] =
            widget.dayPlanTable[rowNumber][index] == 0 ? 1 : 0;
      });
    }
  }

  Widget getOneCell(int rowNumber, int columnNumber, int key) {
    BorderRadius tl = BorderRadius.only(topLeft: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomLeft: Radius.circular(25));
    BorderRadius tbl = BorderRadius.only(
        bottomLeft: Radius.circular(25), topLeft: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == widget.startTableHour &&
        rowNumber == widget.endTableHour - 1 &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = tbl;
    } else if (rowNumber == widget.startTableHour &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = tl;
    } else if (rowNumber == widget.endTableHour - 1 &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    ///  TODO amir: color
    Color lessonColor;
    if (key == 1) {
      lessonColor = availableLegendItem.color;
    } else {
      lessonColor = unavailableLegendItem.color;
    }
    return Container(
      width: widget.cellWidth,
      height: widget.cellHeight,
      child: ![0, 1].contains(key)
          ? Container(
              width: widget.cellHeight,
              height: widget.cellHeight,
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
              Border.all(color: IColors.background, width: 0.5),
              Border.all(color: IColors.background, width: 0.5),
              1)),
    );
  }

  Widget getRowNumberText(int rowNumber) {
    BorderRadius tl = BorderRadius.only(topRight: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomRight: Radius.circular(25));
    BorderRadius tbl = BorderRadius.only(
        bottomRight: Radius.circular(25), topRight: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == widget.startTableHour &&
        rowNumber == widget.endTableHour - 1) {
      res = tbl;
    } else if (rowNumber == widget.startTableHour) {
      res = tl;
    } else if (rowNumber == widget.endTableHour - 1) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    return Container(
      width: widget.cellHeight,
      height: widget.cellHeight,
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

class DailyAvailableVisitTime extends StatefulWidget {
  final List<List<int>> dayReservedTimeTable;
  final List<List<int>> dailyDoctorWorkTime;
  final int startTableHour;
  final int endTableHour;
  double cellWidth;
  double cellHeight;
  final TextEditingController planDurationInMinute;
  final TextEditingController selectedDateController;
  final TextEditingController selectedTimeController;
  final Function onBlocTap;
  final int minutesGapBetweenNow;

  /// 0 for allowing selecting just one part,1 for two and 2 for three part

  DailyAvailableVisitTime(
      {Key key,
      this.dayReservedTimeTable,
      this.dailyDoctorWorkTime,
      this.startTableHour,
      this.endTableHour,
      this.cellHeight,
      this.cellWidth,
      this.planDurationInMinute,
      this.selectedDateController,
      this.selectedTimeController,
      this.onBlocTap,
      this.minutesGapBetweenNow = 0})
      : super(key: key);

  @override
  _DailyAvailableVisitTimeTableState createState() =>
      _DailyAvailableVisitTimeTableState();
}

class _DailyAvailableVisitTimeTableState
    extends State<DailyAvailableVisitTime> {
  final LegendItem availableLegendItem = LegendItem("فعال", IColors.themeColor);
  final LegendItem unavailableLegendItem =
      LegendItem("غیر فعال", Color.fromARGB(255, 180, 180, 180));
  final LegendItem reservedLegendItem = LegendItem("رزرو شده", Colors.black54);
  final LegendItem selectedLegendItem = LegendItem("انتخاب شده", IColors.green);
  List<int> selectedPartNumbers = [];
  List<int> errorSelectedPartNumber = [];

  @override
  Widget build(BuildContext context) {
    if (widget.cellWidth == null) {
      widget.cellWidth = MediaQuery.of(context).size.width * (19 / 100);
    }
    if (widget.cellHeight == null) {
      widget.cellHeight = MediaQuery.of(context).size.width * (8 / 100);
    }
    List<Widget> allRows = [];
    for (int i = 0; i < widget.dailyDoctorWorkTime.length; i++) {
      if (widget.startTableHour <= i && widget.endTableHour - 1 >= i) {
        allRows.add(getColoredRow(i));
      }
    }
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: widget.selectedDateController,
            maxLines: 1,
            enabled: false,
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            decoration: InputDecoration(border: InputBorder.none),
          ),
          _legend(),
          _columnGuid(),
          allRows.length != 0
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: allRows,
                )
              : emptyAvailableTime(),
        ],
      ),
    );
  }

  Widget _columnGuid() {
    print(widget.cellWidth);
    Widget columnItem(String text, double linePercent, double width) {
      return Container(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoText(text),
            Container(
              width: linePercent * width,
              height: 2,
              color: IColors.darkGrey,
            )
          ],
        ),
      );
    }

    return Container(
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          columnItem("نیم ساعت دوم", 0.6, 2 * widget.cellWidth),
          columnItem("نیم ساعت اول", 0.6, 2 * widget.cellWidth),
          columnItem("ساعت", 0, widget.cellHeight * 1.5)
        ],
      ),
    );
  }

  Widget _legend() {
    Widget legendItem(String title, Widget widget) {
      return Row(children: [
        AutoText(
          title,
        ),
        SizedBox(
          width: 5,
        ),
        widget
      ]);
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              legendItem(
                unavailableLegendItem.name,
                Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.circle,
                    color: unavailableLegendItem.color,
                  ),
                  color: Color.fromARGB(0, 0, 0, 0),
                ),
              ),
              legendItem(
                availableLegendItem.name,
                Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.circle,
                    color: availableLegendItem.color,
                  ),
                  color: Color.fromARGB(0, 0, 0, 0),
                ),
              )
            ],
          ),
          SizedBox(
            width: 30,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              legendItem(
                reservedLegendItem.name,
                Container(
                  width: 20,
                  height: 20,
                  child: Icon(
                    Icons.circle,
                    color: reservedLegendItem.color,
                  ),
                  color: Color.fromARGB(0, 0, 0, 0),
                ),
              ),
              legendItem(
                selectedLegendItem.name,
                Container(
                  width: 20,
                  height: 20,
                  color: Color.fromARGB(0, 0, 0, 0),
                  child: Icon(
                    Icons.circle,
                    color: selectedLegendItem.color,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget emptyAvailableTime() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 15),
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
          ),
          border: Border.all(width: 1, color: IColors.darkGrey)),
      child: AutoText("زمان مناسبی برای روز انتخاب شده موجود نیست."),
    );
  }

  Widget getColoredRow(int rowNumber) {
    List<int> hourPlanList = widget.dailyDoctorWorkTime[rowNumber];
    List<Widget> res = [];
    res.add(getRowNumberText(rowNumber));
    for (int columnIndex = 0;
        columnIndex < hourPlanList.length;
        columnIndex++) {
      Widget w = GestureDetector(
        key: ValueKey((rowNumber).toString() + columnIndex.toString()),
        child: getOneCell(rowNumber, columnIndex, hourPlanList[columnIndex]),
        onTap: () {
          handleOnCellTap(rowNumber, columnIndex);
        },
      );
      res.add(w);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: res.reversed.toList(),
    );
  }

  void handleOnCellTap(int r, int c) {
    int currentBloc = DoctorPlan.getPartNumberWithIndex(r, c);
    selectedPartNumbers.sort();
    if (selectedPartNumbers.contains(currentBloc)) {
      /// removing tapped bloc
      /// new plan
      setState(() {
        selectedPartNumbers = [];
      });
      // if (selectedPartNumbers.length == 3 &&
      //     selectedPartNumbers.indexOf(currentBloc) == 1) {
      //   setState(() {
      //     selectedPartNumbers = [selectedPartNumbers[0]];
      //   });
      // } else {
      //   setState(() {
      //     selectedPartNumbers.remove(currentBloc);
      //   });
      // }

      /// TODO
    } else if (selectedPartNumbers.length >= 2) {
      /// TODO max bloc per visit exceeded
      /// show snack bar
      selectedPartNumbers = [];
      // showSnackBar(null, "حداکثر زمان برای هر ویزیت ۳۰ دقیقه است",
      //     context: context);
      handleOnCellTap(r, c);
    }
    // else if (selectedPartNumbers.length == 0 ||
    //     selectedPartNumbers.last + 1 == currentBloc ||
    //     selectedPartNumbers.first - 1 == currentBloc) {
    //   /// checking next cell to be available
    //   bool checkDurationPlan = true;
    //   if ((widget.dayReservedTimeTable != null &&
    //           widget.dayReservedTimeTable[r][c] == 1) ||
    //       widget.dailyDoctorWorkTime[r][c] == 0) {
    //     checkDurationPlan = false;
    //   }
    //   if (checkDurationPlan) {
    //     setState(() {
    //       selectedPartNumbers.add(currentBloc);
    //     });
    //   } else {
    //     showErrorOnCells(r, c, 1);
    //     showSnackBar(null, "زمان انتخاب شده در بازه های مناسب نیست.",
    //         context: context);
    //   }
    // } else {
    //   /// show snack bar error discrete
    //   /// TODO amir
    //   showSnackBar(null, "زمان های انتخاب شده باید پشت سر هم باشند.",
    //       context: context);
    // }
    else {
      if (c % 2 == 0) {
        bool firstIsReserved = ((widget.dayReservedTimeTable != null &&
                widget.dayReservedTimeTable[r][c] == 1) ||
            widget.dailyDoctorWorkTime[r][c] == 0);
        bool secondIsReserved = ((widget.dayReservedTimeTable != null &&
                widget.dayReservedTimeTable[r][c + 1] == 1) ||
            widget.dailyDoctorWorkTime[r][c + 1] == 0);
        bool firstInGap = checkCellGapLimit(r, c);
        bool secondInGap = checkCellGapLimit(r, c + 1);
        if (firstIsReserved || secondIsReserved || firstInGap || secondInGap) {
          showErrorOnCells(r, c, 1);
          showSnackBar(null, "زمان انتخاب شده در بازه های مناسب نیست.",
              context: context);
        } else {
          setState(() {
            selectedPartNumbers = [currentBloc, currentBloc + 1];
          });
        }
      } else {
        bool firstIsReserved = ((widget.dayReservedTimeTable != null &&
                widget.dayReservedTimeTable[r][c] == 1) ||
            widget.dailyDoctorWorkTime[r][c] == 0);
        bool secondIsReserved = ((widget.dayReservedTimeTable != null &&
                widget.dayReservedTimeTable[r][c - 1] == 1) ||
            widget.dailyDoctorWorkTime[r][c - 1] == 0);
        bool firstInGap = checkCellGapLimit(r, c);
        bool secondInGap = checkCellGapLimit(r, c - 1);
        if (firstIsReserved || secondIsReserved || firstInGap || secondInGap) {
          showErrorOnCells(r, c, 1);
          showSnackBar(null, "زمان انتخاب شده در بازه های مناسب نیست.",
              context: context);
        } else {
          setState(() {
            selectedPartNumbers = [currentBloc, currentBloc - 1];
          });
        }
      }
    }
    selectedPartNumbers.sort();
    if (selectedPartNumbers.length == 0) {
      widget.selectedTimeController.text = "";
    } else {
      widget.selectedTimeController.text =
          DateTimeService.convertMinuteToTimeString(
              selectedPartNumbers.first * DoctorPlan.hourMinutePart);
    }
    widget.planDurationInMinute.text =
        (selectedPartNumbers.length * 15).toString();

    /// calling on bloc tap to update parent widget
    try {
      widget.onBlocTap();
    } catch (e) {}
  }

  void showErrorOnCells(int r, int c, int cellCount) {
    setState(() {
      for (int i = 0; i < cellCount; i++) {
        int x = r + (c + i) ~/ (DoctorPlan.hourParts);
        int y = (c + i) % DoctorPlan.hourParts;
        errorSelectedPartNumber.add(DoctorPlan.getPartNumberWithIndex(x, y));
      }
    });
    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        errorSelectedPartNumber = [];
      });
    });
  }

  bool checkCellGapLimit(
    int rowNumber,
    int columnNumber,
  ) {
    DateTime now = DateTimeService.getCurrentDateTime();

    int partNumber = DoctorPlan.getPartNumberWithIndex(rowNumber, columnNumber);

    int startCellMinute = partNumber * DoctorPlan.hourMinutePart;
    DateTime cellDateTime = DateTimeService.getDateAndTimeFromJalali(
        widget.selectedDateController.text);
    cellDateTime = DateTime(cellDateTime.year, cellDateTime.month,
        cellDateTime.day, startCellMinute ~/ 60, startCellMinute % 60);

    if (cellDateTime
        .isAfter(now.add(Duration(minutes: widget.minutesGapBetweenNow)))) {
      return false;
    }
    return true;
  }

  Widget getOneCell(int rowNumber, int columnNumber, int key) {
    BorderRadius tl = BorderRadius.only(topLeft: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomLeft: Radius.circular(25));
    BorderRadius tbl = BorderRadius.only(
        bottomLeft: Radius.circular(25), topLeft: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == widget.startTableHour &&
        rowNumber == widget.endTableHour - 1 &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = tbl;
    } else if (rowNumber == widget.startTableHour &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = tl;
    } else if (rowNumber == widget.endTableHour - 1 &&
        columnNumber == DoctorPlan.hourParts - 1) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    /// part number

    int partNumber = DoctorPlan.getPartNumberWithIndex(rowNumber, columnNumber);

    ///  TODO amir: color
    Color lessonColor;
    if (errorSelectedPartNumber.contains(partNumber)) {
      lessonColor = IColors.red;
    } else if (key == 1 && !checkCellGapLimit(rowNumber, columnNumber)) {
      if (widget.dayReservedTimeTable != null &&
          widget.dayReservedTimeTable[rowNumber][columnNumber] == 1) {
        lessonColor = reservedLegendItem.color;
      } else {
        if (selectedPartNumbers.contains(partNumber)) {
          lessonColor = selectedLegendItem.color;
        } else {
          lessonColor = availableLegendItem.color;
        }
      }
    } else {
      lessonColor = unavailableLegendItem.color;
    }

    return Container(
      margin: EdgeInsets.only(
          top: 1,
          right: ((columnNumber + 1) % 2) * 1.0,
          left: (columnNumber % 2) * 1.0),
      width: widget.cellWidth,
      height: widget.cellHeight,
      decoration: BoxDecoration(
        borderRadius: res,
        color: lessonColor,
      ),
    );
  }

  Widget getRowNumberText(int rowNumber) {
    BorderRadius tl = BorderRadius.only(topRight: Radius.circular(25));
    BorderRadius bl = BorderRadius.only(bottomRight: Radius.circular(25));
    BorderRadius tbl = BorderRadius.only(
        bottomRight: Radius.circular(25), topRight: Radius.circular(25));

    BorderRadius res;
    if (rowNumber == widget.startTableHour &&
        rowNumber == widget.endTableHour - 1) {
      res = tbl;
    } else if (rowNumber == widget.startTableHour) {
      res = tl;
    } else if (rowNumber == widget.endTableHour - 1) {
      res = bl;
    } else {
      res = BorderRadius.only();
    }

    return Container(
      width: widget.cellHeight,
      height: widget.cellHeight,
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
