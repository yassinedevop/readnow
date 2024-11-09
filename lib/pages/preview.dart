import 'dart:io';

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/pages/widgets/preview_page/navigation_pan.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';

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

  late GlobalKey<SfSignaturePadState> _signaturePadKey;
  bool _isDrawing = false;

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

    _signaturePadKey = GlobalKey<SfSignaturePadState>();

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
    final RenderBox? renderBoxContainer =
        context.findRenderObject()! as RenderBox;
    if (renderBoxContainer != null) {
      final double _kContextMenuHeight = 90;
      final double _kContextMenuWidth = 100;
      final double _kHeight = 18;
      final Offset containerOffset = renderBoxContainer.localToGlobal(
        renderBoxContainer.paintBounds.topLeft,
      );
      if (details != null &&
              containerOffset.dy < details.globalSelectedRegion!.topLeft.dy ||
          (containerOffset.dy <
                  details!.globalSelectedRegion!.center.dy -
                      (_kContextMenuHeight / 2) &&
              details.globalSelectedRegion!.height > _kContextMenuWidth)) {
        double top = 0.0;
        double left = 0.0;
        final Rect globalSelectedRect = details.globalSelectedRegion!;
        if ((globalSelectedRect.top) > MediaQuery.of(context).size.height / 2) {
          top = globalSelectedRect.topLeft.dy +
              details.globalSelectedRegion!.height +
              _kHeight;
          left = globalSelectedRect.bottomLeft.dx;
        } else {
          top = globalSelectedRect.height > _kContextMenuWidth
              ? globalSelectedRect.center.dy - (_kContextMenuHeight / 2)
              : globalSelectedRect.topLeft.dy +
                  details.globalSelectedRegion!.height +
                  _kHeight;
          left = globalSelectedRect.height > _kContextMenuWidth
              ? globalSelectedRect.center.dx - (_kContextMenuWidth / 2)
              : globalSelectedRect.bottomLeft.dx;
        }
        final OverlayState? _overlayState =
            Overlay.of(context, rootOverlay: true);
        _overlayEntry = OverlayEntry(
          builder: (context) => Positioned(
            top: top,
            left: left,
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8.0),
                
              ),
              constraints: BoxConstraints.tightFor(
                  width: _kContextMenuWidth, height: _kContextMenuHeight),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _addAnnotation('Highlight', details.selectedText),
                  _addAnnotation('Underline', details.selectedText),
                  _addAnnotation('Strikethrough', details.selectedText),
                ],
              ),
            ),
          ),
        );
        _overlayState?.insert(_overlayEntry!);
      }
    }
  }

  void _checkAndCloseContextMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Widget _addAnnotation(String? annotationType, String? selectedText) {
    return Container(
      height: 30,
      width: 100,
      child: RawMaterialButton(
        onPressed: () async {
          _checkAndCloseContextMenu();
          await Clipboard.setData(ClipboardData(text: selectedText!));
          _drawAnnotation(annotationType);
        },
        child: Text(
          annotationType!,
          style:Theme.of(context).textTheme.labelSmall!.copyWith(
            color: Colors.grey.shade200,
            fontWeight: FontWeight.w400
          ),
        ),
      ),
    );
  }

  void _drawAnnotation(String? annotationType) {
    switch (annotationType) {
      case 'Highlight':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage _page =
                _pdfDocument.pages[pdfTextLine.pageNumber - 1];
            final PdfRectangleAnnotation rectangleAnnotation =
                PdfRectangleAnnotation(
                    pdfTextLine.bounds, 'Highlight Annotation',
                    author: 'Syncfusion',
                    color: PdfColor.fromCMYK(0, 0, 255, 0),
                    innerColor: PdfColor.fromCMYK(0, 0, 255, 0),
                    opacity: 0.5);
            _page.annotations.add(rectangleAnnotation);
            _page.annotations.flattenAllAnnotations();
            _pdfViewerController.addAnnotation(StickyNoteAnnotation(
              pageNumber: pdfTextLine.pageNumber,
              text: 'Highlight Annotation',
              position: pdfTextLine.bounds.center,
              icon: PdfStickyNoteIcon.note,
            ));
            
          });

        }
        break;
      case 'Underline':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage _page = _pdfDocument.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                (_pdfDocument.pages[pdfTextLine.pageNumber].size.height -
                        pdfTextLine.bounds.bottom)
                    .toInt(),
                pdfTextLine.bounds.right.toInt(),
                (_pdfDocument.pages[pdfTextLine.pageNumber].size.height -
                        pdfTextLine.bounds.bottom)
                    .toInt()
              ],
              'Underline Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(0, 255, 0),
              color: PdfColor(0, 255, 0),
            );
            _page.annotations.add(lineAnnotation);
            _page.annotations.flattenAllAnnotations();
          });
          final List<int> bytes = _pdfDocument.saveSync();
          setState(() {
            documentBytes = Uint8List.fromList(bytes);
          });
        }
        break;
      case 'Strikethrough':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage _page = _pdfDocument.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                ((_pdfDocument.pages[pdfTextLine.pageNumber].size.height -
                            pdfTextLine.bounds.bottom) +
                        (pdfTextLine.bounds.height / 2))
                    .toInt(),
                pdfTextLine.bounds.right.toInt(),
                ((_pdfDocument.pages[pdfTextLine.pageNumber].size.height -
                            pdfTextLine.bounds.bottom) +
                        (pdfTextLine.bounds.height / 2))
                    .toInt()
              ],
              'Strikethrough Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(255, 0, 0),
              color: PdfColor(255, 0, 0),
            );
            _page.annotations.add(lineAnnotation);
            _page.annotations.flattenAllAnnotations();
          });
          final List<int> bytes = _pdfDocument.saveSync();
          setState(() {
            documentBytes = Uint8List.fromList(bytes);
          });
        }
        break;
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
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.bookmark),
            onPressed: () {
              _pdfViewerKey.currentState?.openBookmarkView();
            },
          ),
        ],
      ),
      body: PopScope(
        onPopInvokedWithResult: (a, b) async {
          context
              .read<DocumentBloc>()
              .add(UpdateDocumentRead(document.path, document.lastPageRead));
          b = true;
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
                              if (_isDrawing)
                                SfSignaturePad(
                                  key: _signaturePadKey,
                                  backgroundColor: Colors.transparent,
                                  strokeColor: _selectedColor,
                                  minimumStrokeWidth: 1.0,
                                  maximumStrokeWidth: 4.0,
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
