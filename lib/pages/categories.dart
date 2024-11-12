import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/categories_page/search.dart';

class Category {
   String name;
 List<Document> documents;
  final Color color;

  Category({required this.name, required this.documents, required this.color});
}

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);
  
  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  List<Document> filteredDocuments = [];
  List<Category> categories = [];
  String? selectedCategory;
  bool isSelectionMode = false;
  Set<Document> selectedDocuments = {};

  @override
  void initState() {
    super.initState();
    // Initialize categories if needed
  }

  void _renameCategory(Category category) {
    TextEditingController _controller = TextEditingController(text: category.name);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Rename Category'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(hintText: 'Enter new category name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Get.back(result: true);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  category.name = _controller.text;
                });
                Get.back(result: true);
              },
              child: Text('Rename'),
            ),
          ],
        );
      },
    );
  }

  void _handleSearch(String query, List<Document> documents) {
    setState(() {
      filteredDocuments = documents.where((doc) => doc.title.toLowerCase().contains(query.toLowerCase())).toSet().toList(); // Ensure no duplicates
    });
  }

  void _addCategory() {
    if (selectedDocuments.isNotEmpty) {
      TextEditingController _controller = TextEditingController();

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Add Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: 'Enter new category name'),
                ),
            
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDocuments.clear();
                    isSelectionMode = false;
                  });
                  Get.back();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    if (categories.any((cat) => cat.name == _controller.text)) {
                      Get.snackbar('Add Category', 'Category name already exists');
                    } else {
                      final newCategory = Category(
                        name: _controller.text,
                        documents: selectedDocuments.toSet().toList(), // Ensure no duplicates
                        color: Colors.primaries[categories.length % Colors.primaries.length],
                      );
                      setState(() {
                        categories.add(newCategory);
                        selectedDocuments.clear();
                        isSelectionMode = false;
                      });
                      Get.snackbar('Category Added', 'New category has been added');
                    }
                  } else {
                    Get.snackbar('Add Category', 'No category name provided');
                  }
                  setState(() {
                    selectedDocuments.clear();
                    isSelectionMode = false;
                  });
                  Get.close(1);
                },
                child: Text('Add'),
              ),
            ],
          );
        },
      );
    } else {
      Get.snackbar('Add Category', 'No documents selected');
    }
  }

  void _assignToExistingCategory() {
    if (selectedDocuments.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Assign to Existing Category'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: categories.map((category) {
                return ListTile(
                  title: Text(category.name),
                  onTap: () {
                    setState(() {
                      category.documents.addAll(selectedDocuments);
                      category.documents = category.documents.toSet().toList(); // Ensure no duplicates
                      selectedDocuments.clear();
                      isSelectionMode = false;
                    });
                    Get.back();
                    Get.snackbar('Category Updated', 'Documents have been added to the existing category');
                  },
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    selectedDocuments.clear();
                    isSelectionMode = false;
                  });
                  Get.back();
                },
                child: Text('Cancel'),
              ),
            ],
          );
        },
      );
    } else {
      Get.snackbar('Assign Category', 'No documents selected');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'),
        actions: isSelectionMode
            ? [
                IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedDocuments.clear();
                    });
                  },
                ),
              ]
            : null,
      ),
      body: BlocBuilder<DocumentBloc, DocumentState>(
        bloc: context.read<DocumentBloc>()..add(LoadDocuments()),
        builder: (context, state) {
          if (state is DocumentLoaded) {
            var documents = state.documents;
            return Column(
              children: [
                SearchBarWidget(
                  onChanged: (value) => _handleSearch(value, documents),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Wrap(
                    spacing: 8.0,
                    children: [
                      for (var category in categories)
                        GestureDetector(
                          onLongPress: () {
                            _renameCategory(category);
                          },
                          child: ChoiceChip.elevated(
                            label: Text(category.name),
                            selected: selectedCategory == category.name,
                            backgroundColor: category.color.withOpacity(0.5),
                            selectedColor: category.color,
                            onSelected: (selected) {
                              setState(() {
                                selectedCategory = selected ? category.name : null;
                                filteredDocuments = selected ? category.documents.toSet().toList() : documents.toSet().toList(); // Ensure no duplicates
                              });
                            },
                            
                          ),
                        ),
                      ActionChip(
                        label: Text('Add Category'),
                        onPressed: _addCategory,
                      ),
                      if (isSelectionMode)
                        ActionChip(
                          label: Text('Assign to Existing Category'),
                          onPressed: _assignToExistingCategory,
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: state.documents.isEmpty
                      ? Center(child: CircularProgressIndicator())
                      : buildListView(filteredDocuments.isNotEmpty ? filteredDocuments : state.documents ),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        }
          
                       
      )
      
      );
  
        
  }

  

  Widget buildListView(List<Document> documents) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(vertical: 4),
      itemCount: documents.length,
      itemBuilder: (context, index) {
        String fileName = documents[index].title; // Extract file name
        bool isSelected = selectedDocuments.contains(documents[index]);
        String? documentCategory = categories.firstWhere(
          (category) => category.documents.contains(documents[index]),
          orElse: () => Category(name: 'Uncategorized', documents: [], color: Colors.grey),
        ).name;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Material(
            color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.5) : Theme.of(context).cardColor,
            shadowColor: Colors.white10,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.0)),
            elevation: 1,
            child: InkWell(
              borderRadius: BorderRadius.circular(6.0),
              splashColor: Theme.of(context).primaryColor.withOpacity(0.5),
              highlightColor: Theme.of(context).primaryColor.withOpacity(0.5),
              onTap: () async {
                if (isSelectionMode) {
                  setState(() {
                    if (isSelected) {
                      selectedDocuments.remove(documents[index]);
                    } else {
                      selectedDocuments.add(documents[index]);
                    }
                  });
                } else {
                  await updateMostRead(documents[index]);
                }
              },
              onLongPress: () {
                setState(() {
                  isSelectionMode = true;
                  selectedDocuments.add(documents[index]);
                });
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
                  
                  trailing: isSelectionMode
                      ? Checkbox(
                          value: isSelected,
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                selectedDocuments.add(documents[index]);
                              } else {
                                selectedDocuments.remove(documents[index]);
                              }
                            });
                          },
                        )
                      : SizedBox(
                          width: 80,
                          child: Text(
                            documentCategory,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                  color: Theme.of(context).primaryColor.withOpacity(0.7),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${documents[index].lastPageRead}/${documents[index].pageCount}',
                        textAlign: TextAlign.right,
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              color: Theme.of(context).highlightColor,
                            ),
                      ),
                      SizedBox(height: 4),
                      TweenAnimationBuilder<int>(
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
                    ],
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
      context.read<DocumentBloc>().add(UpdateDocumentRead(document));
    }
  }
}
