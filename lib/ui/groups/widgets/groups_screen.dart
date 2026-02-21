import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../domain/models/group.dart';
import '../../../routing/routes.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../blocs/group_bloc.dart';

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<GroupBloc, GroupState>(
          buildWhen: (previous, current) =>
              previous.status != current.status ||
              previous.groups != current.groups,
          builder: (context, state) {
            return CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: _Header(
                    groupCount: state.groups.length,
                    isLoaded: state.status == GroupStatus.loaded ||
                        state.status == GroupStatus.empty,
                  ),
                ),

                // Content
                ...switch (state.status) {
                  GroupStatus.initial ||
                  GroupStatus.loading =>
                    [
                      const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ],
                  GroupStatus.loaded => [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverList.builder(
                        itemCount: state.groups.length,
                        itemBuilder: (context, index) {
                          return _GroupCard(group: state.groups[index]);
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 100)),
                  ],
                  GroupStatus.empty => [
                    const SliverFillRemaining(child: _EmptyGroups()),
                  ],
                  GroupStatus.failure => [
                    SliverFillRemaining(
                      child: Center(
                        child: Text(
                          state.actionError ?? 'Something went wrong',
                          style: TextStyle(color: context.colorScheme.error),
                        ),
                      ),
                    ),
                  ],
                },
              ],
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(Routes.createGroup),
        icon: const Icon(Icons.add),
        label: const Text('New Squad'),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.groupCount, required this.isLoaded});

  final int groupCount;
  final bool isLoaded;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Squads',
                  style: theme.textTheme.headlineLarge,
                ),
                if (isLoaded && groupCount > 0)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      '$groupCount group${groupCount == 1 ? '' : 's'}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface
                            .withValues(alpha: 0.5),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              side: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => context.push(Routes.joinGroup),
            icon: Icon(Icons.link, size: 18, color: theme.colorScheme.primary),
            label: Text(
              'Join',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Group Card ───────────────────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});

  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTap: () => context.push('${Routes.groups}/${group.id}'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest
                .withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.06),
            ),
          ),
          child: Row(
            children: [
              // Emoji avatar
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    group.emoji ?? group.name[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: group.emoji != null ? 28 : 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Name + members
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 14,
                          color: theme.colorScheme.onSurface
                              .withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        if (group.maxMembers != null) ...[
                          Text(
                            ' / ${group.maxMembers}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),

              // Streak or chevron
              if (group.groupStreak > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.primary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.local_fire_department,
                        size: 16,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${group.groupStreak}',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color:
                      theme.colorScheme.onSurface.withValues(alpha: 0.2),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

class _EmptyGroups extends StatelessWidget {
  const _EmptyGroups();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.group_add_outlined,
                size: 40,
                color: theme.colorScheme.primary.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'No squads yet',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Create a squad or join one with an\ninvite code to start your streak.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => context.push(Routes.createGroup),
                icon: const Icon(Icons.add),
                label: const Text('Create a Squad'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(Routes.joinGroup),
                icon: const Icon(Icons.link),
                label: const Text('Join with Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
