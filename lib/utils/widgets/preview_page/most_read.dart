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
            child: _isGridView ? _buildGridView(widget.documents) : DocumentListView(documents : widget.documents, selectedDocuments: [], isSelectionMode: false, onLongPress: (){}, onDocumentsChanged: (){}   ),
            
          ),
        ],
      ),
    );
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
        return GestureDetector(
          onTap: () async {
            await updateMostRead(documents[index]);
          },
          child: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                  ),
                  child: Container(
                    
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: FileImage(File(documents[index].thumbnailPath)),
                        fit: BoxFit.cover,
                      ),
                    ),
                    height: MediaQuery.of(context).size.width * 0.6,
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
          ),
        );
      },
    );
  }



  @override
  void dispose() {
    super.dispose();
  }

  Future<void> updateMostRead(Document document) async {
    // Navigate to PDFViewerScreen and wait for the result
    final result = await Get.toNamed('/preview', arguments: {
      'document': document,
    });
    if (result == true) {
       setState(() {
                    context.read<DocumentBloc>().add(UpdateDocumentRead(document.path, document.lastPageRead));
                  });
    }
  }
}
