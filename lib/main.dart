import 'package:flutter/material.dart';
import 'package:readnow/pages/home.dart';
import 'package:readnow/themes/theme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PDF Reader',
      theme: AppTheme.lightTheme,
      home: PdfListScreen(),
    );
  }
}
