import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';
import '../blocs/feed_state.dart';

/// Wall view showing today's check-ins as a grid.
///
/// Checked-in members show their photo. Members who haven't
/// checked in appear as greyed-out avatars (wall of shame).
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
    final notCheckedInIds =
        feedState.allMemberIds.difference(checkedInUserIds);

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

    final totalItems = (myCheckIn.isNotEmpty ? 1 : 0) +
        uniqueOthersCheckedIn.length +
        missingIds.length;

    if (totalItems == 0) {
      return Container(
        color: Colors.grey[900],
        child: Center(
          child: Text(
            'No group members yet',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final checkedInCount =
        (myCheckIn.isNotEmpty ? 1 : 0) + uniqueOthersCheckedIn.length;
    final totalMembers = feedState.allMemberIds.length;

    return Container(
      color: Colors.grey[900],
      child: Column(
        children: [
          // Header: check-in progress
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                Text(
                  '$checkedInCount / $totalMembers checked in',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
        padding: const EdgeInsets.all(8),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: totalItems,
        itemBuilder: (context, index) {
          // User's own check-in at index 0
          if (myCheckIn.isNotEmpty && index == 0) {
            return _CheckedInTile(
              checkIn: myCheckIn.first,
              user: feedState.users[currentUserId],
              isCurrentUser: true,
              onTap: () => onTapCheckIn?.call(
                myCheckIn.first,
                feedState.users[currentUserId],
              ),
            );
          }

          final adjustedIndex =
              index - (myCheckIn.isNotEmpty ? 1 : 0);

          if (adjustedIndex < uniqueOthersCheckedIn.length) {
            final checkIn = uniqueOthersCheckedIn[adjustedIndex];
            final user = feedState.users[checkIn.userId];
            return _CheckedInTile(
              checkIn: checkIn,
              user: user,
              isCurrentUser: false,
              onTap: () => onTapCheckIn?.call(checkIn, user),
            );
          }

          // Not checked in — wall of shame
          final missingIndex =
              adjustedIndex - uniqueOthersCheckedIn.length;
          final missingUserId = missingIds[missingIndex];
          final missingUser = feedState.users[missingUserId];
          return _MissingTile(
            user: missingUser,
            index: missingIndex,
            totalMissing: missingIds.length,
          );
        },
      ),
          ),
        ],
      ),
    );
  }
}

/// Tile for a member who HAS checked in — shows their photo.
class _CheckedInTile extends StatelessWidget {
  const _CheckedInTile({
    required this.checkIn,
    this.user,
    required this.isCurrentUser,
    this.onTap,
  });

  final CheckIn checkIn;
  final User? user;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Photo
            CachedNetworkImage(
              imageUrl: checkIn.photoUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(color: Colors.grey[800]),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[800],
                child: const Icon(Icons.broken_image, color: Colors.white38),
              ),
            ),

            // Gradient at bottom
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: 56,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            // Name + emoji
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isCurrentUser
                          ? 'You'
                          : user?.firstName ?? user?.displayName ?? 'Someone',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (checkIn.effortEmoji != null)
                    Text(
                      checkIn.effortEmoji!,
                      style: const TextStyle(fontSize: 16),
                    ),
                ],
              ),
            ),

            // "You" badge
            if (isCurrentUser)
              Positioned(
                left: 8,
                top: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Your check-in',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
          ],
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
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0.2126, 0.7152, 0.0722, 0, 0,
                0,      0,      0,      1, 0,
              ]),
              child: CachedNetworkImage(
                imageUrl: widget.user!.photoUrl!,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.grey[800]),
                errorWidget: (_, __, ___) =>
                    Container(color: Colors.grey[800]),
              ),
            )
          else
            Container(color: Colors.grey[800]),

          // Dark overlay
          Container(color: Colors.black.withValues(alpha: 0.4)),

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
                color: Colors.grey[600],
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  'Not yet',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
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
