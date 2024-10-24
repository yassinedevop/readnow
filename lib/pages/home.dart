import 'package:flutter/material.dart';

import 'package:readnow/pages/preview.dart';
import 'package:readnow/services/permissions.dart';
import 'package:readnow/services/scan.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('PDF Files')),
      body: RefreshIndicator(
        onRefresh: _refresh, // Set the refresh function
        child: ListView.builder(
          itemCount: pdfFiles.length,
          itemBuilder: (context, index) {
            String fileName = pdfFiles[index].split('/').last; // Extract file name
            return ListTile(
              title: Text(fileName),
              onTap: () {
                // Navigate to PDFViewerScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewerScreen(pdfPath: pdfFiles[index], pdfName: 'aa',),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
