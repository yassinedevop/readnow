import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/pages/preview.dart';

class ContinueReading extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoaded) {
          Document? lastReadDocument = _getLastReadDocument(state.documents);
          if (lastReadDocument != null) {
            return Container(
              margin: EdgeInsets.all(8),
              color: Colors.white30,
              child: InkWell(
                 highlightColor : Theme.of(context).colorScheme.secondary,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => PDFViewerScreen(pdfName: lastReadDocument.title, pdfPath: lastReadDocument.path)));
                },
                child: Row(
                  children: [
                    Container(
                      width: 100,
                      height: 150,
                      color: Colors.white,
                      child: Image.file(File(lastReadDocument.thumbnailPath), fit: BoxFit.cover),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lastReadDocument.title,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Last Read: ${_formatLastRead(lastReadDocument.lastRead)}',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else {
            return Center(child: Text('No recently read documents'));
          }
        } else if (state is DocumentLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is DocumentError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return Center(child: Text('No documents found'));
        }
      },
    );
  }

  Document? _getLastReadDocument(List<Document> documents) {
    documents.sort((a, b) => b.lastRead?.compareTo(a.lastRead ?? DateTime(1970)) ?? 0);
    return documents.isNotEmpty ? documents.first : null;
  }

  String _formatLastRead(DateTime? lastRead) {
    if (lastRead == null) return 'Never';
    final now = DateTime.now();
    final difference = now.difference(lastRead);
    if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }
}
