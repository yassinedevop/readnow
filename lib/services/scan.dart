import 'dart:io';
import 'package:flutter/material.dart';
List<String> pdfFiles = [];

Future<void> getFiles(String directoryPath) async {
  if(pdfFiles.isEmpty)
  try {
    var rootDirectory = Directory(directoryPath);
    var directories = rootDirectory.listSync(recursive: false);
    
    for (var element in directories) {
      // Check if the element is a directory and not one of the restricted ones
      if (element is Directory &&
          !(element.path.contains('/Android/data/') || element.path.contains('/Android/obb/'))) {
        await getFiles(element.path); // Recursive call for directories
      } else if (element is File && element.path.endsWith(".pdf")) {
        debugPrint(element.path);
        pdfFiles.add(element.path); // Add PDF files to the list
      }
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
