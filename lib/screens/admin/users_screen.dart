// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously, empty_catches

import 'package:flutter/material.dart';
import 'package:spaceshare/services/user_service.dart';
import 'package:spaceshare/models/user.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UsersScreen extends StatefulWidget {
  final UserService userService;

  const UsersScreen({super.key, required this.userService});

  @override
  _UsersScreenState createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  late Future<List<User>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = widget.userService.getUsers();
  }

  Future<void> _showDeleteConfirmationDialog(int userId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(AppLocalizations.of(context)!.confirmDeleteUser),
          content: Text(AppLocalizations.of(context)!.deleteUserConfirmation),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.delete),
              onPressed: () async {
                try {
                  await widget.userService.deleteUser(userId);
                  setState(() {
                    usersFuture = widget.userService.getUsers();
                  });
                  context.pop();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(
                            '${AppLocalizations.of(context)!.failedToDeleteUser}: $e')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showUserFormDialog({User? user}) async {
    final formKey = GlobalKey<FormState>();
    String email = user?.email ?? '';
    String username = user?.username ?? '';

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(user == null
              ? AppLocalizations.of(context)!.addUser
              : AppLocalizations.of(context)!.editUser),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: email,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userEmail,
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    email = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterEmail;
                    }
                    return null;
                  },
                ),
                TextFormField(
                  initialValue: username,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.userUsername,
                    labelStyle: const TextStyle(color: Colors.black),
                  ),
                  style: const TextStyle(color: Colors.black),
                  onChanged: (value) {
                    username = value;
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)!.pleaseEnterUsername;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(AppLocalizations.of(context)!.cancel),
              onPressed: () {
                context.pop();
              },
            ),
            TextButton(
              child: Text(AppLocalizations.of(context)!.save),
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    if (user == null) {
                      await widget.userService.createUser({
                        'email': email,
                        'username': username,
                        'password': 'newpassword123456789',
                      });
                    } else {
                      await widget.userService.updateUser(user.id, {
                        'email': email,
                        'username': username,
                      });
                    }
                    setState(() {
                      usersFuture = widget.userService.getUsers();
                    });
                    context.pop();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text(
                              '${AppLocalizations.of(context)!.failedToSaveUser}: $e')),
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
            child: Text(AppLocalizations.of(context)!.manageUsers,
                style: const TextStyle(color: Colors.black)),
          ),
          backgroundColor: Colors.white,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: FutureBuilder<List<User>>(
          future: usersFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              final users = snapshot.data!;
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
                            onPressed: () => _showUserFormDialog(),
                            icon: const Icon(Icons.add),
                            label: Text(AppLocalizations.of(context)!.addUser),
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
                                label: Text(AppLocalizations.of(context)!.id,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              DataColumn(
                                label: Expanded(
                                  child: Text(
                                      AppLocalizations.of(context)!.email,
                                      style:
                                          const TextStyle(color: Colors.black)),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.username,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              DataColumn(
                                label: Text(
                                    AppLocalizations.of(context)!.userRole,
                                    style:
                                        const TextStyle(color: Colors.black)),
                              ),
                              const DataColumn(
                                label: Text(''),
                              ),
                            ],
                            rows: users
                                .map(
                                  (user) => DataRow(
                                    cells: [
                                      DataCell(
                                        Text(
                                          user.id.toString(),
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                              color: Colors.black),
                                        ),
                                      ),
                                      DataCell(
                                        Text(
                                          user.role,
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
                                                  _showUserFormDialog(
                                                      user: user),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.black),
                                              onPressed: () =>
                                                  _showDeleteConfirmationDialog(
                                                      user.id),
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
