import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/utils/widgets/preview_page/continue_reading.dart';
import 'package:readnow/utils/widgets/preview_page/most_read.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
      body: BlocBuilder<DocumentBloc, DocumentState>(
        builder: (context, state) {
    
          if (state is DocumentLoaded) {
            return RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ContinueReading(lastDocumentRead: state.lastReadDocument!),
                    MostReadBooks(documents: state.documents),
                  ],
                ),
              ),
            );
          } else if (state is DocumentLoading) {
            return Center(child: CircularProgressIndicator());
          } else {
            return Center(child: Text('Failed to load documents'));
          }
        },
      ),
    );
  }
}
