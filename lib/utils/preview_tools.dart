import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

enum AnnotationType { Highlight, Underline, Strikethrough }

PdfColor colorToPdfColor(Color color) {
  return PdfColor(color.red, color.green, color.blue, color.alpha);
}

void drawAnnotation(PdfDocument pdfDocument, PdfViewerController pdfViewerController, GlobalKey<SfPdfViewerState> pdfViewerKey, AnnotationType annotationType, Color selectedColor) {

       List<PdfTextLine> lines =  pdfViewerKey.currentState!
            .getSelectedTextLines();
        final annota = HighlightAnnotation(
            textBoundsCollection: lines,
          );
          annota.color = selectedColor;
            lines.forEach((pdfTextLine) {
          final PdfPage page = pdfDocument.pages[pdfTextLine.pageNumber - 1];
          final PdfRectangleAnnotation rectangleAnnotation =
              PdfRectangleAnnotation(
                  pdfTextLine.bounds, 'Highlight Annotation',
              
                  innerColor: colorToPdfColor(selectedColor),
                  color: colorToPdfColor(selectedColor),
                  opacity: 0.5);
          page.annotations.add(rectangleAnnotation);
          page.annotations.flattenAllAnnotations();
          pdfViewerController.addAnnotation(annota);
        });
      }



OverlayEntry createContextMenu(BuildContext context, PdfTextSelectionChangedDetails? details, Function(AnnotationType) onAnnotationSelected) {
  final double contextMenuHeight = 90;
  final double contextMenuWidth = 100;
  final double height = 18;

  double top = 0.0;
  double left = 0.0;
  final Rect globalSelectedRect = details!.globalSelectedRegion!;
  if ((globalSelectedRect.top) > MediaQuery.of(context).size.height / 2) {
    top = globalSelectedRect.topLeft.dy + details.globalSelectedRegion!.height + height;
    left = globalSelectedRect.bottomLeft.dx;
  } else {
    top = globalSelectedRect.height > contextMenuWidth
        ? globalSelectedRect.center.dy - (contextMenuHeight / 2)
        : globalSelectedRect.topLeft.dy + details.globalSelectedRegion!.height + height;
    left = globalSelectedRect.height > contextMenuWidth
        ? globalSelectedRect.center.dx - (contextMenuWidth / 2)
        : globalSelectedRect.bottomLeft.dx;
  }

  return OverlayEntry(
    builder: (context) => Positioned(
      top: top,
      left: left,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8.0),
        ),
        constraints: BoxConstraints.tightFor(width: contextMenuWidth, height: contextMenuHeight),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildAnnotationButton(context, AnnotationType.Highlight, onAnnotationSelected),
            _buildAnnotationButton(context, AnnotationType.Underline, onAnnotationSelected),
            _buildAnnotationButton(context, AnnotationType.Strikethrough, onAnnotationSelected),
          ],
        ),
      ),
    ),
  );
}

Widget _buildAnnotationButton(BuildContext context, AnnotationType annotationType, Function(AnnotationType) onAnnotationSelected) {
  return Container(
    height: 30,
    width: 100,
    child: RawMaterialButton(
      onPressed: () {
        onAnnotationSelected(annotationType);
      },
      child: Text(
        annotationType.toString().split('.').last,
        style: Theme.of(context).textTheme.labelSmall!.copyWith(
          color: Colors.grey.shade200,
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
  );
}