import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/pages/home.dart';
import 'package:readnow/themes/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(MyApp());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DocumentBloc()..add(LoadDocuments()),
      child: MaterialApp(
        title: 'ReadNow',
        theme: AppTheme.darkTheme,
        home: PdfListScreen(),
      ),
    );
  }
}
