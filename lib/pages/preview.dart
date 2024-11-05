import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;
  final String pdfName;

  const PDFViewerScreen({Key? key, required this.pdfPath, required this.pdfName}) : super(key: key);

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfName),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            context.read<DocumentBloc>().add(UpdateDocumentRead(widget.pdfPath, _pdfViewerController.pageNumber));
            Navigator.pop(context, true); // Pass a result back to the previous screen
          },
        ),
      ),
      body: SfPdfViewer.file(
        File(widget.pdfPath),
        controller: _pdfViewerController,
        onDocumentLoaded: (PdfDocumentLoadedDetails details) {
          setState(() {
            _pageNumber = _pdfViewerController.pageNumber;
            _pageCount = _pdfViewerController.pageCount;
          });
        },
      ),
    );
  }
}
