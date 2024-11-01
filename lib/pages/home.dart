import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/utils/widgets/continue_reading.dart';
import 'package:readnow/utils/widgets/most_read.dart';

class PdfListScreen extends StatefulWidget {
  @override
  _PdfListScreenState createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch PDFs when the screen initializes
    context.read<DocumentBloc>().add(LoadDocuments());
  }

  Future<void> _refresh() async {
    context.read<DocumentBloc>().add(LoadDocuments());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('PDF List'),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              ContinueReading(),
              MostReadBooks(),
            ],
          ),
        ),
      ),
    );
  }
}
