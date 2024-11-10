import 'package:equatable/equatable.dart';

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
  final String filePath;
  final int lastPageRead;

  const UpdateDocumentRead(this.filePath, this.lastPageRead);

  @override
  List<Object> get props => [filePath, lastPageRead];
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