import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';



class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfName;

  const PDFViewerScreen({Key? key, required this.pdfPath, required this.pdfName}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int totalPages = 0;
  int indexPages = 0;
  
  late PdfController _pdfController ;
  @override
  void initState() {
    super.initState();
      _pdfController = PdfController( document: PdfDocument.openFile(widget.pdfPath) , );
  
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfName),
      ),
      body:PdfView(
        onPageChanged: (page) {
          setState(() {
            indexPages = page;
          });
        },
        onDocumentLoaded: (document) => totalPages = document.pagesCount,
  controller: _pdfController),
      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.chevron_left),
              onPressed: () {
                if (indexPages > 0) {
                  indexPages--;
                  _pdfController.jumpToPage(indexPages);
                }
              },
            ),
            Text("$indexPages/$totalPages"),
            IconButton(
              icon: Icon(Icons.chevron_right),
              onPressed: () {
                if (indexPages < totalPages) {
                  indexPages++;
                  _pdfController.jumpToPage(indexPages);
                }
              },
            ),
          ],
        ),
      ),
      
    );
  }
}
