import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

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
    return BlocListener<GroupBloc, GroupState>(
      listenWhen: (previous, current) =>
          previous.actionStatus != current.actionStatus,
      listener: (context, state) {
        if (state.actionStatus == GroupActionStatus.success) {
          context.pop();
        } else if (state.actionStatus == GroupActionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.actionError ?? 'Failed to join group')),
          );
        }
      },
      child: BlocSelector<GroupBloc, GroupState, GroupActionStatus>(
        selector: (state) => state.actionStatus,
        builder: (context, actionStatus) {
          final isLoading = actionStatus == GroupActionStatus.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Join Group'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _codeController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Invite Code',
                      hintText: 'e.g. ABC123',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _joinGroup(),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLoading ? null : _joinGroup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Join Group'),
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
