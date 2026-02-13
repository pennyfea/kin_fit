import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories/authentication_repository.dart';
import 'routing/app_router.dart';
import 'ui/core/theme/app_theme.dart';
import 'utils/logger.dart';

/// Main entry point for the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = Logger('Main');

  try {
    // Initialize Firebase
    await Firebase.initializeApp();
    logger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    logger.error('Failed to initialize Firebase', e, stackTrace);
    rethrow;
  }

  runApp(const App());
}

/// The root widget of the application.
class App extends StatelessWidget {
  /// Creates an [App].
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create the authentication repository
    final authenticationRepository = AuthenticationRepository();

    // Create the router with authentication
    final appRouter = AppRouter(
      authenticationRepository: authenticationRepository,
    );

    return MultiProvider(
      providers: [
        // Provide authentication repository to the entire app
        Provider<AuthenticationRepository>.value(
          value: authenticationRepository,
        ),
      ],
      child: MaterialApp.router(
        title: 'App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.router,
      ),
    );
  }
}
