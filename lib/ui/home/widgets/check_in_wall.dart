import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';
import '../blocs/feed_state.dart';
import 'check_in_card.dart';

/// Wall view showing today's check-ins as a scrolling feed.
class CheckInWall extends StatelessWidget {
  const CheckInWall({
    required this.feedState,
    required this.currentUserId,
    this.onTapCheckIn,
    this.onReact,
    super.key,
  });

  final FeedState feedState;
  final String currentUserId;
  final void Function(CheckIn checkIn, User? user)? onTapCheckIn;
  final void Function(CheckIn checkIn, String emoji)? onReact;

  @override
  Widget build(BuildContext context) {
    // Build ordered list: user first, then checked-in, then not-checked-in
    final checkedInUserIds = feedState.checkIns.map((c) => c.userId).toSet();
    final notCheckedInIds = feedState.allMemberIds.difference(checkedInUserIds);

    // User's own check-in first
    final myCheckIn = feedState.checkIns
        .where((c) => c.userId == currentUserId)
        .toList();

    // Others who checked in
    final othersCheckedIn = feedState.checkIns
        .where((c) => c.userId != currentUserId)
        .toList();

    // Deduplicate (a user might have check-ins in multiple groups)
    final seenUserIds = <String>{};
    final uniqueOthersCheckedIn = <CheckIn>[];
    for (final c in othersCheckedIn) {
      if (seenUserIds.add(c.userId)) {
        uniqueOthersCheckedIn.add(c);
      }
    }

    // Members who haven't checked in (excluding self)
    final missingIds = notCheckedInIds
        .where((id) => id != currentUserId)
        .toList();

    final totalItems =
        (myCheckIn.isNotEmpty ? 1 : 0) +
        uniqueOthersCheckedIn.length +
        missingIds.length;

    if (totalItems == 0) {
      return Container(
        color: Theme.of(context).colorScheme.surface,
        child: Center(
          child: Text(
            'No group members yet',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    final checkedInCount =
        (myCheckIn.isNotEmpty ? 1 : 0) + uniqueOthersCheckedIn.length;
    final totalMembers = feedState.allMemberIds.length;

    return SafeArea(
      child: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            // Header: "Today's Check-ins" and progress
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Today's Feed",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest
                          .withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$checkedInCount / $totalMembers',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Feed
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 24,
                  top: 0,
                ),
                itemCount: totalItems,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  // User's own check-in at index 0
                  if (myCheckIn.isNotEmpty && index == 0) {
                    return _buildFeedCard(
                      context,
                      myCheckIn.first,
                      feedState.users[currentUserId],
                    );
                  }

                  final adjustedIndex = index - (myCheckIn.isNotEmpty ? 1 : 0);

                  if (adjustedIndex < uniqueOthersCheckedIn.length) {
                    final checkIn = uniqueOthersCheckedIn[adjustedIndex];
                    final user = feedState.users[checkIn.userId];
                    return _buildFeedCard(context, checkIn, user);
                  }

                  // Not checked in — Missing tile
                  final missingIndex =
                      adjustedIndex - uniqueOthersCheckedIn.length;
                  final missingUserId = missingIds[missingIndex];
                  final missingUser = feedState.users[missingUserId];
                  return SizedBox(
                    height: 120, // Smaller tile for missing users
                    child: _MissingTile(
                      user: missingUser,
                      index: missingIndex,
                      totalMissing: missingIds.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(BuildContext context, CheckIn checkIn, User? user) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: CheckInCard(
          checkIn: checkIn,
          user: user,
          onReact: (emoji) => onReact?.call(checkIn, emoji),
        ),
      ),
    );
  }
}

/// Tile for a member who has NOT checked in — greyed out photo or Lottie.
///
/// The alarm-clock Lottie plays on one tile at a time, cycling through
/// all missing tiles so we don't run N animations simultaneously.
class _MissingTile extends StatefulWidget {
  const _MissingTile({
    required this.index,
    required this.totalMissing,
    this.user,
  });

  final User? user;
  final int index;
  final int totalMissing;

  @override
  State<_MissingTile> createState() => _MissingTileState();
}

class _MissingTileState extends State<_MissingTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _lottieController;
  LottieComposition? _composition;
  bool _isMyTurn = false;

  /// Each tile's turn lasts this long (Lottie duration + pause).
  static const _turnDuration = Duration(seconds: 6);

  static const _assetPath = 'assets/animations/alarm-clock-falling.json';

  @override
  void initState() {
    super.initState();
    _lottieController = AnimationController(vsync: this);
    _loadComposition();
  }

  Future<void> _loadComposition() async {
    final composition = await AssetLottie(_assetPath).load();
    if (!mounted) return;
    _composition = composition;
    _lottieController.duration = composition.duration;
    _startCycle();
  }

  void _startCycle() {
    final total = widget.totalMissing.clamp(1, 100);
    final cycleDuration = _turnDuration * total;
    final myDelay = _turnDuration * widget.index;

    // Wait for initial offset, then repeat on the full cycle
    Future.delayed(myDelay, () {
      if (!mounted) return;
      _playOnce();
      // Set up repeating cycle
      _scheduleNext(cycleDuration);
    });
  }

  void _scheduleNext(Duration cycleDuration) {
    // After our animation finishes, wait for the rest of the cycle
    final waitTime = cycleDuration - _turnDuration;
    Future.delayed(waitTime, () {
      if (!mounted) return;
      _playOnce();
      _scheduleNext(cycleDuration);
    });
  }

  void _playOnce() {
    if (!mounted) return;
    setState(() => _isMyTurn = true);
    _lottieController.reset();
    _lottieController.forward().then((_) {
      if (mounted) setState(() => _isMyTurn = false);
    });
  }

  @override
  void dispose() {
    _lottieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.user?.photoUrl != null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background: greyed-out profile photo or dark fallback
          if (hasPhoto)
            ColorFiltered(
              colorFilter: const ColorFilter.matrix(<double>[
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: CachedNetworkImage(
                imageUrl: widget.user!.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Theme.of(context).colorScheme.surfaceContainer,
                ),
              ),
            )
          else
            Container(color: Theme.of(context).colorScheme.surfaceContainer),

          // Dark overlay
          Container(
            color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.4),
          ),

          // Lottie alarm clock — centered, plays when it's this tile's turn
          if (_isMyTurn && _composition != null)
            Center(
              child: SizedBox(
                width: 64,
                height: 64,
                child: Lottie(
                  composition: _composition!,
                  controller: _lottieController,
                ),
              ),
            )
          else if (!hasPhoto)
            Center(
              child: Icon(
                Icons.person_outline,
                color: Theme.of(
                  context,
                ).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                size: 48,
              ),
            ),

          // Name + "Not yet" at bottom
          Positioned(
            left: 8,
            right: 8,
            bottom: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.user?.firstName ??
                      widget.user?.displayName ??
                      'Unknown',
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Not yet',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
