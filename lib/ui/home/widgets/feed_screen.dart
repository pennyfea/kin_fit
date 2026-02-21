import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';
import '../../../routing/routes.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/feed_cubit.dart';
import '../blocs/feed_state.dart';
import 'check_in_card.dart';
import 'check_in_wall.dart';

/// The Feed tab screen — shows today's check-ins across all groups.
///
/// If the user hasn't checked in yet, shows a CTA to open the camera.
/// If they have, shows the check-in wall.
class FeedScreen extends StatelessWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FeedCubit, FeedState>(
      builder: (context, feedState) {
        if (feedState.status == FeedStatus.loading ||
            feedState.status == FeedStatus.initial) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (feedState.hasCheckedIn) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.surface,
            body: _CheckedInFeed(feedState: feedState),
          );
        }

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          body: const _NotCheckedInView(),
        );
      },
    );
  }
}

/// Feed view when the user HAS checked in — shows the wall.
class _CheckedInFeed extends StatelessWidget {
  const _CheckedInFeed({required this.feedState});

  final FeedState feedState;

  @override
  Widget build(BuildContext context) {
    final currentUserId = context.read<AppBloc>().state.user.id;

    return CheckInWall(
      feedState: feedState,
      currentUserId: currentUserId,
      onTapCheckIn: (checkIn, user) => _onTapCheckIn(context, checkIn, user),
      onReact: (checkIn, emoji) => _onReact(context, checkIn, emoji),
    );
  }

  void _onTapCheckIn(BuildContext context, CheckIn checkIn, User? user) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: CheckInCard(
            checkIn: checkIn,
            user: user,
            onReact: (emoji) => _onReact(context, checkIn, emoji),
          ),
        ),
      ),
    );
  }

  void _onReact(BuildContext context, CheckIn checkIn, String emoji) {
    final userId = context.read<AppBloc>().state.user.id;
    context.read<CheckInRepository>().addReaction(
      groupId: checkIn.groupId,
      checkInId: checkIn.id,
      userId: userId,
      emoji: emoji,
    );
  }
}

/// View when the user has NOT checked in yet — CTA to open camera.
class _NotCheckedInView extends StatelessWidget {
  const _NotCheckedInView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.camera_alt_outlined,
                  size: 64,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'Check in to see\nyour friends',
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 12),
              Text(
                'Snap a photo of your workout to unlock the feed.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => context.push(Routes.camera),
                  style: ElevatedButton.styleFrom(elevation: 0),
                  child: const Text('Check In Now'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
