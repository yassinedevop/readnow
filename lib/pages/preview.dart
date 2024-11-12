import 'dart:io';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/preview_tools.dart';
import 'package:readnow/utils/widgets/home_page/navigation_pan.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PDFViewerScreen extends StatefulWidget {
  @override
  PDFViewerScreenState createState() => PDFViewerScreenState();
}

class PDFViewerScreenState extends State<PDFViewerScreen>
    with SingleTickerProviderStateMixin {
  late PdfViewerController _pdfViewerController;
  late PdfDocument _pdfDocument;
  Uint8List? documentBytes;
  Color _selectedColor = Colors.red;
  late GlobalKey<SfPdfViewerState> _pdfViewerKey;

  final Map<String, dynamic> args = Get.arguments;
  late Document document;
  late int _pageNumber;
  late int _pageCount;

  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<Offset> _bottomSlideAnimation;
  late Animation<double> _fadeAnimation;
  Timer? _timer;

  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    _pdfViewerController = PdfViewerController();
    document = args['document'];
    _pageNumber = document.lastPageRead;
    _pageCount = document.pageCount;
    _getPDFBytes();
    _pdfViewerKey = GlobalKey<SfPdfViewerState>();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(-1, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _bottomSlideAnimation = Tween<Offset>(
      begin: Offset(0, 0),
      end: Offset(0, 1),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startTimer();
  }

  void _getPDFBytes() async {
    final file = File(document.path);
    final bytes = await file.readAsBytes();
    documentBytes = bytes;
    _pdfDocument = PdfDocument(inputBytes: documentBytes);

    setState(() {});
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer(Duration(seconds: 2), () {
      _animationController.forward();
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _animationController.reverse();
    _startTimer();
  }

  void _showContextMenu(
    BuildContext context,
    PdfTextSelectionChangedDetails? details,
  ) {
    final OverlayState? overlayState = Overlay.of(context, rootOverlay: true);
    _overlayEntry = createContextMenu(context, details, (annotationType) {
      _checkAndCloseContextMenu();
      Clipboard.setData(ClipboardData(text: details!.selectedText!));
      drawAnnotation(_pdfDocument, _pdfViewerController, _pdfViewerKey,
          annotationType, _selectedColor);
    });
    overlayState?.insert(_overlayEntry!);
  }

  void _checkAndCloseContextMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  @override
  void dispose() {
    final List<int> bytes = _pdfDocument.saveSync();

    documentBytes = Uint8List.fromList(bytes);

    File(document.path).writeAsBytesSync(documentBytes!);
    _timer?.cancel();
    _animationController.dispose();
    _pdfViewerController.dispose();

    _pdfDocument.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: PopScope(
        onPopInvokedWithResult: (
          __,
          result,
        ) async {
          context
              .read<DocumentBloc>()
              .add(UpdateDocumentRead(document));
              
              Get.back(result: true);
        
        },
        child: MouseRegion(
          onHover: (_) => _resetTimer(),
          child: Stack(
            children: [
              documentBytes != null
                  ? Column(
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              SfPdfViewer.memory(
                                documentBytes!,
                                key: _pdfViewerKey,
                                controller: _pdfViewerController,
                                enableHyperlinkNavigation: true,
                                canShowHyperlinkDialog: false,
                                canShowScrollStatus: false,
                                canShowPaginationDialog: false,
                                canShowScrollHead: false,
                                canShowPageLoadingIndicator: true,
                                enableDocumentLinkAnnotation: true,
                                initialPageNumber: document.lastPageRead,
                                pageSpacing: 0.0,
                                onPageChanged: (details) {
                                  setState(() {
                                    _pageNumber = details.newPageNumber;
                                    document.lastPageRead = _pageNumber;
                                  });
                                },
                                onTextSelectionChanged: (details) {
                                  if (details.selectedText == null &&
                                      _overlayEntry != null) {
                                    _checkAndCloseContextMenu();
                                  } else if (details.selectedText != null &&
                                      _overlayEntry == null) {
                                    _showContextMenu(context, details);
                                  }
                                },
                                enableTextSelection: true,
                                canShowTextSelectionMenu: false,
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: CircularProgressIndicator(),
                    ),
              Positioned(
                left: 16.0,
                top: MediaQuery.of(context).size.height / 2 - 100,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          _buildColorCircle(Colors.red),
                          _buildColorCircle(Colors.green),
                          _buildColorCircle(Colors.blue),
                          _buildColorCircle(Colors.yellow),
                          _buildColorCircle(Colors.black),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SlideTransition(
                  position: _bottomSlideAnimation,
                  child: NavigationPan(
                    pageNumber: _pageNumber,
                    pageCount: _pageCount,
                    onChanged: (value) {
                      _pdfViewerController.jumpToPage(value.toInt());
                    },
                    pdfViewerController: _pdfViewerController,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildColorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedColor = color;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 4.0),
        width: 36.0,
        height: 36.0,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: _selectedColor == color ? Colors.white : Colors.transparent,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
