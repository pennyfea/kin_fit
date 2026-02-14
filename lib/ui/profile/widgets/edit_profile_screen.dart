import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
          appBar: AppBar(
            title: const Text('Edit Profile'),
            actions: [
              TextButton(
                onPressed: isLoaded ? _save : null,
                child: const Text('Save'),
              ),
            ],
          ),
          body: isLoaded
              ? Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextField(
                        controller: _firstNameController,
                        decoration: const InputDecoration(
                          labelText: 'First Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _lastNameController,
                        decoration: const InputDecoration(
                          labelText: 'Last Name',
                        ),
                        textCapitalization: TextCapitalization.words,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _save(),
                      ),
                    ],
                  ),
                )
              : const Center(child: CircularProgressIndicator()),
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
