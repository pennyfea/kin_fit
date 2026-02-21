import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/check_in_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../utils/extensions/context_extensions.dart';
import '../../app/blocs/app_bloc.dart';
import '../blocs/stats_cubit.dart';
import '../blocs/stats_state.dart';

/// The Stats tab screen — streaks, weekly progress, and personal records.
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = context.select<AppBloc, String>(
      (bloc) => bloc.state.user.id,
    );

    return BlocProvider(
      create: (context) => StatsCubit(
        userRepository: context.read<UserRepository>(),
        checkInRepository: context.read<CheckInRepository>(),
        userId: userId,
      )..load(),
      child: const _StatsView(),
    );
  }
}

class _StatsView extends StatelessWidget {
  const _StatsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<StatsCubit, StatsState>(
          builder: (context, state) {
            if (state.status == StatsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              children: [
                const SizedBox(height: 24),
                Text(
                  'Your Stats',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                const SizedBox(height: 24),

                // Hero streak
                _HeroStreakCard(streak: state.currentStreak),
                const SizedBox(height: 16),

                // Stats grid — 2x2
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.emoji_events_outlined,
                        value: '${state.longestStreak}',
                        label: 'Best Streak',
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.camera_alt_outlined,
                        value: '${state.totalCheckIns}',
                        label: 'Check-ins',
                        color: Colors.cyanAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        icon: Icons.people_outline,
                        value: '${state.groupCount}',
                        label: 'Groups',
                        color: Colors.purpleAccent,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        icon: Icons.check_circle_outline,
                        value: '${state.weeklyCount}/7',
                        label: 'This Week',
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Weekly progress
                _WeeklyProgress(activity: state.weeklyActivity),
                const SizedBox(height: 28),

                // Motivational card
                _MotivationCard(streak: state.currentStreak),
                const SizedBox(height: 28),

                // Activity calendar placeholder
                _CalendarPlaceholder(),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ─── Hero Streak Card ────────────────────────────────────────────────────────

class _HeroStreakCard extends StatelessWidget {
  const _HeroStreakCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.15),
            theme.colorScheme.primary.withValues(alpha: 0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          // Fire icon with glow
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: theme.colorScheme.primary.withValues(alpha: 0.12),
            ),
            child: Icon(
              Icons.local_fire_department,
              size: 36,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$streak',
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak == 1 ? 'Day Streak' : 'Day Streak',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Streak emoji based on length
          Text(
            _streakEmoji(streak),
            style: const TextStyle(fontSize: 32),
          ),
        ],
      ),
    );
  }

  String _streakEmoji(int streak) {
    if (streak >= 30) return '👑';
    if (streak >= 14) return '⚡';
    if (streak >= 7) return '💪';
    if (streak >= 3) return '🔥';
    if (streak >= 1) return '✨';
    return '😴';
  }
}

// ─── Stat Card ───────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
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

// ─── Weekly Progress ─────────────────────────────────────────────────────────

class _WeeklyProgress extends StatelessWidget {
  const _WeeklyProgress({required this.activity});

  final List<bool> activity;

  static const _dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final todayIndex = DateTime.now().weekday - 1; // 0=Mon

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'This Week',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${activity.where((d) => d).length} of 7 days',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final isActive = activity[i];
              final isToday = i == todayIndex;
              final isFuture = i > todayIndex;

              return _DayDot(
                label: _dayLabels[i],
                isActive: isActive,
                isToday: isToday,
                isFuture: isFuture,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  const _DayDot({
    required this.label,
    required this.isActive,
    required this.isToday,
    required this.isFuture,
  });

  final String label;
  final bool isActive;
  final bool isToday;
  final bool isFuture;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final Color dotColor;
    final Color borderColor;
    final Widget? child;

    if (isActive) {
      dotColor = primary;
      borderColor = primary;
      child = const Icon(Icons.check, size: 18, color: Colors.black);
    } else if (isToday) {
      dotColor = Colors.transparent;
      borderColor = primary.withValues(alpha: 0.5);
      child = null;
    } else if (isFuture) {
      dotColor = theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2);
      borderColor = Colors.transparent;
      child = null;
    } else {
      // Past, missed
      dotColor = theme.colorScheme.error.withValues(alpha: 0.1);
      borderColor = theme.colorScheme.error.withValues(alpha: 0.3);
      child = Icon(
        Icons.close,
        size: 14,
        color: theme.colorScheme.error.withValues(alpha: 0.5),
      );
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: dotColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 2),
          ),
          child: child != null ? Center(child: child) : null,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isToday
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
            fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Motivation Card ─────────────────────────────────────────────────────────

class _MotivationCard extends StatelessWidget {
  const _MotivationCard({required this.streak});

  final int streak;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = _getMessage(streak);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.06),
            theme.colorScheme.primary.withValues(alpha: 0.02),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Text(message.emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message.body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _Motivation _getMessage(int streak) {
    if (streak == 0) {
      return const _Motivation(
        emoji: '🏁',
        title: 'Start your streak!',
        body: 'Check in today to get your first day on the board.',
      );
    }
    if (streak < 3) {
      return const _Motivation(
        emoji: '🌱',
        title: 'Building momentum',
        body: 'Keep it up — 3 days in a row is your next milestone.',
      );
    }
    if (streak < 7) {
      return _Motivation(
        emoji: '🔥',
        title: '$streak days strong!',
        body: 'You\'re close to a full week. Don\'t break the chain!',
      );
    }
    if (streak < 14) {
      return const _Motivation(
        emoji: '💪',
        title: 'One week down!',
        body: 'Hit 14 days and you\'ll be in the top tier of consistency.',
      );
    }
    if (streak < 30) {
      return _Motivation(
        emoji: '⚡',
        title: 'Unstoppable!',
        body: '$streak days — you\'re building a real habit. 30 days is next.',
      );
    }
    return _Motivation(
      emoji: '👑',
      title: 'Legend status',
      body: '$streak days and counting. You\'re an inspiration.',
    );
  }
}

class _Motivation {
  const _Motivation({
    required this.emoji,
    required this.title,
    required this.body,
  });

  final String emoji;
  final String title;
  final String body;
}

// ─── Calendar Placeholder ────────────────────────────────────────────────────

class _CalendarPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.calendar_month_outlined,
            size: 40,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 12),
          Text(
            'Activity Calendar',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Coming soon',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.25),
            ),
          ),
        ],
      ),
    );
  }
}
