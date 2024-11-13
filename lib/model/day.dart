

import 'dart:math';

class BooksWithReadTime {
  final String title;
  final String dateTime = DateTime.now().toIso8601String();
  int readCount;
  int duration; // in minutes

  BooksWithReadTime({required this.title, this.readCount = 1, this.duration = 0});

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'dateTime': dateTime,
      'readCount': readCount,
      'duration': duration,
    };
  }

  factory BooksWithReadTime.fromJson(Map<String, dynamic> json) {
    return BooksWithReadTime(
      title: json['title'],
      readCount: json['readCount'] ?? 1,
      duration: json['duration'] ?? 0,
    );
  }
}



class Day {

  final String id;
  final String date;
   int readCount;
   int pageCount;
   int duration;
   List<BooksWithReadTime> booksRead;

  Day({
    String? id,
    this.date = '',
    this.readCount = 0,
    this.pageCount = 0,
    this.duration = 0,
    this.booksRead = const [],
  }) : id = id ?? _generateId();

  static String _generateId() {
    final random = Random();
    return DateTime.now().millisecondsSinceEpoch.toString() + random.nextInt(1000).toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'readCount': readCount,
      'pageCount': pageCount,
      'duration': duration,
      'booksRead': booksRead.map((book) => book.toJson()).toList(),
    };
  }

  factory Day.fromJson(Map<String, dynamic> json) {
    return Day(
      id: json['id'],
      date: json['date'],
      readCount: json['readCount'],
      pageCount: json['pageCount'],
      duration: json['duration'],
      booksRead: (json['booksRead'] as List).map((book) => BooksWithReadTime.fromJson(book)).toList(),
    );
  }
}