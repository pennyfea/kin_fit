import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../utils/extensions/context_extensions.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/group_bloc.dart';

class JoinGroupScreen extends StatefulWidget {
  const JoinGroupScreen({super.key});

  @override
  State<JoinGroupScreen> createState() => _JoinGroupScreenState();
}

class _JoinGroupScreenState extends State<JoinGroupScreen> {
  final _codeController = TextEditingController();

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _joinGroup() {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final userId = context.read<AppBloc>().state.user.id;
    context.read<GroupBloc>().add(
      GroupJoinRequested(inviteCode: code, userId: userId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == GroupActionStatus.success) {
          context.pop();
        } else if (state.actionStatus == GroupActionStatus.failure) {
          context.showSnackBar(
            state.actionError ?? 'Failed to join group',
          );
        }
      },
      child: BlocSelector<GroupBloc, GroupState, GroupActionStatus>(
        selector: (state) => state.actionStatus,
        builder: (context, actionStatus) {
          final isLoading = actionStatus == GroupActionStatus.loading;

          return Scaffold(
            backgroundColor: context.colorScheme.surface,
            appBar: AppBar(title: const Text('Join Squad')),
            body: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Illustration
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.link_rounded,
                          size: 40,
                          color: theme.colorScheme.primary
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Enter the 6-character invite code\nshared by your squad leader.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Code field
                  TextField(
                    controller: _codeController,
                    autofocus: true,
                    textAlign: TextAlign.center,
                    style: context.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 6,
                    ),
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'ABC123',
                      counterText: '',
                      hintStyle: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: 6,
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.15),
                      ),
                    ),
                    onSubmitted: (_) => _joinGroup(),
                  ),

                  const Spacer(),

                  // Join button
                  SizedBox(
                    height: 60,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _joinGroup,
                      child: isLoading
                          ? SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                strokeWidth: 3,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  context.colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : const Text('Join Squad'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
