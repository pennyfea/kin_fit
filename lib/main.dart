import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'data/repositories/authentication_repository.dart';
import 'data/repositories/check_in_repository.dart';
import 'data/repositories/group_repository.dart';
import 'data/repositories/user_repository.dart';
import 'data/services/storage_service.dart';
import 'firebase_options.dart';
import 'routing/app_router.dart';
import 'ui/app/blocs/app_bloc.dart';
import 'ui/app/blocs/app_event.dart';
import 'ui/app/blocs/app_state.dart';
import 'ui/core/theme/app_theme.dart';
import 'ui/groups/blocs/group_bloc.dart';
import 'ui/home/blocs/feed_cubit.dart';
import 'utils/logger.dart';

/// Main entry point for the application.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const logger = Logger('Main');

  try {
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.info('Firebase initialized successfully');
  } catch (e, stackTrace) {
    logger.error('Failed to initialize Firebase', e, stackTrace);
    rethrow;
  }

  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;

  runApp(App(authenticationRepository: authenticationRepository));
}

/// The root widget of the application.
class App extends StatelessWidget {
  const App({
    required this.authenticationRepository,
    super.key,
  });

  final AuthenticationRepository authenticationRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authenticationRepository),
        RepositoryProvider(create: (_) => UserRepository()),
        RepositoryProvider(create: (_) => GroupRepository()),
        RepositoryProvider(create: (_) => CheckInRepository()),
        RepositoryProvider(create: (_) => StorageService()),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AppBloc(
              authenticationRepository: authenticationRepository,
            )..add(const AppUserSubscriptionRequested()),
          ),
          BlocProvider(
            create: (context) => GroupBloc(
              groupRepository: context.read<GroupRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => FeedCubit(
              groupRepository: context.read<GroupRepository>(),
              checkInRepository: context.read<CheckInRepository>(),
              userRepository: context.read<UserRepository>(),
            ),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}

/// The main app view that configures the router.
class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final AppRouter _appRouter = AppRouter(
    authenticationRepository: context.read<AuthenticationRepository>(),
  );

  @override
  void initState() {
    super.initState();
    // If already authenticated on launch, start subscriptions.
    final appState = context.read<AppBloc>().state;
    if (appState.status == AppStatus.authenticated) {
      context.read<GroupBloc>().add(
            GroupsSubscriptionRequested(appState.user.id),
          );
      context.read<FeedCubit>().load(appState.user.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AppBloc, AppState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == AppStatus.authenticated) {
          context.read<GroupBloc>().add(
                GroupsSubscriptionRequested(state.user.id),
              );
          context.read<FeedCubit>().load(state.user.id);
        }
      },
      child: MaterialApp.router(
        title: 'Bod Squad',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: _appRouter.router,
      ),
    );
  }
}
