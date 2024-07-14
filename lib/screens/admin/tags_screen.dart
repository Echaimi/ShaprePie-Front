import 'package:flutter/material.dart';
import 'package:spaceshare/services/tag_service.dart';
import 'package:spaceshare/models/tag.dart';
import 'package:go_router/go_router.dart';

class TagsScreen extends StatefulWidget {
  final TagService tagService;

  const TagsScreen({super.key, required this.tagService});

  @override
  _TagsScreenState createState() => _TagsScreenState();
}

class _TagsScreenState extends State<TagsScreen> {
  late Future<List<Tag>> tagsFuture;

  @override
  void initState() {
    super.initState();
    tagsFuture = widget.tagService.getTags();
  }

  Future<void> _showDeleteConfirmationDialog(int tagId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this tag?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                try {
                  await widget.tagService.deleteTag(tagId);
                  setState(() {
                    tagsFuture = widget.tagService.getTags();
                  });
                  context.pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete tag: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTagFormDialog({Tag? tag}) async {
    final formKey = GlobalKey<FormState>();
    String tagName = tag?.name ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(tag == null ? 'Add Tag' : 'Edit Tag'),
          content: Form(
            key: formKey,
            child: TextFormField(
              initialValue: tagName,
              decoration: const InputDecoration(
                labelText: 'Tag Name',
                labelStyle: TextStyle(color: Colors.black),
              ),
              style: const TextStyle(color: Colors.black),
              onChanged: (value) {
                tagName = value;
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a tag name';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (tag == null) {
                      await widget.tagService.createTag({'name': tagName});
                    } else {
                      await widget.tagService
                          .updateTag(tag.id, {'name': tagName});
                    }
                    setState(() {
                      tagsFuture = widget.tagService.getTags();
                    });
                    context.pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to save tag: $e')),
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
          title: const Align(
            alignment: Alignment.centerLeft,
            child: Text('Manage Tags', style: TextStyle(color: Colors.black)),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: FutureBuilder<List<Tag>>(
          future: tagsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final tags = snapshot.data!;
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
                            onPressed: () => _showTagFormDialog(),
                            icon: const Icon(Icons.add),
                            label: const Text('Add Tag'),
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
                            columns: const [
                              DataColumn(
                                label: Text('ID',
                                    style: TextStyle(color: Colors.black)),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text('Name',
                                      style: TextStyle(color: Colors.black)),
                                ),
                              ),
                              DataColumn(
                                label: Text(''),
                              ),
                            ],
                            rows: tags
                                .map(
                                  (tag) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          tag.id.toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          tag.name,
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
                                                  _showTagFormDialog(tag: tag),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _showDeleteConfirmationDialog(
                                                      tag.id),
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
