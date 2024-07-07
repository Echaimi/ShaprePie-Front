import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:nsm/providers/auth_provider.dart';
import 'package:nsm/services/api_service.dart';
import 'package:nsm/services/auth_service.dart';
import 'package:nsm/services/event_service.dart';
import 'package:nsm/services/user_service.dart';
import 'providers/LanguageProvider.dart';
import 'screens/event_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:nsm/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env.local");

  final notificationService = NotificationService();
  await notificationService.initialize();

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
          // Add LanguageProvider
          create: (_) => LanguageProvider(),
        ),
      ],
      child: Builder(
        builder: (context) {
          final ThemeData theme = ThemeData();
          final languageProvider = Provider.of<LanguageProvider>(context);

          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Navigation App',
            locale:
                languageProvider.locale, // Use the locale from LanguageProvider
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
      ),
    );
  }
}
