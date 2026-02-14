import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/group_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/group.dart';
import '../../home/widgets/check_in_card.dart';
import '../blocs/group_detail_bloc.dart';

class GroupDetailScreen extends StatelessWidget {
  const GroupDetailScreen({required this.groupId, super.key});

  final String groupId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GroupDetailBloc(
        groupRepository: context.read<GroupRepository>(),
        checkInRepository: context.read<CheckInRepository>(),
      )..add(GroupDetailSubscriptionRequested(groupId)),
      child: const _GroupDetailView(),
    );
  }
}

class _GroupDetailView extends StatelessWidget {
  const _GroupDetailView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GroupDetailBloc, GroupDetailState>(
      builder: (context, state) {
        return switch (state.status) {
          GroupDetailStatus.initial || GroupDetailStatus.loading =>
            const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            ),
          GroupDetailStatus.loaded => _LoadedView(
              group: state.group!,
              todayCheckIns: state.todayCheckIns,
            ),
          GroupDetailStatus.failure => Scaffold(
              appBar: AppBar(),
              body: Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              ),
            ),
        };
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  const _LoadedView({
    required this.group,
    required this.todayCheckIns,
  });

  final Group group;
  final List<CheckIn> todayCheckIns;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _showInviteCode(context, group),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // Group info header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (group.emoji != null)
                    Text(group.emoji!, style: const TextStyle(fontSize: 32)),
                  if (group.emoji != null) const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${group.memberCount} member${group.memberCount == 1 ? '' : 's'}',
                          style: theme.textTheme.bodyLarge,
                        ),
                        if (group.groupStreak > 0)
                          Row(
                            children: [
                              const Icon(Icons.local_fire_department, size: 16),
                              const SizedBox(width: 4),
                              Text(
                                '${group.groupStreak} day streak',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SliverToBoxAdapter(child: Divider(height: 1)),

          // Today's check-ins header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Today's Check-ins",
                style: theme.textTheme.titleMedium,
              ),
            ),
          ),

          // Check-ins list
          if (todayCheckIns.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Center(
                  child: Text('No check-ins yet today. Be the first!'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList.builder(
                itemCount: todayCheckIns.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: CheckInCard(checkIn: todayCheckIns[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  void _showInviteCode(BuildContext context, Group group) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Invite Code', style: theme.textTheme.titleLarge),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  group.inviteCode,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 4,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: group.inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Invite code copied!')),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.copy),
                label: const Text('Copy Code'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
