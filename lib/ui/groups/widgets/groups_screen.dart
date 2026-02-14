import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/group.dart';
import '../../../routing/routes.dart';
import '../blocs/group_bloc.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Groups'),
        actions: [
          TextButton.icon(
            onPressed: () => context.push(Routes.joinGroup),
            icon: const Icon(Icons.link, size: 18),
            label: const Text('Join'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: BlocBuilder<GroupBloc, GroupState>(
        buildWhen: (previous, current) =>
            previous.status != current.status ||
            previous.groups != current.groups,
        builder: (context, state) {
          return switch (state.status) {
            GroupStatus.initial || GroupStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            GroupStatus.loaded => _GroupsList(groups: state.groups),
            GroupStatus.empty => const _EmptyGroups(),
            GroupStatus.failure =>
              Center(child: Text(state.actionError ?? 'Something went wrong')),
          };
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(Routes.createGroup),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _GroupsList extends StatelessWidget {
  const _GroupsList({required this.groups});

  final List<Group> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        return _GroupCard(group: group);
      },
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Text(
            group.emoji ?? group.name[0].toUpperCase(),
            style: TextStyle(
              fontSize: group.emoji != null ? 24 : 18,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
        title: Text(group.name),
        subtitle: Text(
          '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
        ),
        trailing: group.groupStreak > 0
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, size: 18),
                  const SizedBox(width: 4),
                  Text('${group.groupStreak}'),
                ],
              )
            : null,
        onTap: () => context.push('${Routes.groups}/${group.id}'),
      ),
    );
  }
}

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.group_add_outlined,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'No groups yet',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Create a group or join one with an invite code to start your fitness streak.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
