import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:readnow/main.dart';
import 'package:readnow/model/day.dart';

class ReadingTimeBarChart extends StatelessWidget {
  final List<Day> days;

  ReadingTimeBarChart({required this.days});

  @override
  Widget build(BuildContext context) {
    List<Day> lastMonthDays = _filterLastMonthDays(days);
    double maxY = _getMaxY(lastMonthDays);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        barGroups: _getReadingTime(lastMonthDays),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        borderData: FlBorderData(show: true),
        maxY: maxY,
      ),
    );
  }

  List<Day> _filterLastMonthDays(List<Day> days) {
    DateTime now = DateTime.now();
    DateTime lastMonth = DateTime(now.year, now.month - 1, now.day);
    return days.where((day) => DateTime.parse(day.date).isAfter(lastMonth)).toList();
  }

  double _getMaxY(List<Day> days) {
    return days.map((day) => day.duration.toDouble()).reduce((a, b) => a > b ? a : b);
  }

  List<BarChartGroupData> _getReadingTime(List<Day> days) {
    List<BarChartGroupData> barGroups = [];
    for (int i = 0; i < days.length; i++) {
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: days[i].duration.toDouble(),
              color: AppTheme.lightTheme.primaryColor,
            ),
          ],
        ),
      );
    }
    return barGroups;
  }
}
