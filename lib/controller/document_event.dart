import 'package:equatable/equatable.dart';
import 'package:readnow/model/document.dart';

abstract class DocumentEvent extends Equatable {
  const DocumentEvent();

  @override
  List<Object> get props => [];
}

class LoadDocuments extends DocumentEvent {
  const LoadDocuments();

  @override
  List<Object> get props => [];
}

class UpdateDocumentRead extends DocumentEvent {
  final Document document;
  final int _duration; // in minutes

  const UpdateDocumentRead(this.document, {int duration = 0}) : _duration = duration;

  int get duration => _duration;

  @override
  List<Object> get props => [document, _duration];
}

class UpdateDocumentCategory extends DocumentEvent {
  final String filePath;
  final String? category;

  const UpdateDocumentCategory(this.filePath, this.category);

  @override
  List<Object> get props => [filePath, category ?? ''];
}

class ClearCache extends DocumentEvent {}
