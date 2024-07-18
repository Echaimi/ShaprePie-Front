// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:spaceshare/services/category_service.dart';
import 'package:spaceshare/models/category.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

AppLocalizations? t(BuildContext context) => AppLocalizations.of(context);

class CategoriesScreen extends StatefulWidget {
  final CategoryService categoryService;

  const CategoriesScreen({super.key, required this.categoryService});

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  late Future<List<Category>> categoriesFuture;

  @override
  void initState() {
    super.initState();
    categoriesFuture = widget.categoryService.getCategories();
  }

  Future<void> _showDeleteConfirmationDialog(int categoryId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t(context)?.confirmDelete ?? 'Confirm Delete'),
          content: Text(
            t(context)?.deleteCategoryConfirmation ??
                'Are you sure you want to delete this category?',
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t(context)?.cancel ?? 'Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(t(context)?.delete ?? 'Delete'),
              onPressed: () async {
                try {
                  await widget.categoryService.deleteCategory(categoryId);
                  setState(() {
                    categoriesFuture = widget.categoryService.getCategories();
                  });
                  context.pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                      '${t(context)?.deleteCategoryFailed ?? 'Failed to delete category'}: $e',
                    )),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showCategoryFormDialog({Category? category}) async {
    final formKey = GlobalKey<FormState>();
    String categoryName = category?.name ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(category == null
              ? t(context)?.addCategory ?? 'Add Category'
              : t(context)?.editCategory ?? 'Edit Category'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: categoryName,
              decoration: InputDecoration(
                labelText: t(context)?.categoryName ?? 'Category Name',
                labelStyle: const TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                categoryName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return t(context)?.enterCategoryName ??
                      'Please enter a category name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(t(context)?.cancel ?? 'Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(t(context)?.save ?? 'Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (category == null) {
                      await widget.categoryService
                          .createCategory({'name': categoryName});
                    } else {
                      await widget.categoryService
                          .updateCategory(category.id, {'name': categoryName});
                    }
                    setState(() {
                      categoriesFuture = widget.categoryService.getCategories();
                    });
                    context.pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                        '${t(context)?.saveCategoryFailed ?? 'Failed to save category'}: $e',
                      )),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              t(context)?.manageCategories ?? 'Manage Categories',
              style: const TextStyle(color: Colors.black),
            ),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: FutureBuilder<List<Category>>(
          future: categoriesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text(
                      '${t(context)?.error ?? 'Error'}: ${snapshot.error}'));
            } else {
              final categories = snapshot.data!;
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: MediaQuery.of(context).size.width < 800
                          ? MediaQuery.of(context).size.width
                          : 800,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () => _showCategoryFormDialog(),
                            icon: const Icon(Icons.add),
                            label:
                                Text(t(context)?.addCategory ?? 'Add Category'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              textStyle: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width < 800
                              ? MediaQuery.of(context).size.width
                              : 800,
                          child: DataTable(
                            columns: [
                              DataColumn(
                                label: Text(
                                  t(context)?.id ?? 'ID',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                    t(context)?.name ?? 'Name',
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                ),
                              ),
                              const DataColumn(
                                label: Text(''),
                              ),
                            ],
                            rows: categories
                                .map(
                                  (category) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          category.id.toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          category.name,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.edit,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _showCategoryFormDialog(
                                                      category: category),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _showDeleteConfirmationDialog(
                                                      category.id),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
