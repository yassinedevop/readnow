import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pdfx/pdfx.dart';
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
    _initSharedPreferences();
  }

  Directory directory = Directory('');

  Future<void> _initSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  Future<void> _onLoadDocuments(LoadDocuments event, Emitter<DocumentState> emit) async {
    emit(DocumentLoading());
    try {
      if( documents.isEmpty ) {
        final documents = await _getFiles();
        emit(DocumentLoaded(documents));
      } else {
        emit(DocumentLoaded(documents));
      }
    } catch (e) {
      emit(DocumentError(e.toString()));
    }
  }

  Future<void> _onUpdateDocumentRead(UpdateDocumentRead event, Emitter<DocumentState> emit) async {
    prefs = await SharedPreferences.getInstance();
    try {
      await _setLastRead(event.filePath);
      await _incrementReadCount(event.filePath);
      await _setLastPageRead(event.filePath, event.lastPageRead);
      emit(DocumentReadUpdated(event.filePath));
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
            print(element.path);
            pdfFiles.add(Document(
              id: element.path.hashCode.toString(),
              title: element.path.split('/').last.split('.').first,
              path: element.path,
              thumbnailPath: await _renderFirstPage(element.path),
              lastRead: await _getLastRead(element.path),
              readCount: await _getReadCount(element.path),
              lastPageRead: await _getLastPageRead(element.path),
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

  Future<String> _renderFirstPage(String path) async {
    try {
      final String cachedImagePath = await _imageFromCache(path.split('/').last);
      if (cachedImagePath == '') {
        final document = await PdfDocument.openFile(path);
        final page = await document.getPage(1);
        final pageImage = await page.render(width: page.width, height: page.height);
        await page.close();
        return _saveImageToCache(pageImage!.bytes, path);
      } else {
        return cachedImagePath;
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

  Future<DateTime?> _getLastRead(String filePath) async {
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
    return prefs.getInt('lastPageRead_$filePath') ?? 0;
  }

  Future<void> _setLastPageRead(String filePath, int pageNumber) async {
    await prefs.setInt('lastPageRead_$filePath', pageNumber);
  }
}