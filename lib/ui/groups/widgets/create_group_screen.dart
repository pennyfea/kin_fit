import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../app/blocs/app_bloc.dart';
import '../blocs/group_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  int _maxMembers = 4;

  static const _minMembers = 2;
  static const _maxMembersLimit = 12;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createGroup() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final userId = context.read<AppBloc>().state.user.id;
    context.read<GroupBloc>().add(
          GroupCreateRequested(
            name: name,
            userId: userId,
            maxMembers: _maxMembers,
          ),
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
            SnackBar(content: Text(state.actionError ?? 'Failed to create group')),
          );
        }
      },
      child: BlocSelector<GroupBloc, GroupState, GroupActionStatus>(
        selector: (state) => state.actionStatus,
        builder: (context, actionStatus) {
          final isLoading = actionStatus == GroupActionStatus.loading;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Create Group'),
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _nameController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Group Name',
                      hintText: 'e.g. Morning Crew',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _createGroup(),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Group Size',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      IconButton.outlined(
                        onPressed: _maxMembers > _minMembers
                            ? () => setState(() => _maxMembers--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Expanded(
                        child: Center(
                          child: Text(
                            '$_maxMembers members',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      IconButton.outlined(
                        onPressed: _maxMembers < _maxMembersLimit
                            ? () => setState(() => _maxMembers++)
                            : null,
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: isLoading ? null : _createGroup,
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Group'),
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
