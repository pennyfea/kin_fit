import 'package:equatable/equatable.dart';

enum StatsStatus { loading, loaded, failure }

class StatsState extends Equatable {
  const StatsState({
    this.status = StatsStatus.loading,
    this.currentStreak = 0,
    this.longestStreak = 0,
    this.groupCount = 0,
    this.totalCheckIns = 0,
    this.weeklyActivity = const [false, false, false, false, false, false, false],
    this.memberSince,
    this.errorMessage,
  });

  final StatsStatus status;
  final int currentStreak;
  final int longestStreak;
  final int groupCount;
  final int totalCheckIns;

  /// 7 bools for Mon–Sun of the current week (true = checked in that day).
  final List<bool> weeklyActivity;

  final DateTime? memberSince;
  final String? errorMessage;

  /// How many days this week the user checked in.
  int get weeklyCount => weeklyActivity.where((d) => d).length;

  StatsState copyWith({
    StatsStatus? status,
    int? currentStreak,
    int? longestStreak,
    int? groupCount,
    int? totalCheckIns,
    List<bool>? weeklyActivity,
    DateTime? memberSince,
    String? errorMessage,
  }) {
    return StatsState(
      status: status ?? this.status,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      groupCount: groupCount ?? this.groupCount,
      totalCheckIns: totalCheckIns ?? this.totalCheckIns,
      weeklyActivity: weeklyActivity ?? this.weeklyActivity,
      memberSince: memberSince ?? this.memberSince,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentStreak,
    longestStreak,
    groupCount,
    totalCheckIns,
    weeklyActivity,
    memberSince,
    errorMessage,
  ];
}
