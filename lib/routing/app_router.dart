import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/repositories/authentication_repository.dart';
import '../ui/auth/widgets/login_screen.dart';
import 'routes.dart';

/// The application router configuration.
///
/// Handles navigation and authentication-based redirects using GoRouter.
class AppRouter {
  /// Creates an [AppRouter].
  AppRouter({
    required AuthenticationRepository authenticationRepository,
  }) : _authenticationRepository = authenticationRepository;

  final AuthenticationRepository _authenticationRepository;

  late final GoRouter router = GoRouter(
    routes: _routes,
    initialLocation: Routes.home,
    redirect: _redirect,
    refreshListenable: GoRouterRefreshStream(
      _authenticationRepository.user,
    ),
  );

  /// Defines the application routes.
  List<RouteBase> get _routes => [
        GoRoute(
          path: Routes.login,
          name: 'login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: Routes.home,
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
      ];

  /// Handles authentication-based redirects.
  ///
  /// Redirects to login if the user is not authenticated.
  /// Redirects to home if the user is authenticated and tries to access login.
  String? _redirect(BuildContext context, GoRouterState state) {
    final user = _authenticationRepository.currentUser;
    final isAuthenticated = user.isNotEmpty;
    final isLoggingIn = state.matchedLocation == Routes.login;

    // Redirect to login if not authenticated and not already on login page
    if (!isAuthenticated && !isLoggingIn) {
      return Routes.login;
    }

    // Redirect to home if authenticated and on login page
    if (isAuthenticated && isLoggingIn) {
      return Routes.home;
    }

    // No redirect needed
    return null;
  }
}

/// A simple home screen placeholder.
///
/// This should be replaced with your actual home screen implementation.
class HomeScreen extends StatelessWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // TODO: Implement logout
            },
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.home, size: 80),
            SizedBox(height: 16),
            Text(
              'Welcome Home!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('You are now authenticated.'),
          ],
        ),
      ),
    );
  }
}

/// A listenable that notifies listeners when a stream emits a new value.
///
/// Used to refresh the GoRouter when the authentication state changes.
class GoRouterRefreshStream extends ChangeNotifier {
  /// Creates a [GoRouterRefreshStream].
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) => notifyListeners(),
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
