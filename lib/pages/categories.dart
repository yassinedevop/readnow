import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/categories_page/search.dart';

class Category {
  final String name;
  final List<Document> documents;
  final Color color;

  Category({required this.name, required this.documents, required this.color});
}

class CategoriesPage extends StatefulWidget {
  final List<Document> documents;

  const CategoriesPage({Key? key, required this.documents}) : super(key: key);
  
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Document> filteredDocuments = [];
  final DocumentBloc _documentBloc = DocumentBloc();
  List<Category> categories = [];
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

  }


  void _handleSearch(String query) {
    setState(() {
      filteredDocuments = widget.documents.where((doc) => doc.title.toLowerCase().contains(query.toLowerCase())).toList();
    });
  }

  void _addCategory() {
    // Implement your logic to add a new category
  }

  @override
  void dispose() {
    _documentBloc.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
      ),
      body: Column(
        children: [
          SearchBarWidget(
          
             onChanged: _handleSearch,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8.0,
              children: [
                for (var category in categories)
                  ChoiceChip(
                    label: Text(category.name),
                    selected: selectedCategory == category.name,
                    backgroundColor: category.color.withOpacity(0.5),
                    selectedColor: category.color,
                    onSelected: (selected) {
                      setState(() {
                        selectedCategory = selected ? category.name : null;
                        filteredDocuments = selected ? category.documents : widget.documents;
                      });
                    },
                  ),
                ActionChip(
                  label: Text('Add Category'),
                  onPressed: _addCategory,
                ),
              ],
            ),
          ),
          Expanded(
            child: widget.documents.isEmpty
                ? Center(child: CircularProgressIndicator())
                : buildListView(filteredDocuments.isNotEmpty ? filteredDocuments : widget.documents),
          ),
        ],
      ),
    );
  }

  Widget buildListView(List<Document> documents) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        String fileName = documents[index].title; // Extract file name
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Material(
            color: Theme.of(context).cardColor,
            shadowColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(6.0),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
              onTap: () async {
                await updateMostRead(documents[index]);
              },
              child: Padding(
                padding: EdgeInsets.all(8),
                child: ListTile(
                  minLeadingWidth: 48.0,
                  leading: Container(
                    color: Colors.white,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.0, end: 1.0),
                      duration: Duration(milliseconds: index * 100),
                      curve: Curves.easeOut,
                      builder: (BuildContext context, double value, Widget? child) {
                        return Opacity(
                          opacity: value,
                          child: Image(
                            image: FileImage(
                              File(documents[index].thumbnailPath),
                            ),
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),
                  title: Text(
                    fileName,
                    style: Theme.of(context).textTheme.titleMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: SizedBox(
                    width: 50,
                    child: Text(
                      '${documents[index].lastPageRead}/${documents[index].pageCount}',
                      textAlign: TextAlign.right,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Theme.of(context).highlightColor,
                          ),
                    ),
                  ),
                  subtitle: TweenAnimationBuilder<int>(
                    tween: IntTween(
                      begin: 0,
                      end: 100,
                    ),
                    duration: Duration(milliseconds: index * 300),
                    curve: Curves.easeOut,
                    builder: (context, progress, child) {
                      return LinearProgressIndicator(
                        semanticsLabel: 'Read Progress',
                        semanticsValue: '${documents[index].lastPageRead}/${documents[index].pageCount}',
                        value: (documents[index].lastPageRead / documents[index].pageCount) * progress / 100,
                        valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                        color: Theme.of(context).primaryColor,
                        backgroundColor: Theme.of(context).primaryColor.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                        minHeight: 5.0,
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> updateMostRead(Document document) async {
    // Navigate to PDFViewerScreen and wait for the result
    final result = await Get.toNamed('/preview', arguments: {
      'document': document,
    });
    if (result == true) {
      // Refresh the document list if the result is true
      _documentBloc.add(LoadDocuments());
    }
  }
}
