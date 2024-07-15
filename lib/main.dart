import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:spaceshare/screens/admin/admin_dashboard.dart';
import 'package:spaceshare/screens/admin/admin_login_screen.dart';
import 'package:spaceshare/screens/admin/categories_screen.dart';
import 'package:spaceshare/screens/admin/events_screen.dart';
import 'package:spaceshare/screens/admin/tags_screen.dart';
import 'package:spaceshare/screens/admin/users_screen.dart';
import 'package:spaceshare/screens/create_expense_screen.dart';
import 'package:spaceshare/screens/update_event_screen.dart';
import 'package:spaceshare/services/category_service.dart';
import 'package:spaceshare/services/event_websocket_service.dart';
import 'package:spaceshare/services/tag_service.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:spaceshare/providers/auth_provider.dart';
import 'package:spaceshare/services/api_service.dart';
import 'package:spaceshare/services/auth_service.dart';
import 'package:spaceshare/services/event_service.dart';
import 'package:spaceshare/services/user_service.dart';
import 'providers/LanguageProvider.dart';
import 'screens/event_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:spaceshare/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.local");

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    final notificationService = NotificationService();
    await notificationService.initialize();
  }

  FlutterNativeSplash.preserve(
      widgetsBinding: WidgetsFlutterBinding.ensureInitialized());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => ApiService()),
        Provider<UserService>(
            create: (context) => UserService(context.read<ApiService>())),
        ChangeNotifierProvider<AuthProvider>(
            create: (context) =>
                AuthProvider(AuthService(), context.read<UserService>())),
        Provider<EventService>(
          create: (context) => EventService(context.read<ApiService>()),
        ),
        ChangeNotifierProvider<LanguageProvider>(
          create: (_) => LanguageProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final authProvider =
              Provider.of<AuthProvider>(context, listen: false);
          return FutureBuilder(
            future: authProvider.init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const MaterialApp(
                  home: Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  ),
                );
              } else {
                FlutterNativeSplash.remove();
                return const AppRouter();
              }
            },
          );
        },
      ),
    );
  }
}

class AppRouter extends StatelessWidget {
  const AppRouter({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData();
    final languageProvider = Provider.of<LanguageProvider>(context);
    final rootNavigatorKey = GlobalKey<NavigatorState>();
    final shellNavigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Navigation App',
      locale: languageProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
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
          bodySmall: const TextStyle(fontSize: 12.0, color: Color(0xFFFFFFFE)),
          bodyMedium: const TextStyle(fontSize: 14.0, color: Color(0xFFFFFFFE)),
          bodyLarge: const TextStyle(fontSize: 16.0, color: Color(0xFFFFFFFE)),
        ),
      ),
      routerConfig: GoRouter(
        navigatorKey: rootNavigatorKey,
        initialLocation: kIsWeb ? '/admin' : '/',
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
          ShellRoute(
            navigatorKey: shellNavigatorKey,
            builder: (context, state, child) {
              final id = state.pathParameters['id'];
              final eventId = int.tryParse(id!);
              if (eventId == null) {
                throw const FormatException('Failed to parse ID');
              }
              final authProvider =
                  Provider.of<AuthProvider>(context, listen: false);

              return ChangeNotifierProvider(
                create: (_) => EventWebsocketProvider(eventId, authProvider),
                child: child,
              );
            },
            routes: [
              GoRoute(
                name: 'event',
                path: '/events/:id',
                builder: (context, state) {
                  final id = state.pathParameters['id'];
                  final eventId = int.tryParse(id!);
                  if (eventId == null) {
                    throw const FormatException('Failed to parse ID');
                  }
                  final eventService = context.read<EventService>();
                  return EventScreen(
                      eventId: eventId, eventService: eventService);
                },
                routes: [
                  GoRoute(
                    name: 'create_expense',
                    path: 'expenses/create',
                    builder: (context, state) => const CreateExpenseScreen(),
                  ),
                  GoRoute(
                    name: 'edit_expense',
                    path: 'expenses/:expenseId/edit',
                    builder: (context, state) {
                      final id = state.pathParameters['expenseId'];
                      final expenseId = int.tryParse(id!);
                      if (expenseId == null) {
                        throw const FormatException('Failed to parse ID');
                      }
                      return UpdateExpenseScreen(
                        expenseId: expenseId,
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          GoRoute(
            name: 'admin_login',
            path: '/admin/login',
            redirect: (context, state) {
              final authProvider = context.read<AuthProvider>();
              if (authProvider.isAuthenticated) {
                return '/admin';
              }
              return null;
            },
            builder: (context, state) => const AdminLoginScreen(),
          ),
          GoRoute(
            name: 'admin',
            path: '/admin',
            redirect: (context, state) => '/admin/categories',
          ),
          ShellRoute(
            redirect: (context, state) {
              final authProvider = context.read<AuthProvider>();
              if (!authProvider.isAuthenticated ||
                  authProvider.user?.role != 'admin') {
                return '/admin/login';
              }
              return null;
            },
            navigatorKey: shellNavigatorKey,
            builder: (context, state, child) => AdminDashboard(child: child),
            routes: [
              GoRoute(
                  path: '/admin/categories',
                  builder: (context, state) {
                    final categoryService =
                        CategoryService(context.read<ApiService>());
                    return CategoriesScreen(categoryService: categoryService);
                  }),
              GoRoute(
                  path: '/admin/tags',
                  builder: (context, state) {
                    final tagService = TagService(context.read<ApiService>());
                    return TagsScreen(tagService: tagService);
                  }),
              GoRoute(
                  path: '/admin/users',
                  builder: (context, state) =>
                      UsersScreen(userService: context.read<UserService>())),
              GoRoute(
                  path: '/admin/events',
                  builder: (context, state) =>
                      EventsScreen(eventService: context.read<EventService>())),
            ],
          ),
        ],
      ),
    );
  }
}
