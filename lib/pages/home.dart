import 'package:flutter/material.dart';

import 'package:readnow/pages/preview.dart';
import 'package:readnow/services/permissions.dart';
import 'package:readnow/services/scan.dart';
import 'package:pdfx/pdfx.dart';
class PdfListScreen extends StatefulWidget {
  @override
  _PdfListScreenState createState() => _PdfListScreenState();
}

class _PdfListScreenState extends State<PdfListScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch PDFs when the screen initializes
    Future.wait([_refresh() ]);
  }

  Future<void> _refresh()async {
    await handleStoragePermission();
    setState(() {
      
    });
  }

  bool _isGridView = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text('PDF Files'),
      actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
        ],),
      body: RefreshIndicator(
        onRefresh: _refresh, // Set the refresh function
        child: _isGridView ? _buildGridView(): _buildListView(),
      ),
    );
  }
}
 Widget _buildGridView() {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Number of columns in the grid
        crossAxisSpacing: 0.0, // Spacing between columns
        mainAxisSpacing: 0.0, // Spacing between rows
        childAspectRatio: 0.7,
      ),
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        String fileName = pdfFiles[index].split('/').last.split('.').first; // Extract file name
        return GestureDetector(
          onTap: () {
            // Navigate to PDFViewerScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerScreen(
                  pdfPath: pdfFiles[index],
                  pdfName: pdfFiles[index].split('/').last.split('.')[0],
                ),
              ),
            );
          },
          child: Card(
            elevation: 1,
            color: Colors.grey[100],
            shadowColor: Colors.transparent,

            child: Column(
              children: [
                Expanded(
                  child: FutureBuilder<PdfPageImage>(
                    future: renderFirstPage(pdfFiles[index]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Image.memory(snapshot.data!.bytes, fit: BoxFit.cover);
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    fileName,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
Widget _buildListView() {

    return ListView.builder(
      itemCount: pdfFiles.length,
      itemBuilder: (context, index) {
        String fileName = pdfFiles[index].split('/').last.split('.').first; // Extract file name
        return ListTile(
          leading: FutureBuilder<PdfPageImage>(
            future: renderFirstPage(pdfFiles[index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return Image.memory(snapshot.data!.bytes, width: 50, height: 50, fit: BoxFit.cover);
              } else {
                return Container(width: 50, height: 50, child: Center(child: CircularProgressIndicator()));
              }
            },
          ),
          title: Text(fileName),
          onTap: () {
            // Navigate to PDFViewerScreen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PDFViewerScreen(pdfPath: pdfFiles[index], pdfName: fileName,),
              ),
            );
          },
        );
      },
    );
  
}


Future<PdfPageImage> renderFirstPage(String fileName)async {
  final document = await PdfDocument.openFile(fileName); 
 
  final page = await document.getPage(1);
  final pageImage = await page.render(width: page.width, height: page.height);
  await page.close();
  return pageImage!;
}