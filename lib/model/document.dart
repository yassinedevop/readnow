class Document {
  String id;
  String title;
  String path;
  String thumbnailPath;
  DateTime? lastRead;
  int readCount;
  int lastPageRead;
  int pageCount;
  String? category; // Add this line

  Document({
    required this.id,
    required this.title,
    required this.path,
    required this.thumbnailPath,
    this.lastRead,
    this.readCount = 1,
    this.lastPageRead = 1,
    required this.pageCount,
    this.category, // Add this line
  });

  factory Document.fromMap(Map<String, dynamic> map) {
    return Document(
      id: map['id'],
      title: map['title'],
      path: map['path'],
      thumbnailPath: map['thumbnailPath'],
      lastRead: map['lastRead'] != null ? DateTime.parse(map['lastRead']) : null,
      readCount: map['readCount'] ?? 1,
      lastPageRead: map['lastPageRead'] ?? 1,
      pageCount: map['pageCount'] ?? 1,
      category: map['category'], // Add this line
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
      'lastPageRead': lastPageRead,
      'pageCount': pageCount,
      'category': category, // Add this line
    };
  }
}