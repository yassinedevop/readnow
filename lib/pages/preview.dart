import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfName),
      ),
      body: PDFView(
        onRender: (pages) => setState(() {
          totalPages = pages!;
        }),
        onPageChanged: (page, total) => setState(() {
          indexPages = page!;
        }),
        filePath: widget.pdfPath,
        pageFling: false,
        autoSpacing: false,
      ),
    );
  }
}
