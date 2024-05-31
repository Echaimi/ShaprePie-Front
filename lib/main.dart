import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'pages/login_page.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    if (kReleaseMode) {
      exit(1);
    }
  };

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stackTrace) {
    if (kDebugMode) {
      print('Caught an error: $error');
    }
    if (kDebugMode) {
      print('Stack trace: $stackTrace');
    }
    if (kReleaseMode) {
      exit(1);
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Navigation App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}
