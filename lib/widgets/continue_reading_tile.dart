import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readnow/model/document.dart';
import 'dart:io';

class ContinueReadingTile extends StatelessWidget {
  final Document document;
  final Function refreshDocuments;

  ContinueReadingTile({required this.document, required this.refreshDocuments});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.all(8),
      onTap: () async {
        // Navigate to PDFViewerScreen and wait for the result
        final result = await Get.toNamed('/preview', arguments: {
          'document': document,
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
                File(document.thumbnailPath),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        document.title,
        style: Theme.of(context).textTheme.titleMedium,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(
              begin: 0.0,
              end: (document.lastPageRead / document.pageCount),
            ),
            duration: Duration(milliseconds: 2000),
            curve: Curves.easeOut,
            builder: (context, progress, child) {
              return LinearProgressIndicator(
                semanticsLabel: 'Read Progress',
                semanticsValue: '${document.lastPageRead}/${document.pageCount}',
                value: progress,
                valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                minHeight: 5.0,
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            'Last Read: ${_formatLastRead(document.lastRead)}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
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
