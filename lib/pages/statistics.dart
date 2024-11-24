import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:readnow/model/day.dart';
import 'package:readnow/utils/widgets/statistics_page/reading_progress_line_chart.dart';
import 'package:readnow/utils/widgets/statistics_page/reading_progress_bar_chart.dart';
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
  

            return SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      child: ReadingProgressBarChart(days: days),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      height: 300,
                      child: ReadingProgressLineChart(days: days),
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



}
