import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/pages/home.dart';
import 'package:readnow/pages/preview.dart';
import 'package:readnow/pages/statistics.dart';
import 'package:flutter/services.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  const platform = MethodChannel('com.example.readnow/pdf');
  platform.setMethodCallHandler((call) async {
    if (call.method == 'openPDF') {
      final String filePath = call.arguments;
      Get.to(() => PDFViewerScreen(), arguments: Document.fromPath(filePath) );
    }
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentBloc()..add(LoadDocuments()),
      child: GetMaterialApp(
        title: 'Read Now',
        theme: AppTheme.darkTheme,
        home: HomePage(),
        debugShowCheckedModeBanner: false,
        getPages: [
          GetPage(name: '/', page: () => HomePage()),
          GetPage(name: '/preview', page: () => PDFViewerScreen()),
          GetPage(name: '/statistics', page: () => StatisticsPage()), // Add this line
        ],
      ),
    );
  }
}

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    primaryColor: Color(0xFF6368EC), // Primary color
    scaffoldBackgroundColor: Color(0xFF0f1923), // Background color
    cardColor: Color(0xFF1A253B), // Cards color
    textTheme: TextTheme(
      displayLarge: GoogleFonts.lato(
        textStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      bodyLarge: GoogleFonts.roboto(
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      bodyMedium: GoogleFonts.openSans(
        textStyle: TextStyle(color: Colors.white, fontSize: 14),
      ),
      titleMedium: GoogleFonts.montserrat(
        textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF6368EC), // Primary color
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF6368EC), // Primary color
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6368EC), // Primary color
    ),
    colorScheme: ColorScheme.light(
      primary: Color(0xFF6368EC), // Primary color
      secondary: Color(0xFF6368EC), // Primary color
      surface: Color(0xFF1A253B), // Cards color
    ),

    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Color(0xFF0f1923),
      indicatorColor: Color(0xFF6368EC),
     shadowColor: Colors.white30,
     overlayColor:WidgetStatePropertyAll(Color(0xFF6368EC)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF1A253B), // Cards color
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );

  static final ThemeData darkTheme = ThemeData(
    shadowColor: Colors.white30,
    primaryColor: Color(0xFF6368EC), // Primary color
    scaffoldBackgroundColor: Color(0xFF0f1923), // Background color
    cardColor: Color(0xFF1A253B), // Cards color
    textTheme: TextTheme(
      displayLarge: GoogleFonts.lato(
        textStyle: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      bodyLarge: GoogleFonts.roboto(
        textStyle: TextStyle(color: Colors.white, fontSize: 16),
      ),
      bodyMedium: GoogleFonts.openSans(
        textStyle: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
      ),
      titleMedium: GoogleFonts.montserrat(
        textStyle: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
      ),
    ),
    buttonTheme: ButtonThemeData(
      buttonColor: Color(0xFF6368EC), // Primary color
      textTheme: ButtonTextTheme.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Color(0xFF0f1923), // Primary color
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF6368EC), // Primary color
    ),
    colorScheme: ColorScheme.dark(
      primary: Color(0xFF6368EC), // Primary color
      secondary: Color(0xFF6368EC), // Primary color
      surface: Color(0xFF1A253B), // Cards color
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Color(0xFF1A253B), // Cards color
      contentTextStyle: TextStyle(color: Colors.white),
    ),
  );
}