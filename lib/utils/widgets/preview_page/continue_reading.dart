import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';

class ContinueReading extends StatelessWidget {
final lastDocumentRead ;
  ContinueReading({Key? key, this.lastDocumentRead}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DocumentBloc, DocumentState>(
      builder: (context, state) {
        if (state is DocumentLoaded) {
          
          return ListTile(
            tileColor: Theme.of(context).cardColor,
            minVerticalPadding: 30.0,
            splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
            horizontalTitleGap: 14.0,
            onTap: () async {
              var result = await Get.toNamed('/preview', arguments: {
                'document': lastDocumentRead,
              });

              if (result) {
                context.read<DocumentBloc>().add(UpdateDocumentRead(lastDocumentRead));
          
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
                      File(lastDocumentRead.thumbnailPath),
                    ),
                  ),
                ),
              ),
            ),
            title: Text(
              lastDocumentRead.title,
              style: Theme.of(context).textTheme.titleMedium,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  'Last Read: ${_formatLastRead(lastDocumentRead.lastRead!)}',
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).highlightColor.withOpacity(0.7),
                      ),
                ),
                SizedBox(height: 20.0),
                TweenAnimationBuilder<int>(
                  tween: IntTween(
                    begin: 0,
                    end: 100,
                  ),
                  duration: Duration(milliseconds: 2000),
                  curve: Curves.easeOut,
                  builder: (context, progress, child) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 10,
                          child: LinearProgressIndicator(
                            semanticsLabel: 'Read Progress',
                            semanticsValue: '${lastDocumentRead.lastPageRead}/${lastDocumentRead.pageCount}',
                            value: (lastDocumentRead.lastPageRead / lastDocumentRead.pageCount) * progress / 100,
                            valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                            backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                            minHeight: 5.0,
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      SizedBox(width: 10.0,),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '${lastDocumentRead.lastPageRead}/${lastDocumentRead.pageCount}',
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                  color: Theme.of(context).highlightColor,
                                ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
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
