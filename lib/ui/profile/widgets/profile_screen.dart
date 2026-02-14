import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../app/blocs/app_bloc.dart';
import '../../app/blocs/app_event.dart';
import '../blocs/profile_cubit.dart';
import '../blocs/profile_state.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state.status) {
            ProfileStatus.loading =>
              const Center(child: CircularProgressIndicator()),
            ProfileStatus.loaded => _LoadedProfile(state: state),
            ProfileStatus.failure => Center(
                child: Text(state.errorMessage ?? 'Something went wrong'),
              ),
          };
        },
      ),
    );
  }
}

class _LoadedProfile extends StatelessWidget {
  const _LoadedProfile({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = state.user;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        const SizedBox(height: 24),

        // Avatar + name
        Center(
          child: Column(
            children: [
              _Avatar(user: user),
              const SizedBox(height: 16),
              Text(
                user.displayName,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (user.createdAt != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Joined ${_formatDate(user.createdAt!)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 32),

        // Streak stats
        _StatsRow(
          currentStreak: state.calculatedStreak,
          longestStreak: user.longestStreak,
          groupCount: user.groupIds.length,
        ),
        const SizedBox(height: 32),

        // Actions
        _ActionTile(
          icon: Icons.edit_outlined,
          label: 'Edit Profile',
          onTap: () => context.push(Routes.editProfile),
        ),
        _ActionTile(
          icon: Icons.people_outline,
          label: 'My Groups',
          onTap: () => context.push(Routes.groups),
        ),
        const Divider(height: 32),
        _ActionTile(
          icon: Icons.logout,
          label: 'Log Out',
          isDestructive: true,
          onTap: () => _confirmLogout(context),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }

  void _confirmLogout(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                context.read<AppBloc>().add(const AppLogoutRequested());
              },
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(user);

    return CircleAvatar(
      radius: 48,
      backgroundColor: theme.colorScheme.primaryContainer,
      backgroundImage: user.photoUrl != null
          ? CachedNetworkImageProvider(user.photoUrl!)
          : null,
      child: user.photoUrl == null
          ? Text(
              initials,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            )
          : null,
    );
  }

  String _getInitials(User user) {
    final first = user.firstName?.isNotEmpty == true ? user.firstName![0] : '';
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last'.toUpperCase();
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.currentStreak,
    required this.longestStreak,
    required this.groupCount,
  });

  final int currentStreak;
  final int longestStreak;
  final int groupCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            icon: Icons.local_fire_department,
            value: '$currentStreak',
            label: 'Current\nStreak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.emoji_events_outlined,
            value: '$longestStreak',
            label: 'Longest\nStreak',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            icon: Icons.people_outline,
            value: '$groupCount',
            label: 'Groups',
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Icon(icon, size: 24, color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive ? theme.colorScheme.error : null;

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right, size: 20),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }
}
