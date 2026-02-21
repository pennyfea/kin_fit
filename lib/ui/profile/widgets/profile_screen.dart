import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../../utils/extensions/context_extensions.dart';
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
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return switch (state.status) {
            ProfileStatus.loading => const Center(
                child: CircularProgressIndicator(),
              ),
            ProfileStatus.loaded => _LoadedProfile(state: state),
            ProfileStatus.failure => Center(
                child: Text(
                  state.errorMessage ?? 'Something went wrong',
                  style: TextStyle(color: context.colorScheme.error),
                ),
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
    final user = state.user;

    return CustomScrollView(
      slivers: [
        // No AppBar — edge-to-edge header
        SliverToBoxAdapter(child: _ProfileHeader(user: user, state: state)),

        // Quick stats
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: _QuickStats(state: state),
          ),
        ),

        // Account section
        SliverToBoxAdapter(
          child: _MenuSection(
            title: 'Account',
            children: [
              _MenuItem(
                icon: Icons.person_outline,
                label: 'Edit Profile',
                onTap: () => context.push(Routes.editProfile),
              ),
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                trailing: _ComingSoonChip(),
                onTap: () => _showComingSoon(context, 'Notifications'),
              ),
              _MenuItem(
                icon: Icons.lock_outline_rounded,
                label: 'Privacy',
                trailing: _ComingSoonChip(),
                onTap: () => _showComingSoon(context, 'Privacy settings'),
              ),
            ],
          ),
        ),

        // Social section
        SliverToBoxAdapter(
          child: _MenuSection(
            title: 'Social',
            children: [
              _MenuItem(
                icon: Icons.person_add_outlined,
                label: 'Invite Friends',
                onTap: () => _shareInvite(context),
              ),
              _MenuItem(
                icon: Icons.share_outlined,
                label: 'Share Profile',
                trailing: _ComingSoonChip(),
                onTap: () => _showComingSoon(context, 'Profile sharing'),
              ),
            ],
          ),
        ),

        // Support section
        SliverToBoxAdapter(
          child: _MenuSection(
            title: 'Support',
            children: [
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & FAQ',
                onTap: () => _openUrl('https://bodsquad.app/help'),
              ),
              _MenuItem(
                icon: Icons.chat_bubble_outline_rounded,
                label: 'Contact Us',
                onTap: () => _openUrl('mailto:support@bodsquad.app'),
              ),
              _MenuItem(
                icon: Icons.star_outline_rounded,
                label: 'Rate the App',
                onTap: () => _showComingSoon(context, 'App Store rating'),
              ),
            ],
          ),
        ),

        // Legal section
        SliverToBoxAdapter(
          child: _MenuSection(
            title: 'Legal',
            children: [
              _MenuItem(
                icon: Icons.description_outlined,
                label: 'Terms of Service',
                onTap: () => _openUrl('https://bodsquad.app/terms'),
              ),
              _MenuItem(
                icon: Icons.shield_outlined,
                label: 'Privacy Policy',
                onTap: () => _openUrl('https://bodsquad.app/privacy'),
              ),
            ],
          ),
        ),

        // Danger zone
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _DangerButton(
                  label: 'Log Out',
                  onTap: () => _confirmLogout(context),
                ),
                const SizedBox(height: 12),
                _DangerButton(
                  label: 'Delete Account',
                  isDelete: true,
                  onTap: () => _confirmDeleteAccount(context),
                ),
              ],
            ),
          ),
        ),

        // Version info
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
            child: _VersionInfo(),
          ),
        ),
      ],
    );
  }

  void _shareInvite(BuildContext context) {
    Clipboard.setData(
      const ClipboardData(text: 'Join me on Bod Squad! https://bodsquad.app'),
    );
    context.showSnackBar('Invite link copied!');
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showComingSoon(BuildContext context, String feature) {
    context.showSnackBar('$feature coming soon!');
  }

  void _confirmLogout(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.logout_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Log Out?',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'You can always log back in with your phone number.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      context.read<AppBloc>().add(const AppLogoutRequested());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Log Out'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmDeleteAccount(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colorScheme.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 24),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: theme.colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Delete Account?',
                  style: theme.textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'This will permanently delete your account, check-ins, and remove you from all groups. This cannot be undone.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                      _showComingSoon(context, 'Account deletion');
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Delete My Account'),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => Navigator.pop(sheetContext),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ─── Profile Header ──────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user, required this.state});

  final User user;
  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.of(context).padding.top + 20,
        20,
        24,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.08),
            theme.colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        children: [
          // Settings gear top-right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () =>
                  _showComingSoon(context),
              icon: Icon(
                Icons.settings_outlined,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ),

          // Avatar with glow
          _Avatar(user: user),
          const SizedBox(height: 20),

          // Name
          Text(
            user.displayName,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),

          // Member since
          if (user.createdAt != null) ...[
            const SizedBox(height: 6),
            Text(
              'Member since ${_formatDate(user.createdAt!)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    context.showSnackBar('Settings coming soon!');
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[date.month - 1]} ${date.year}';
  }
}

// ─── Avatar ──────────────────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  const _Avatar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initials = _getInitials(user);

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 32,
            spreadRadius: 8,
          ),
        ],
      ),
      child: CircleAvatar(
        radius: 52,
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: user.photoUrl != null
            ? CachedNetworkImageProvider(user.photoUrl!)
            : null,
        child: user.photoUrl == null
            ? Text(
                initials,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w900,
                ),
              )
            : null,
      ),
    );
  }

  String _getInitials(User user) {
    final first = user.firstName?.isNotEmpty == true ? user.firstName![0] : '';
    final last = user.lastName?.isNotEmpty == true ? user.lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last'.toUpperCase();
  }
}

// ─── Quick Stats ─────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.state});

  final ProfileState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              value: '${state.calculatedStreak}',
              label: 'Day Streak',
              icon: Icons.local_fire_department,
              color: theme.colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),
          Expanded(
            child: _StatItem(
              value: '${state.user.longestStreak}',
              label: 'Best Streak',
              icon: Icons.emoji_events_outlined,
              color: Colors.amber,
            ),
          ),
          Container(
            width: 1,
            height: 40,
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.15),
          ),
          Expanded(
            child: _StatItem(
              value: '${state.user.groupIds.length}',
              label: 'Groups',
              icon: Icons.people_outline,
              color: Colors.cyanAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 6),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }
}

// ─── Menu Section ────────────────────────────────────────────────────────────

class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              title.toUpperCase(),
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(
                      height: 1,
                      indent: 56,
                      color: theme.colorScheme.outlineVariant
                          .withValues(alpha: 0.08),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Menu Item ───────────────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 4),
            ],
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Coming Soon Chip ────────────────────────────────────────────────────────

class _ComingSoonChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        'Soon',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.primary,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ─── Danger Buttons ──────────────────────────────────────────────────────────

class _DangerButton extends StatelessWidget {
  const _DangerButton({
    required this.label,
    required this.onTap,
    this.isDelete = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool isDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.error;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: isDelete ? 0.08 : 0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: isDelete ? 0.2 : 0.1),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Version Info ────────────────────────────────────────────────────────────

class _VersionInfo extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.hasData
            ? 'v${snapshot.data!.version} (${snapshot.data!.buildNumber})'
            : '';

        return Center(
          child: Text(
            'Bod Squad $version',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
        );
      },
    );
  }
}
