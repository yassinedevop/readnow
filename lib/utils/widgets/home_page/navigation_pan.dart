import 'package:flutter/material.dart';

import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class NavigationPan extends StatelessWidget {
 final int pageNumber;
 final int pageCount;
  final Function(double) onChanged;
  final PdfViewerController pdfViewerController;
  NavigationPan( {required this.pageNumber, required this.pageCount, required this.onChanged, required this.pdfViewerController});

  @override
  Widget build(BuildContext context) {
    return  Container(
                          color: Theme.of(context).colorScheme.surface,
                          padding: EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Slider(
                                thumbColor: Theme.of(context).primaryColor.withBlue(200),
                                inactiveColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                value: pageNumber.toDouble(),
                                min: 1.0,
                                divisions: (pageCount-1) == 0 ? null : pageCount-1,
                                max: pageCount.toDouble(),
                                onChanged: onChanged
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Page $pageNumber of $pageCount',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                
                    ;
  }
}