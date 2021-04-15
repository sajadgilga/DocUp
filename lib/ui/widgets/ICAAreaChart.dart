import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class AreaData {
  final String title;
  final int age;
  final double lower2;
  final double lower;
  final double halfUpper;
  final double avg = 1;

  AreaData(this.title, this.age,
      {this.lower2 = 0, this.lower = 0, this.halfUpper = 0});
}

class ICAAreaChart extends StatefulWidget {
  final int age;
  final int icaIndex;

  const ICAAreaChart({Key key, this.age, this.icaIndex}) : super(key: key);

  @override
  _ICAAreaChartState createState() => _ICAAreaChartState();
}

class _ICAAreaChartState extends State<ICAAreaChart> {
  @override
  Widget build(BuildContext context) {
    return Center(
        child: SfCartesianChart(
      legend: Legend(
          isVisible: true,
          alignment: ChartAlignment.center,
          position: LegendPosition.bottom,
          isResponsive: true,
          orientation: LegendItemOrientation.horizontal,
          overflowMode: LegendItemOverflowMode.scroll,
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
      series: getDefaultData(),
      tooltipBehavior: TooltipBehavior(enable: true),
    ));
  }

  List<AreaData> get icaCognitiveAreaChartData {
    return <AreaData>[
      AreaData('0', 0, lower2: 50.5, lower: 19, halfUpper: 9.55),
      AreaData('20-30', 25, lower2: 50.5, lower: 19, halfUpper: 9.55),
      AreaData('30-40', 35, lower2: 49.12, lower: 19.98, halfUpper: 10),
      AreaData('40-50', 45, lower2: 43.02, lower: 22.28, halfUpper: 11.1),
      AreaData('50-60', 55, lower2: 41.00, lower: 20.7, halfUpper: 8),
      AreaData('60-70', 65, lower2: 36.42, lower: 19.88, halfUpper: 9.95),
      AreaData('70-80', 75, lower2: 36.00, lower: 20.3, halfUpper: 8.55),
      AreaData('>80', 95, lower2: 35.00, lower: 18, halfUpper: 7.95),
    ];
  }

  List<XyDataSeries<AreaData, num>> getDefaultData() {
    return <XyDataSeries<AreaData, num>>[
          StackedAreaSeries<AreaData, num>(
              dataSource: icaCognitiveAreaChartData,
              xValueMapper: (AreaData sales, _) => sales.age,
              yValueMapper: (AreaData sales, _) => sales.lower2,
              color: Color.fromARGB(255, 242, 142, 134),
              legendItemText: "اختلال شناختی "),
          StackedAreaSeries<AreaData, num>(
              dataSource: icaCognitiveAreaChartData,
              xValueMapper: (AreaData sales, _) => sales.age,
              yValueMapper: (AreaData sales, _) => sales.lower,
              color: Color.fromARGB(255, 251, 188, 4),
              legendItemText: "در خطر"),
          StackedAreaSeries<AreaData, num>(
              dataSource: icaCognitiveAreaChartData,
              xValueMapper: (AreaData sales, _) => sales.age,
              yValueMapper: (AreaData sales, _) => sales.halfUpper,
              color: Color.fromARGB(255, 122, 214, 147),
              legendItemText: "سالم"),
          StackedAreaSeries<AreaData, num>(
              dataSource: icaCognitiveAreaChartData,
              xValueMapper: (AreaData sales, _) => sales.age,
              yValueMapper: (AreaData sales, _) => sales.avg,
              color: Color.fromARGB(255, 26, 84, 41),
              isVisibleInLegend: false),
          StackedAreaSeries<AreaData, num>(
              dataSource: icaCognitiveAreaChartData,
              xValueMapper: (AreaData sales, _) => sales.age,
              yValueMapper: (AreaData sales, _) => sales.halfUpper,
              color: Color.fromARGB(255, 122, 214, 147),
              isVisibleInLegend: false),
        ] +
        (widget.icaIndex != null && widget.age != null
            ? <XyDataSeries<AreaData, num>>[
                ScatterSeries<AreaData, num>(
                    dataSource: icaCognitiveAreaChartData,
                    xValueMapper: (AreaData sales, _) => widget.age,
                    yValueMapper: (AreaData sales, _) => widget.icaIndex,
                    color: Colors.black,
                    isVisibleInLegend: false,
                    markerSettings: MarkerSettings(
                        isVisible: true,
                        height: 10,
                        width: 10,
                        shape: DataMarkerType.circle,
                        borderWidth: 3,
                        borderColor: Colors.black),
                    dataLabelSettings: DataLabelSettings(
                        opacity: 1,
                        labelAlignment: ChartDataLabelAlignment.auto))
              ]
            : <XyDataSeries<AreaData, num>>[]);
  }
}
