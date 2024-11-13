import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/document_list.dart';


class ToggleGridView extends StatelessWidget {
  final bool isGridView;
  final Function onPressed;

  ToggleGridView({required this.isGridView, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(isGridView ? Icons.list : Icons.grid_on),
      onPressed: () => onPressed(),
    );
  }
}
class MostReadBooks extends StatefulWidget {
  final List<Document> documents;

  MostReadBooks({required this.documents});

  @override
  _MostReadBooksState createState() => _MostReadBooksState();
}
    class _MostReadBooksState extends State<MostReadBooks> {
      bool _isGridView = false;

      @override
      Widget build(BuildContext context) {
        List<Document> topMostReadBooks = _getTopMostReadBooks(widget.documents);

        return Container(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Most Read',
                    style: Theme.of(context).textTheme.displayLarge,
                  ),
                  Spacer(),
                  ToggleGridView(
                    isGridView: _isGridView,
                    onPressed: () {
                      setState(() {
                        _isGridView = !_isGridView;
                      });
                    },
                  ),
                ],
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height * 0.6,
                child: _isGridView ? _buildGridView(topMostReadBooks) : DocumentListView(documents: topMostReadBooks, selectedDocuments: [], isSelectionMode: false, onLongPress: (){}, onDocumentsChanged: (){}),
              ),
            ],
          ),
        );
      }

      List<Document> _getTopMostReadBooks(List<Document> documents) {
        // Sort documents by readCount in descending order and take the top 20
        documents.sort((a, b) => b.readCount.compareTo(a.readCount));
        return documents.take(20).toList();
      }

      Widget _buildGridView(List<Document> documents) {
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 7 / 10,
            crossAxisCount: 2,
          ),
          itemCount: documents.length,
          itemBuilder: (context, index) {
            String fileName = documents[index].title; // Extract file name
            return Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8.0),
                            image: DecorationImage(
                              image: FileImage(File(documents[index].thumbnailPath)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8.0),
                            splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                            highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
                            onTap: () async {
                              var result = await Get.toNamed('/preview', arguments: {
                                'document': documents[index],
                              });

                              if (result)
                                context.read<DocumentBloc>().add(UpdateDocumentRead(documents[index]));
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    fileName,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            );
          },
        );
      }

      @override
      void dispose() {
        super.dispose();
      }
    }
