import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/document_list.dart';

class ContinueReading extends StatelessWidget {
  final Document lastDocumentRead;

  ContinueReading({required this.lastDocumentRead});

  @override
  Widget build(BuildContext context) {
    return DocumentListTile(
      document: lastDocumentRead,
      onTap: () {
        Get.toNamed('/preview', arguments: lastDocumentRead);
      },
    
      isSelected: false,
      isSelectionMode: false,
      onLongPress: () {},
      onCheckboxChanged: (bool? value) {},
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
