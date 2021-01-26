import 'package:Neuronio/constants/colors.dart';
import 'package:Neuronio/constants/strings.dart';
import 'package:Neuronio/models/CalendarEvent.dart';
import 'package:Neuronio/models/DoctorPlan.dart';
import 'package:Neuronio/ui/widgets/AutoText.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/day_view.dart';
import 'package:Neuronio/ui/widgets/modifiedPackages/calendar_views-0.5.2/lib/days_page_view.dart';
import 'package:Neuronio/utils/dateTimeService.dart';
import 'package:flutter/material.dart';
import 'package:shamsi_date/shamsi_date.dart';

class DayViewExample extends StatefulWidget {
  Map<DateTime, DataSourceDailyWorkTimes> daysWorkTimes;
  bool showEventTitle;
  int daysPerPage;

  DayViewExample(this.daysWorkTimes,
      {this.showEventTitle = true, this.daysPerPage = 4});

  @override
  State createState() => new _DayViewExampleState();
}

class _DayViewExampleState extends State<DayViewExample> {
  @override
  void initState() {
    super.initState();
  }

  String _minuteOfDayToHourMinuteString(int minuteOfDay) {
    return "${(minuteOfDay ~/ 60).toString().padLeft(2, "0")}"
        ":"
        "${(minuteOfDay % 60).toString().padLeft(2, "0")}";
  }

  List<StartDurationItem> _getEventsOfDay(DateTime day) {
    List<Event> events = [];
    widget.daysWorkTimes.forEach((dateTime, daysWorkTimes) {
      if (DateTimeService.getDateStringFormDateTime(day) ==
          DateTimeService.getDateStringFormDateTime(dateTime)) {
        events = daysWorkTimes?.dataSourceWorkTimes;
      }
    });

    return events
        .map(
          (event) => new StartDurationItem(
            startMinuteOfDay: event.startMinuteOfDay,
            duration: event.duration,
            builder: (context, itemPosition, itemSize) => _eventBuilder(
              context,
              itemPosition,
              itemSize,
              event,
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    DaysPageController _daysPageController = new DaysPageController(
      firstDayOnInitialPage: DateTimeService.getCurrentDateTime(),
      daysPerPage: widget.daysPerPage,
    );
    return new DaysPageView(
      scrollDirection: Axis.horizontal,
      pageSnapping: true,
      reverse: false,
      controller: _daysPageController,
      pageBuilder: _daysPageBuilder,
    );
  }

  Widget _daysPageBuilder(BuildContext context, List<DateTime> days) {
    List<String> daysStrings =
        days.map((e) => DateTimeService.getDateStringFormDateTime(e)).toList();
    Map<DateTime, DataSourceDailyWorkTimes> daysWorkTimesPartition = {};

    widget.daysWorkTimes.forEach((dateTime, daysWorkTimes) {
      if (daysStrings
          .contains(DateTimeService.getDateStringFormDateTime(dateTime))) {
        daysWorkTimesPartition[dateTime] = daysWorkTimes;
      }
    });

    return new Container(
      child: new DayViewEssentials(
        properties:
            new DayViewProperties(days: daysWorkTimesPartition.keys.toList()),
        widths: DayViewWidths(
          daySeparationAreaWidth: 2,
          timeIndicationAreaWidth: 30,
          mainAreaStartPadding: 0,
          mainAreaEndPadding: 0,
        ),
        child: new Column(
          children: <Widget>[
            new Container(
              color: Colors.grey[200],
              child: new DayViewDaysHeader(
                headerItemBuilder: _headerItemBuilder,
              ),
            ),
            new Expanded(
              child: new SingleChildScrollView(
                child: new DayViewSchedule(
                  heightPerMinute: 0.5,
                  components: <ScheduleComponent>[
                    new TimeIndicationComponent.intervalGenerated(
                      generatedTimeIndicatorBuilder:
                          _generatedTimeIndicatorBuilder,
                    ),
                    new SupportLineComponent.intervalGenerated(
                      generatedSupportLineBuilder: _generatedSupportLineBuilder,
                    ),
                    new DaySeparationComponent(
                      generatedDaySeparatorBuilder:
                          _generatedDaySeparatorBuilder,
                    ),
                    new EventViewComponent(
                      getEventsOfDay: _getEventsOfDay,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerItemBuilder(BuildContext context, DateTime day) {
    Jalali jalali = DateTimeService.getJalaliformDateTime(day);
    return new Container(
      color: Colors.grey[300],
      padding: new EdgeInsets.symmetric(vertical: 4.0),
      child: new Column(
        children: <Widget>[
          new Text(
            "${Strings.persianDaysSigns[jalali.weekDay - 1]}",
            style: new TextStyle(fontWeight: FontWeight.bold),
            maxLines: 1,
          ),
          new Text(
            "${jalali.day}",
            maxLines: 1,
          ),
        ],
      ),
    );
  }

  Positioned _generatedTimeIndicatorBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    int minuteOfDay,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Container(
        child: new Center(
          child: new Text(
              _minuteOfDayToHourMinuteString(minuteOfDay).split(":")[0]),
        ),
      ),
    );
  }

  Positioned _generatedSupportLineBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    double itemWidth,
    int minuteOfDay,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemWidth,
      child: new Container(
        height: 0.7,
        color: Colors.grey[700],
      ),
    );
  }

  Positioned _generatedDaySeparatorBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    int daySeparatorNumber,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Center(
        child: new Container(
          width: 0.7,
          color: Colors.grey,
        ),
      ),
    );
  }

  Positioned _eventBuilder(
    BuildContext context,
    ItemPosition itemPosition,
    ItemSize itemSize,
    Event event,
  ) {
    return new Positioned(
      top: itemPosition.top,
      left: itemPosition.left,
      width: itemSize.width,
      height: itemSize.height,
      child: new Container(
        margin: new EdgeInsets.only(left: 1.0, right: 1.0, bottom: 1.0),
        padding: new EdgeInsets.all(3.0),
        color: event.color ?? IColors.themeColor,
        child: widget.showEventTitle
            ? new AutoText(
                "${event.title}",
              )
            : SizedBox(),
      ),
    );
  }
}
