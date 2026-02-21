import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/extensions/context_extensions.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_state.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AppBloc, String>(
      (bloc) => bloc.state.user.id,
    );

    return BlocProvider(
      create: (context) => ProfileCubit(
        userRepository: context.read<UserRepository>(),
        checkInRepository: context.read<CheckInRepository>(),
        userId: userId,
      )..load(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          !_initialized && current.status == ProfileStatus.loaded,
      listener: (context, state) {
        _firstNameController.text = state.user.firstName ?? '';
        _lastNameController.text = state.user.lastName ?? '';
        _initialized = true;
      },
      builder: (context, state) {
        final isLoaded = state.status == ProfileStatus.loaded;

        return Scaffold(
          backgroundColor: context.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: isLoaded
              ? CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Edit Profile',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 32),
                            TextField(
                              controller: _firstNameController,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'First Name',
                                filled: true,
                                fillColor: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              controller: _lastNameController,
                              style: theme.textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Last Name',
                                filled: true,
                                fillColor: theme
                                    .colorScheme
                                    .surfaceContainerHighest
                                    .withValues(alpha: 0.2),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.outlineVariant
                                        .withValues(alpha: 0.2),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide(
                                    color: theme.colorScheme.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 16,
                                ),
                              ),
                              textCapitalization: TextCapitalization.words,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _save(),
                            ),
                            const Spacer(),
                            const SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: _save,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 18,
                                ),
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                elevation: 8,
                                shadowColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.5),
                              ),
                              child: Text(
                                'Save Changes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: theme.colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                )
              : Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
        );
      },
    );
  }

  Future<void> _save() async {
    await context.read<ProfileCubit>().updateName(
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
    );
    if (mounted) context.pop();
  }
}
