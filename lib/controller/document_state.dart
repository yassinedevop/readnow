import 'package:equatable/equatable.dart';
import 'package:readnow/model/document.dart';

abstract class DocumentState extends Equatable {
  const DocumentState();

  @override
  List<Object> get props => [];
}

class DocumentInitial extends DocumentState {}

class DocumentLoading extends DocumentState {}

class DocumentLoaded extends DocumentState {
  final List<Document> documents;
  final Document? lastReadDocument;

  const DocumentLoaded(this.documents, {this.lastReadDocument});

  @override
  List<Object> get props => [documents, lastReadDocument ?? ''];
}

class DocumentError extends DocumentState {
  final String message;

  const DocumentError(this.message);

  @override
  List<Object> get props => [message];
}

class DocumentReadUpdated extends DocumentState {
  final String document;

  const DocumentReadUpdated(this.document);

  @override
  List<Object> get props => [document];
}

class DocumentLastReadLoaded extends DocumentState {
  final String filePath;
  final DateTime? lastRead;
  final int lastPageRead;

  const DocumentLastReadLoaded(this.filePath, this.lastRead, this.lastPageRead);

  @override
  List<Object> get props => [filePath, lastRead ?? DateTime(1970), lastPageRead];
}