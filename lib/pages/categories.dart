import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:readnow/controller/document_bloc.dart';
import 'package:readnow/controller/document_event.dart';
import 'package:readnow/controller/document_state.dart';
import 'package:readnow/model/document.dart';
import 'package:readnow/utils/widgets/categories_page/search.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Category {
  String name;
  List<Document> documents;
  final Color color;

  Category({required this.name, required this.documents, required this.color});

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'documents': documents.map((doc) => doc.toMap()).toList(),
      'color': color.value,
    };
  }

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      name: json['name'],
      documents: (json['documents'] as List).map((doc) => Document.fromMap(doc)).toList(),
      color: Color(json['color']),
    );
  }
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
  bool _isDialogVisible = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? categoriesStringList = prefs.getStringList('categories');
    if (categoriesStringList != null) {
      setState(() {
        categories = categoriesStringList.map((categoryString) => Category.fromJson(jsonDecode(categoryString))).toList();
      });
    }
  
  }

  Future<void> _saveCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> categoriesStringList = categories.map((category) => jsonEncode(category.toJson())).toList();
    await prefs.setStringList('categories', categoriesStringList);
  }

  void _renameCategory(Category category) {
    TextEditingController _controller = TextEditingController(text: category.name);
    setState(() {
      _isDialogVisible = true;
    });
    showDialog(
      context: context,
      builder: (context) {
        return AnimatedOpacity(
          opacity: _isDialogVisible ? 1.0 : 0.0,
          duration: Duration(milliseconds: 300),
          child: AlertDialog(
            title: Text('Rename or Delete Category'),
            content: TextField(
              controller: _controller,
              decoration: InputDecoration(hintText: 'Enter new category name'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _isDialogVisible = false;
                  });
                  Get.back(result: true);
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    category.name = _controller.text;
                    _isDialogVisible = false;
                  });
                  _saveCategories();
                  Get.back(result: true);
                },
                child: Text('Rename'),
              ),
              TextButton(
                onPressed: () async {
                  setState(() {
                    for (var document in category.documents) {
                      document.category = null;
                      context.read<DocumentBloc>().add(UpdateDocumentCategory(document.path, null));
                    }
                    categories.remove(category);
                    _isDialogVisible = false;
                  });
                  await _removeCategoryFromPreferences(category);
                  Get.back(result: true);
                },
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _removeCategoryFromPreferences(Category category) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? categoriesStringList = prefs.getStringList('categories');
    if (categoriesStringList != null) {
      categoriesStringList.removeWhere((categoryString) => Category.fromJson(jsonDecode(categoryString)).name == category.name);
      await prefs.setStringList('categories', categoriesStringList);
    }
  }

  void _handleSearch(String query, List<Document> documents) {
    setState(() {
      filteredDocuments = documents.where((doc) => doc.title.toLowerCase().contains(query.toLowerCase())).toSet().toList(); // Ensure no duplicates
    });
  }

  void _addCategory() {
    if (selectedDocuments.isNotEmpty) {
      TextEditingController _controller = TextEditingController();
      setState(() {
        _isDialogVisible = true;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AnimatedOpacity(
            opacity: _isDialogVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: AlertDialog(
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
                      _isDialogVisible = false;
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
                          for (var document in selectedDocuments) {
                            // Remove document from old category
                            final oldCategory = categories.firstWhere(
                              (cat) => cat.documents.contains(document),
                              orElse: () => Category(name: 'Uncategorized', documents: [], color: Colors.grey),
                            );
                            oldCategory.documents.remove(document);

                            // Assign document to new category
                            document.category = newCategory.name;
                            context.read<DocumentBloc>().add(UpdateDocumentCategory(document.path, newCategory.name));
                          }
                          selectedDocuments.clear();
                          isSelectionMode = false;
                          _isDialogVisible = false;
                        });
                        _saveCategories();
                        Get.snackbar('Category Added', 'New category has been added');
                      }
                    } else {
                      Get.snackbar('Add Category', 'No category name provided');
                    }
                    setState(() {
                      selectedDocuments.clear();
                      isSelectionMode = false;
                      _isDialogVisible = false;
                    });
                    Get.close(1);
                  },
                  child: Text('Add'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Get.snackbar('Add Category', 'No documents selected');
    }
  }

  void _assignToExistingCategory() {
    if (selectedDocuments.isNotEmpty && categories.isNotEmpty) {
      setState(() {
        _isDialogVisible = true;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AnimatedOpacity(
            opacity: _isDialogVisible ? 1.0 : 0.0,
            duration: Duration(milliseconds: 300),
            child: AlertDialog(
              title: Text('Assign to Existing Category'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: categories.map((category) {
                  return ListTile(
                    title: Text(category.name),
                    onTap: () {
                      setState(() {
                        for (var document in selectedDocuments) {
                          // Remove document from old category
                          final oldCategory = categories.firstWhere(
                            (cat) => cat.documents.contains(document),
                            orElse: () => Category(name: 'Uncategorized', documents: [], color: Colors.grey),
                          );
                          oldCategory.documents.remove(document);

                          // Assign document to new category
                          document.category = category.name;
                          context.read<DocumentBloc>().add(UpdateDocumentCategory(document.path, category.name));
                        }
                        category.documents.addAll(selectedDocuments);
                        category.documents = category.documents.toSet().toList(); // Ensure no duplicates
                        selectedDocuments.clear();
                        isSelectionMode = false;
                        _isDialogVisible = false;
                      });
                      _saveCategories();
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
                      _isDialogVisible = false;
                    });
                    Get.back();
                  },
                  child: Text('Cancel'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      Get.snackbar('Assign Category', 'No documents selected or no categories available');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: BlocBuilder<DocumentBloc, DocumentState>(
        bloc: context.read<DocumentBloc>()..add(LoadDocuments()),
        builder: (context, state) {
          if (state is DocumentLoaded) {
            var documents = state.documents;
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SearchBarWidget(
                          onChanged: (value) => _handleSearch(value, documents),
                        ),
                      ),
                    ),
                  isSelectionMode ?  IconButton(
                  icon: Icon(Icons.cancel),
                  onPressed: () {
                    setState(() {
                      isSelectionMode = false;
                      selectedDocuments.clear();
                    });
                  },
                ) : Container(),
                  ],
                ),
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.0),
                  alignment: Alignment.centerLeft,
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
                      if (isSelectionMode && categories.isNotEmpty)
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
                      : buildListView(filteredDocuments.isNotEmpty ? filteredDocuments : state.documents),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget buildListView(List<Document> documents) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(vertical: 4),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          String fileName = documents[index].title; // Extract file name
          bool isSelected = selectedDocuments.contains(documents[index]);
          String? documentCategory = documents[index].category ?? 'Uncategorized';
      
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
      ),
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
