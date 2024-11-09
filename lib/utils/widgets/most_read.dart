import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:readnow/model/document.dart';


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
  final Function refreshDocuments;

  MostReadBooks({required this.documents, required this.refreshDocuments});

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
            child: _isGridView ? _buildGridView(widget.documents) : _buildListView(widget.documents),
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

  Widget _buildListView(List<Document> documents) {
    return ListView.builder(
      padding: EdgeInsets.symmetric( vertical: 4),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        String fileName = documents[index].title; // Extract file name
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Material(
            color : Theme.of(context).cardColor,
            shadowColor:Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2, 
            
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
                highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
                onTap: () async {
                 await  updateMostRead(documents[index]);
                },
                child: ListTile(
                  minLeadingWidth: 48.0,
                  
                  leading: Container(
                   color: Colors.white,
                  /*   decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                      image: DecorationImage(
                        image: FileImage(File(documents[index].thumbnailPath)),
                        fit: BoxFit.cover,
                      ),
                    ), */
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end:  1.0),
                      
                      duration: Duration(
                        milliseconds: index * 100,
                      ),
                      curve: Curves.easeOut,
                      builder: (BuildContext context, double value, Widget? child) { 
                        return Opacity(
                          opacity: value,
                          child: Image(
                            image: FileImage(
                              File(documents[index].thumbnailPath),
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
                    
                      '${documents[index].lastPageRead}/${documents[index].pageCount}'
                      ,
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
          duration: Duration(milliseconds: index*300),
          curve: Curves.easeOut,
          builder: (context, progress, child) {
            return LinearProgressIndicator(
              semanticsLabel: 'Read Progress',
              semanticsValue: '${documents[index].lastPageRead}/${documents[index].pageCount}',
              value: (documents[index].lastPageRead/documents[index].pageCount)*progress/100,
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
      // Refresh the document list if the result is true
      widget.refreshDocuments();
    }
  }
}
