import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/continue_reading.dart';
import 'package:readnow/utils/widgets/most_read.dart';

class PdfListScreen extends StatefulWidget {
  @override
  _PdfListScreenState createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {
  List<Document> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    context.read<DocumentBloc>().add(LoadDocuments());
  }

  Future<void> _refresh() async {
    await _loadDocuments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text('Read Now'),
      ),
      body: BlocListener<DocumentBloc, DocumentState>(
        listener: (context, state) {
          if (state is DocumentLoaded) {
            setState(() {
              _documents = state.documents;
            });
          }
        },
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: SingleChildScrollView(
            child: Column(
              children: [
                ContinueReading(documents: _documents, refreshDocuments: _refresh),
                MostReadBooks(documents: _documents, refreshDocuments: _refresh),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
