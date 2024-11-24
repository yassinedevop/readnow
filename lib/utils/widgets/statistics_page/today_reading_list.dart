import 'package:flutter/material.dart';
import 'package:readnow/model/day.dart';

class TodayReadingList extends StatelessWidget {
  final Day todayStats;

  TodayReadingList({required this.todayStats});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: todayStats.booksRead.length,
      itemBuilder: (context, index) {
        final book = todayStats.booksRead[index];
        return ListTile(
          title: Text(book.title),
          subtitle: Text('Time spent: ${book.duration} minutes'),
        );
      },
    );
  }
}
