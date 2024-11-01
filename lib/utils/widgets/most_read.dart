import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/pages/preview.dart';



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
  @override
  _MostReadBooksState createState() => _MostReadBooksState();
}

class _MostReadBooksState extends State<MostReadBooks> {
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    // Load documents when the widget is initialized
    context.read<DocumentBloc>().add(LoadDocuments());
  }

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
                style: Theme.of(context).textTheme.titleLarge,
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
            child: BlocBuilder<DocumentBloc, DocumentState>(
              builder: (context, state) {
                if (state is DocumentLoading) {
                  return Center(child: CircularProgressIndicator());
                } else if (state is DocumentLoaded) {
                  List<Document> sortedDocuments = List.from(state.documents);
                  sortedDocuments.sort((a, b) => b.readCount.compareTo(a.readCount));
                  return _isGridView ? _buildGridView(sortedDocuments) : _buildListView(sortedDocuments);
                } else if (state is DocumentError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else {
                  return Center(child: Text('No documents found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildGridView(List<Document> documents) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 0.65,
        crossAxisCount: 2,
      ),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        String fileName = documents[index].title; // Extract file name
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
        
          ),
          child: InkWell(
            radius: 15,
            borderRadius: BorderRadius.circular(15),
            splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
            onTap: () async {
              // Update the last read time and read count
              context.read<DocumentBloc>().add(UpdateDocumentRead(documents[index].path));
              // Navigate to PDFViewerScreen and wait for the result
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PDFViewerScreen(
                    pdfPath: documents[index].path,
                    pdfName: documents[index].title,
                  ),
                ),
              );
              if (result == true) {
                // Refresh the document list if the result is true
                context.read<DocumentBloc>().add(LoadDocuments());
              }
            },
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(File(documents[index].thumbnailPath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                  
                  height: MediaQuery.of(context).size.width * 0.6,
                ),
                Text(
                  fileName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
 Widget _buildListView(List<Document> documents) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        String fileName = documents[index].title; // Extract file name
        return InkWell(
          splashColor: Theme.of(context).primaryColor.withOpacity(0.5) ,
          highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
          onTap: () async {
            // Update the last read time and read count
            context.read<DocumentBloc>().add(UpdateDocumentRead(documents[index].path));
            // Navigate to PDFViewerScreen and wait for the result
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerScreen(
                  pdfPath: documents[index].path,
                  pdfName: documents[index].title,
                ),
              ),
            );
            if (result == true) {
              // Refresh the document list if the result is true
              context.read<DocumentBloc>().add(LoadDocuments());
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),

            child: Container(
              margin: EdgeInsets.symmetric(vertical: 4),
              color: Colors.white30,
              
              child: ListTile(
                leading: Container(
                  height: 100,
                  width: 50,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    image: DecorationImage(
                      image: FileImage(File(documents[index].thumbnailPath)),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  fileName,
                  style: Theme.of(context).textTheme.bodyMedium,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  'Read Count: ${documents[index].readCount}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> updateMostRead(Document document)async{

    // Update the last read time
    context.read<DocumentBloc>().add( UpdateDocumentRead(document.path));

    // Navigate to PDFViewerScreen
     final result = await       Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerScreen(
                  pdfPath: document.path,
                  pdfName: document.title,
                ),
              ),
            );

    if (result) {
      // Refresh the UI
      context.read<DocumentBloc>().add(LoadDocuments());


    }
}


}


