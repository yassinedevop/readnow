import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart';
import 'package:readnow/model/day.dart';
import 'document_event.dart';
import 'document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:external_path/external_path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class DocumentBloc extends Bloc<DocumentEvent, DocumentState> {
  late SharedPreferences prefs;
  List<Document> documents = [];

  DocumentBloc() : super(DocumentInitial()) {
    on<LoadDocuments>(_onLoadDocuments);
    on<UpdateDocumentRead>(_onUpdateDocumentRead);
    on<UpdateDocumentCategory>(_onUpdateDocumentCategory);
    on<ClearCache>(_onClearCache);
    _initSharedPreferences();
  }

  Directory directory = Directory('');

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _onLoadDocuments(LoadDocuments event, Emitter<DocumentState> emit) async {
    emit(DocumentLoading());
    try {
      if (documents.isEmpty) {
        documents = await _getFiles();
      }
      for (var document in documents) {
        document.category = await _getDocumentCategory(document.path);
      }
      final lastReadDocument = _getLastReadDocument(documents);
      
      emit(DocumentLoaded(documents, lastReadDocument: lastReadDocument));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onUpdateDocumentRead(UpdateDocumentRead event, Emitter<DocumentState> emit) async {
    prefs = await SharedPreferences.getInstance();
    try {
      await _setLastRead(event.document.path);
      await _incrementReadCount(event.document.path);
      await _setLastPageRead(event.document.path, event.document.lastPageRead);
      await _updateDayStatistics(event.document, event.duration);
      
      final index = documents.indexWhere( (doc) => doc.path == event.document.path);
      documents[index].lastRead =  DateTime.now();
      documents[index].lastPageRead = event.document.lastPageRead;

      emit(DocumentLoaded(documents, lastReadDocument: documents[index])); // Ensure the state is updated with the latest documents
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onUpdateDocumentCategory(UpdateDocumentCategory event, Emitter<DocumentState> emit) async {
    try {
      final document = documents.firstWhere((doc) => doc.path == event.filePath);
      document.category = event.category;
      await _setDocumentCategory(event.filePath, event.category ?? '');
      final lastReadDocument = _getLastReadDocument(documents);
      emit(DocumentLoaded(documents, lastReadDocument: lastReadDocument)); // Ensure the state is updated with the latest documents
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onClearCache(ClearCache event, Emitter<DocumentState> emit) async {
    emit(DocumentLoading());
    try {
      final cacheDir = Directory(directory.path);
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
      await prefs.clear(); // Clear SharedPreferences
      documents = await _getFiles();
      for (var document in documents) {
        document.category = await _getDocumentCategory(document.path);
      }
      final lastReadDocument = _getLastReadDocument(documents);
      emit(DocumentLoaded(documents, lastReadDocument: lastReadDocument));
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<List<Document>> _getFiles() async {
    List<Document> pdfFiles = [];

    directory = await getTemporaryDirectory();
    try {
      PermissionStatus permissionStatus = await Permission.manageExternalStorage.request();
      if (permissionStatus.isGranted) {
        // Permission granted for Android 11+
        String downloadDirectory = await ExternalPath.getExternalStoragePublicDirectory(ExternalPath.DIRECTORY_DOWNLOADS);
        var directories = Directory(downloadDirectory).listSync(recursive: true);
        for (var element in directories) {
          // search only on Downloads and skip hidden files
          if (element is File && element.path.endsWith(".pdf") && !element.path.contains("/.")) {
            final pathAndCount = await _renderFirstPage(element.path);
            pdfFiles.add(Document(
              id: element.path.hashCode.toString(),
              title: element.path.split('/').last.split('.').first,
              path: element.path,
              thumbnailPath: await pathAndCount[0],
              lastRead: await _getLastRead(element.path),
              readCount: await _getReadCount(element.path),
              lastPageRead: await _getLastPageRead(element.path), pageCount: pathAndCount[1],
            ));
          }
        }
      } else {
        throw Exception("Permission denied");
      }
    } catch (e) {
      throw Exception("Error loading files: $e");
    }
    return pdfFiles;
  }



  Future<List<dynamic>> _renderFirstPage(String path) async {
    try {
      final String cachedImagePath = await _imageFromCache(path.split('/').last);
      if (cachedImagePath == '') {
        final document = await PdfDocument.openFile(path);
        final pageCount = document.pagesCount;
        final page = await document.getPage(1);
        final pageImage = await page.render(width: page.width, height: page.height, backgroundColor: '#ffffff', quality: 80 , format: PdfPageImageFormat.png);
        await page.close();
        return [_saveImageToCache(pageImage!.bytes, path), pageCount];
      } else {
        final document = await PdfDocument.openFile(path);
        final pageCount = document.pagesCount;
        return [cachedImagePath, pageCount];
      }
    } catch (e) {
      throw Exception("Error rendering first page: $e");
    }
  }

  Future<String> _saveImageToCache(Uint8List imageBytes, String filePath) async {
    final String fileName = filePath.split('/').last;
    final cachedImagePath = "${directory.path}/$fileName";
    final file = File(cachedImagePath);
    await file.writeAsBytes(imageBytes);
    return cachedImagePath;
  }

  Future<String> _imageFromCache(String fileName) async {
    final cachedImagePath = "${directory.path}/$fileName";
    return await File(cachedImagePath).exists().then((value) => value ? cachedImagePath : '');
  }

  DateTime? _getLastRead(String filePath)  {
    final lastReadString = prefs.getString('lastRead_$filePath');
    if (lastReadString != null) {
      return DateTime.parse(lastReadString);
    }
    return null;
  }

  Future<void> _setLastRead(String filePath) async {
    final now = DateTime.now().toIso8601String();
    await prefs.setString('lastRead_$filePath', now);
  }

  Future<int> _getReadCount(String filePath) async {
    return prefs.getInt('readCount_$filePath') ?? 0;
  }

  Future<void> _incrementReadCount(String filePath) async {
    int readCount = (prefs.getInt('readCount_$filePath') ?? 0);
    readCount++;
    await prefs.setInt('readCount_$filePath', readCount);
  }

  Future<int> _getLastPageRead(String filePath) async {
    return prefs.getInt('lastPageRead_$filePath') ?? 1;
  }

  Future<void> _setLastPageRead(String filePath, int pageNumber) async {
    await prefs.setInt('lastPageRead_$filePath', pageNumber);
  }

  Future<String?> _getDocumentCategory(String filePath) async {
    return prefs.getString('documentCategory_$filePath');
  }

  Future<void> _setDocumentCategory(String filePath, String category) async {
    await prefs.setString('documentCategory_$filePath', category);
  }

  Future<void> _updateDayStatistics(Document document, int duration) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> daysStringList = prefs.getStringList('days') ?? [];
    final today = DateTime.now().toIso8601String().split('T').first;
    final index = daysStringList.indexWhere((dayString) => Day.fromJson(jsonDecode(dayString)).date == today);

    if (index != -1) {
      final day = Day.fromJson(jsonDecode(daysStringList[index]));
      day.readCount += 1;
      day.pageCount += document.pageCount;
      day.duration += duration;

      final bookIndex = day.booksRead.indexWhere((book) => book.title == document.title);
      if (bookIndex != -1) {
        day.booksRead[bookIndex].readCount += 1;
        day.booksRead[bookIndex].duration += duration;
      } else {
        day.booksRead.add(BooksWithReadTime(title: document.title, duration: duration));
      }

      daysStringList[index] = jsonEncode(day.toJson());
    } else {
      final newDay = Day(
        date: today,
        readCount: 1,
        pageCount: document.pageCount,
        duration: duration,
        booksRead: [BooksWithReadTime(title: document.title, duration: duration)],
      );
      daysStringList.add(jsonEncode(newDay.toJson()));
    }

    await prefs.setStringList('days', daysStringList);
  }

  Document? _getLastReadDocument(List<Document> documents) {
    documents.sort((a, b) => b.lastRead?.compareTo(a.lastRead ?? DateTime(1970)) ?? 0);
    return documents.isNotEmpty ? documents.first : null;
  }
}
