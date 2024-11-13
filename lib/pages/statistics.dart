import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:readnow/main.dart';
import 'package:readnow/model/day.dart';

import 'package:shared_preferences/shared_preferences.dart';


Future<List<Day>> _getDaysFromLocal() async {
  final prefs = await SharedPreferences.getInstance();
  final List<String>? daysStringList = prefs.getStringList('days');
  if (daysStringList == null) return [];

  return daysStringList.map((dayString) => Day.fromJson(jsonDecode(dayString))).toList();
}

class StatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistics'),
      ),
      body: FutureBuilder<List<Day>>(
        future: _getDaysFromLocal(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load statistics'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No statistics available'));
          } else {
            final days = snapshot.data!;
            final today = DateTime.now().toIso8601String().split('T').first;
            final todayStats = days.firstWhere((day) => day.date == today, orElse: () => Day());

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Reading Progress Over the Week',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: _getReadingProgress(days),
                            isCurved: true,
                            color: Theme.of(context).primaryColor,
                            barWidth: 4,
                            belowBarData: BarAreaData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Time Spent Reading Over the Week',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        barGroups: _getReadingTime(days),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                        ),
                        borderData: FlBorderData(show: true),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Time Spent Reading Today',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: todayStats.booksRead.length,
                      itemBuilder: (context, index) {
                        final book = todayStats.booksRead[index];
                        return ListTile(
                          title: Text(book.title),
                          subtitle: Text('Time spent: ${book.duration} minutes'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }

  List<FlSpot> _getReadingProgress(List<Day> days) {
    // Calculate reading progress based on readCount
    List<FlSpot> spots = [];
    for (int i = 0; i < days.length; i++) {
      spots.add(FlSpot(i.toDouble(), days[i].readCount.toDouble()));
    }
    return spots;
  }

  List<BarChartGroupData> _getReadingTime(List<Day> days) {
    // Calculate reading time based on duration
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
