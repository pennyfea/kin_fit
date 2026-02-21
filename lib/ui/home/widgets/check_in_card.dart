import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/models/check_in.dart';
import '../../../domain/models/user.dart';

/// Full-screen check-in card shown when tapping a wall tile.
///
/// Shows the check-in photo filling the card, with user info
/// overlaid at the bottom and reaction buttons below.
class CheckInCard extends StatelessWidget {
  const CheckInCard({
    required this.checkIn,
    this.user,
    this.onReact,
    super.key,
  });

  final CheckIn checkIn;
  final User? user;
  final ValueChanged<String>? onReact;

  static const _quickReactions = ['💛', '🔥', '😍', '💪', '👏'];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Guard against unbounded height (e.g. inside scrollables)
        final height = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : MediaQuery.of(context).size.height * 0.85;
        return SizedBox(
          height: height,
          width: constraints.maxWidth,
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Photo
              Positioned.fill(
                child: CachedNetworkImage(
                  imageUrl: checkIn.photoUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: Theme.of(context).colorScheme.surfaceContainerLow,
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.5),
                        size: 48,
                      ),
                    ),
                  ),
                ),
              ),

              // Gradient overlay at bottom
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 160,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // User info + caption + reactions at bottom
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        _UserAvatar(user: user, size: 32),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            user?.displayName ?? 'Someone',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (checkIn.effortEmoji != null)
                          Text(
                            checkIn.effortEmoji!,
                            style: const TextStyle(fontSize: 24),
                          ),
                      ],
                    ),
                    if (checkIn.caption != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        checkIn.caption!,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 12),
                    // Reaction bar
                    Row(
                      children: [
                        for (final emoji in _quickReactions)
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: GestureDetector(
                              onTap: () => onReact?.call(emoji),
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  emoji,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _UserAvatar extends StatelessWidget {
  const _UserAvatar({required this.size, this.user});

  final User? user;
  final double size;

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      backgroundImage: user?.photoUrl != null
          ? CachedNetworkImageProvider(user!.photoUrl!)
          : null,
      child: user?.photoUrl == null
          ? Text(
              initials,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: size * 0.4,
              ),
            )
          : null,
    );
  }

  String _getInitials() {
    if (user == null) return '?';
    final first = user!.firstName?.isNotEmpty == true
        ? user!.firstName![0]
        : '';
    final last = user!.lastName?.isNotEmpty == true ? user!.lastName![0] : '';
    if (first.isEmpty && last.isEmpty) return '?';
    return '$first$last'.toUpperCase();
  }
}
