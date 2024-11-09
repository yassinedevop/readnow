import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:readnow/model/document.dart';

class ContinueReading extends StatelessWidget {
  final List<Document> documents;
  final Function refreshDocuments;

  ContinueReading({required this.documents, required this.refreshDocuments});

  @override
  Widget build(BuildContext context) {
    Document? lastReadDocument = _getLastReadDocument(documents);
    if (lastReadDocument != null) {
      return Container(
        margin: EdgeInsets.all(8),
        color: Get.theme.colorScheme.secondary.withOpacity(0.1),
        child: ListTile(
          contentPadding: EdgeInsets.all(8),
          onTap: () async {
            // Navigate to PDFViewerScreen and wait for the result
            final result = await Get.toNamed('/preview', arguments: {
              'document': lastReadDocument,
            });
            if (result == true) {
              // Refresh the document list if the result is true
              refreshDocuments();
            }
          },
          leading: Transform.scale(
            scale: 2.0,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.transparent,
                image: DecorationImage(
                  image: FileImage(
                    File(lastReadDocument.thumbnailPath),
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            lastReadDocument.title,
            style: Theme.of(context).textTheme.titleMedium,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8),
              TweenAnimationBuilder<int>(
                tween: IntTween(
                  begin: 0,
                  end: 100,
                ),
                duration: Duration(milliseconds: 2000),
                curve: Curves.easeOut,
                builder: (context, progress, child) {
                  return LinearProgressIndicator(
                    semanticsLabel: 'Read Progress',
                    semanticsValue: '${lastReadDocument.lastPageRead}/${lastReadDocument.pageCount}',
                    value: (lastReadDocument.lastPageRead / lastReadDocument.pageCount) * progress / 100,
                    valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                    minHeight: 5.0,
                    borderRadius: BorderRadius.circular(12),
                  );
                },
              ),
              SizedBox(height: 8),
              Text(
                'Last Read: ${_formatLastRead(lastReadDocument.lastRead)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(child: Text('No recently read documents'));
    }
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
