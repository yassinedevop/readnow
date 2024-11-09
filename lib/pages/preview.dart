import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/model/document.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';

class PDFViewerScreen extends StatefulWidget {
  @override
  PDFViewerScreenState createState() => PDFViewerScreenState();
}

class PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfViewerController _pdfViewerController;
  int _pageNumber = 0;
  int _pageCount = 0;

  @override
  void initState() {
    _pdfViewerController = PdfViewerController();
    super.initState();
  }

  @override
  void dispose() {
    _pdfViewerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = Get.arguments;
    final Document document = args['document'];

    return Scaffold(
      body: WillPopScope(
        onWillPop: () async {
        print('Page number: ${_pdfViewerController.pageNumber}');
        context.read<DocumentBloc>().add(UpdateDocumentRead(document.path, _pageNumber));
        Get.back(result: true); // Pass a result back to the previous screen
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(document.title),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              print('Page number: ${_pdfViewerController.pageNumber}');
              context.read<DocumentBloc>().add(UpdateDocumentRead(document.path, _pageNumber));
              Get.back(result: true); // Pass a result back to the previous screen
            },
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: SfPdfViewer.file(
                File(document.path),
                controller: _pdfViewerController,
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  _pdfViewerController.jumpToPage(document.lastPageRead);
                  setState(() {
                    _pageNumber = document.lastPageRead;
                    _pageCount = _pdfViewerController.pageCount;
                  });
                },
                onPageChanged: (details) => setState(() {
                  _pageNumber = details.newPageNumber;
                }),
              ),
            ),
            Container(
              color: Theme.of(context).primaryColor,
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Page $_pageNumber of $_pageCount',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
