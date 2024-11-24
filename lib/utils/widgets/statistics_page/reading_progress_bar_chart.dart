import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:readnow/main.dart';
import 'package:readnow/model/day.dart';


class ReadingProgressBarChart extends StatefulWidget {
  final List<Day> days;

  ReadingProgressBarChart({required this.days});

  final Color barBackgroundColor =
AppTheme.lightTheme.primaryColor.withOpacity(0.3);
  final Color barColor = AppTheme.lightTheme.secondaryHeaderColor;
  final Color touchedBarColor = AppTheme.lightTheme.primaryColor;

  @override
  State<StatefulWidget> createState() => ReadingProgressBarChartState();
}

class ReadingProgressBarChartState extends State<ReadingProgressBarChart> {
  final Duration animDuration = const Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  List<Day> get lastWeekDays {
    DateTime today = DateTime.now();
    DateTime oneWeekAgo = today.subtract(Duration(days: 6));
    return widget.days.where((day) {
      DateTime dayDate = DateTime.parse(day.date);
      return dayDate.isAfter(oneWeekAgo) && dayDate.isBefore(today.add(Duration(days: 1)));
    }).toList();
  }

  final chartKey = GlobalKey();
  @override
  void dispose() {
    isPlaying = false;
    chartKey.currentState?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Reading',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                                      const SizedBox(
                    height: 4,
                  ),
                  Text(
                    'Pages read in the last 7 days',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).primaryColor,
                    ), ),
                  const SizedBox(
                    height: 38,
                  ),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: BarChart(
                       mainBarData(),
                       chartRendererKey : chartKey,
                      swapAnimationDuration: animDuration,
                      
                    ),
                  ),
                ),
                const SizedBox(
                  height: 12,
                ),
              ],
            ),
          ),
         
        ],
      ),
    );
  }

  BarChartGroupData makeGroupData(
    int x,
    double y, {
    bool isTouched = false,
    Color? barColor,
    double width = 22,
    List<int> showTooltips = const [],
  }) {
    barColor ??= widget.barColor;
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched ? y + 1 : y,
          color: isTouched ?  barColor :  widget.touchedBarColor ,
          width: width,
          
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 10,
            color: widget.barBackgroundColor,
          ),
        ),
      ],
      showingTooltipIndicators: showTooltips,
    );
  }

  List<BarChartGroupData> showingGroups() {
    DateTime today = DateTime.now();
    return List.generate(7, (i) {
      DateTime day = today.subtract(Duration(days: 6 - i));
      var thatDay = lastWeekDays.firstWhere(
        (d) => DateTime.parse(d.date).day == day.day,
        orElse: () => Day(date: day.toString(), readCount: 0),
      );
      return makeGroupData(i, thatDay.readCount.toDouble(), isTouched: i == touchedIndex);
    });
  }

  BarChartData mainBarData() {
    return BarChartData(
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipColor: (_) => Theme.of(context).primaryColor.withOpacity(0.7),
          tooltipHorizontalAlignment: FLHorizontalAlignment.right,
    
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            String weekDay = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][group.x];
            return BarTooltipItem(
              '$weekDay\n',
              Theme.of(context).textTheme.titleSmall!,
              children: <TextSpan>[
                TextSpan(
                  text: (rod.toY.toInt()).toString(),
                  style: Theme.of(context).textTheme.bodyLarge
                ),
              ],
            );
          },
        ),
        touchCallback: (FlTouchEvent event, barTouchResponse) {
          setState(() {
            if (!event.isInterestedForInteractions ||
                barTouchResponse == null ||
                barTouchResponse.spot == null) {
              touchedIndex = -1;
              return;
            }
            touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
          });
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: getTitles,
            reservedSize: 38,
          ),
        ),
        leftTitles: const AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      barGroups: showingGroups(),
      gridData: const FlGridData(show: false),
    );
  }

  Widget getTitles(double value, TitleMeta meta) {
    final style = Theme.of(context).textTheme.bodyMedium;
    Widget text;
    if (value.toInt() < 7) {
      DateTime today = DateTime.now();
      DateTime day = today.subtract(Duration(days: 6 - value.toInt()));
      text = Text(['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day.weekday - 1], style: style);
    } else {
      text =  Text('', style: style);
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }


  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(
      animDuration + const Duration(milliseconds: 150),
    );
    if (isPlaying) {
      await refreshState();
    }
  }
}
