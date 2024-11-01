class Document {
  String id;
  String title;
  String path;
  String thumbnailPath;
  DateTime? lastRead;
  int readCount;

  Document({
    required this.id,
    required this.title,
    required this.path,
    required this.thumbnailPath,
    this.lastRead,
    this.readCount = 0,
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      title: map['title'],
      path: map['path'],
      thumbnailPath: map['thumbnailPath'],
      lastRead: map['lastRead'] != null ? DateTime.parse(map['lastRead']) : null,
      readCount: map['readCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'path': path,
      'thumbnailPath': thumbnailPath,
      'lastRead': lastRead?.toIso8601String(),
      'readCount': readCount,
    };
  }
}