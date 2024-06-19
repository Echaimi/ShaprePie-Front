import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nsm/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:nsm/providers/auth_provider.dart';
import 'package:nsm/services/event_service.dart';
import 'package:nsm/services/api_service.dart';
import 'package:nsm/services/auth_service.dart';
import 'package:nsm/services/user_service.dart';
import 'dart:io';
import 'screens/event_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';

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
    return MultiProvider(
      providers: [
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        ChangeNotifierProvider(
          create: (context) => UserProvider(
            UserService(context.read<ApiService>()),
          ),
        ),
        ChangeNotifierProxyProvider<UserProvider, AuthProvider>(
            create: (context) => AuthProvider(
                  AuthService(),
                  context.read<UserProvider>(),
                ),
            update: (context, userProvider, previous) =>
                AuthProvider(AuthService(), userProvider)),
        Provider<EventService>(
          create: (context) => EventService(context.read<ApiService>()),
        ),
      ],
      child: Builder(
        builder: (context) {
          final ThemeData theme = ThemeData();

          return Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return MaterialApp.router(
                title: 'Navigation App',
                theme: theme.copyWith(
                  colorScheme: theme.colorScheme.copyWith(
                    primary: const Color(0xFFE53170),
                    secondary: const Color(0xFFFF8906),
                    background: const Color(0xFF0F0E17),
                    primaryContainer: const Color(0xFF232136),
                    secondaryContainer: const Color(0xFF373455),
                  ),
                  scaffoldBackgroundColor: const Color(0xFF0F0E17),
                  textTheme: theme.textTheme.copyWith(
                    titleLarge: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFE)),
                    titleMedium: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFE)),
                    titleSmall: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFFFFE)),
                    bodySmall: const TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFFFFFFE),
                    ),
                    bodyMedium: const TextStyle(
                      fontSize: 14.0,
                      color: Color(0xFFFFFFFE),
                    ),
                    bodyLarge: const TextStyle(
                      fontSize: 16.0,
                      color: Color(0xFFFFFFFE),
                    ),
                  ),
                ),
                routerConfig: GoRouter(
                  initialLocation: '/',
                  routes: [
                    GoRoute(
                      name: 'home',
                      path: '/',
                      builder: (context, state) => HomeScreen(
                        eventService: context.read<EventService>(),
                      ),
                    ),
                    GoRoute(
                      name: 'profile',
                      path: '/profile',
                      builder: (context, state) => const ProfileScreen(),
                    ),
                    GoRoute(
                      name: 'event',
                      path: '/events/:id',
                      builder: (context, state) {
                        final id = state.pathParameters['id'];
                        final eventId = int.tryParse(id!);
                        if (eventId == null) {
                          throw const FormatException('Failed to parse ID');
                        }
                        return EventScreen(eventId: eventId);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
