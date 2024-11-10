import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/model/document.dart';

class DocumentListView extends StatefulWidget {
  final List<Document> documents;
  final List<Document> selectedDocuments;
  final bool isSelectionMode;
  final VoidCallback onLongPress;
  final VoidCallback onDocumentsChanged; // Add this line

  DocumentListView({
    required this.documents,  
    required this.selectedDocuments,
    this.isSelectionMode = false,
    required this.onLongPress,
    required this.onDocumentsChanged, // Add this line
  });

  @override
  State<DocumentListView> createState() => _DocumentListViewState();
}

class _DocumentListViewState extends State<DocumentListView> {
  List<Document> filteredDocuments = [];

  @override
  void initState() {
    super.initState();
    filteredDocuments = widget.documents;
  }


  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4),
      itemCount: filteredDocuments.length,
      itemBuilder: (context, index) {
        String fileName = filteredDocuments[index].title; // Extract file name
        final document = filteredDocuments[index];
        final isSelected = widget.selectedDocuments.contains(document);

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Material(
            color: Theme.of(context).cardColor,
            shadowColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(6.0),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
              onTap: ()async {
                if (widget.isSelectionMode) {
                  setState(() {
                    if (isSelected) {
                      widget.selectedDocuments.remove(document);
                    } else {
                      widget.selectedDocuments.add(document);
                    }
                  });
                } else {
                 var result = await Get.toNamed('/preview', arguments: {
                    'document': document,
                  });
                  
                  if(result)
                  context.read<DocumentBloc>().add(UpdateDocumentRead(document.path , document.lastPageRead));
                }
              },
              onLongPress: () {
                widget.onLongPress();
               
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListTile(
                  minLeadingWidth: 48.0,
                  leading: widget.isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (value) {
                            setState(() {
                              if (value == true) {
                                widget.selectedDocuments.add(document);
                              } else {
                                widget.selectedDocuments.remove(document);
                              }
                            });
                          },
                        )
                      : Container(
                          color: Colors.white,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.0, end: 1.0),
                            duration: Duration(milliseconds: index * 100),
                            curve: Curves.easeOut,
                            builder: (BuildContext context, double value, Widget? child) {
                              return Opacity(
                                opacity: value,
                                child: Image(
                                  image: FileImage(
                                    File(filteredDocuments[index].thumbnailPath),
                                  ),
                                  fit: BoxFit.cover,
                                ),
                              );
                            },
                          ),
                        ),
                  title: Text(
                    fileName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 50,
                    child: Text(
                      '${filteredDocuments[index].lastPageRead}/${filteredDocuments[index].pageCount}',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).highlightColor,
                          ),
                    ),
                  ),
                  subtitle: TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: 100,
                    ),
                    duration: Duration(milliseconds: index * 300),
                    curve: Curves.easeOut,
                    builder: (context, progress, child) {
                      return LinearProgressIndicator(
                        semanticsLabel: 'Read Progress',
                        semanticsValue: '${filteredDocuments[index].lastPageRead}/${filteredDocuments[index].pageCount}',
                        value: (filteredDocuments[index].lastPageRead / filteredDocuments[index].pageCount) * progress / 100,
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        minHeight: 5.0,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }


}
