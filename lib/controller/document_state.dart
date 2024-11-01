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

  const DocumentLoaded(this.documents);

  @override
  List<Object> get props => [documents];
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