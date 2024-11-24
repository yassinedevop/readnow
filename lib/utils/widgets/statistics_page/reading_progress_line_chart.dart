import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:readnow/model/day.dart';
import 'package:readnow/main.dart';

class ReadingProgressLineChart extends StatefulWidget {
  final List<Day> days;

  ReadingProgressLineChart({required this.days});

  @override
  State<ReadingProgressLineChart> createState() => _ReadingProgressLineChartState();
}

class _ReadingProgressLineChartState extends State<ReadingProgressLineChart> {
  List<Color> gradientColors = [
    AppTheme.lightTheme.cardColor.withOpacity(0.4),
      AppTheme.lightTheme.primaryColor.withOpacity(0.5),

     AppTheme.lightTheme.primaryColor.withOpacity(0.7),

    
    AppTheme.lightTheme.primaryColor,
  ];
     List<Day> daysOverMonth = []; 

  bool showAvg = false;

  @override
  Widget build(BuildContext context) {
    return Card(
 
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          children: [
              Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.symmetric(horizontal : 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Reading ',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                                        const SizedBox(
                      height: 4,
                    ),
                    Text(
                      'Pages read in the last 30 days',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).primaryColor,
                      ), ),
                    const SizedBox(
                      height: 38,
                    ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Padding(
                     padding: const EdgeInsets.symmetric(horizontal : 10.0),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        style: ElevatedButton.styleFrom(
                          
                          
                          backgroundColor:                   
                              Theme.of(context).primaryColor.withOpacity( showAvg ? 1.0 : 0.4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        onPressed: () {
                          setState(() {
                            showAvg = !showAvg;
                          });
                        },
                        child: Text(
                          'Average',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 24,
                  left: 24,
               
             
                ),
                child: LineChart(
                  generateLineChartData(showAvg: showAvg),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  int map30ToToday(int day) {
    DateTime now = DateTime.now();
    DateTime oneMonthAgo = now.subtract(Duration(days: 30)); // Last 30 days inclusive
    return oneMonthAgo.add(Duration(days: day)).day;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
   

    return Text(map30ToToday(value.toInt()).toString(), textAlign: TextAlign.left);
  }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    if (value % 2 == 0) {
      return Text(value.toInt().toString(), style: Theme.of(context).textTheme.bodyMedium);
    }
    return Container();
  }

  LineChartData generateLineChartData({required bool showAvg}) {
    List<FlSpot> spots = _getReadingProgress(widget.days);
    double maxY = widget.days.map((d) => d.readCount).reduce((a, b) => a > b ? a : b).toDouble();
    double avgY = spots.map((spot) => spot.y).reduce((a, b) => a + b) / spots.length;

    return LineChartData(
      lineTouchData:  LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (touchedSpot) => Theme.of(context).primaryColor.withOpacity(0.7),
          getTooltipItems: (List<LineBarSpot> touchedSpots) {
            return touchedSpots.map((spot) {
              return LineTooltipItem(
                'Day ${map30ToToday(spot.x.toInt())}\n${spot.y.toInt()} pages',
                Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
              );
            }).toList();
          },
        ),
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
            getTitlesWidget: bottomTitleWidgets,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 1,
            getTitlesWidget: leftTitleWidgets,
            reservedSize: 18,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border(
          left: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.7), width: 3),
          bottom: BorderSide(color: Theme.of(context).primaryColor.withOpacity(0.7), width: 3),
          top: BorderSide.none,
          right: BorderSide.none,
        ),
      ),
      gridData: FlGridData(show: false),
      minX: 1,
      maxX: spots.length.toDouble(),
      minY: -1,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: showAvg ? List.generate(spots.length, (index) => FlSpot(spots[index].x, avgY)) : spots,
          isCurved: true,
          gradient: LinearGradient(
            colors: showAvg
                ? [
                    ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.7)!,
                    ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.4)!,
                  ]
                : gradientColors,
          ),
          barWidth: showAvg ? 5 : 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: showAvg
                  ? [
                      ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.2)!.withOpacity(0.4),
                      ColorTween(begin: gradientColors[0], end: gradientColors[1]).lerp(0.5)!,
                    ]
                  : gradientColors.map((color) => color.withOpacity(0.5)).toList(),
            ),
          ),
        ),
      ],
    );
  }

List<FlSpot> _getReadingProgress(List<Day> days) {
  List<FlSpot> spots = [];
  DateTime now = DateTime.now();
  DateTime oneMonthAgo = now.subtract(Duration(days: 29)); // Last 30 days inclusive
  List<Day> lastMonthReadDays = days.where((d) => DateTime.parse(d.date).isAfter(oneMonthAgo)).toList();
  
  for (int i = 0; i < 30; i++) {
    DateTime currentDate = oneMonthAgo.add(Duration(days: i));
    var thatDay = lastMonthReadDays.firstWhere(
      (d) => DateTime.parse(d.date).day == currentDate.day && DateTime.parse(d.date).month == currentDate.month,
      orElse: () => Day(date: currentDate.toString(), readCount: 0),
    );

    final readCount = thatDay.readCount;
    // Map the days to [1, 30] range with today as 30
    spots.add(FlSpot((i + 1).toDouble(), readCount.toDouble()));
  }
  return spots;
}

}
