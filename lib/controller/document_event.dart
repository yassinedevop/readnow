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
  const UpdateDocumentRead(this.document);

  @override
  List<Object> get props => [document];
}

class UpdateDocumentCategory extends DocumentEvent {
  final String filePath;
  final String category;

  const UpdateDocumentCategory(this.filePath, this.category);

  @override
  List<Object> get props => [filePath, category];
}

class GetDocumentLastRead extends DocumentEvent {
  final String filePath;

  const GetDocumentLastRead(this.filePath);

  @override
  List<Object> get props => [filePath];
}