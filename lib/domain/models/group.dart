import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'group.g.dart';

/// Represents a fitness accountability group.
@JsonSerializable(explicitToJson: true)
class Group extends Equatable {
  const Group({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.creatorId,
    this.emoji,
    this.memberIds = const [],
    this.maxMembers,
    this.groupStreak = 0,
    this.longestGroupStreak = 0,
    this.createdAt,
  });

  final String id;
  final String name;
  final String? emoji;
  final String inviteCode;
  final String creatorId;
  final List<String> memberIds;
  final int? maxMembers;
  final int groupStreak;
  final int longestGroupStreak;
  final DateTime? createdAt;

  static const empty = Group(
    id: '',
    name: '',
    inviteCode: '',
    creatorId: '',
  );

  bool get isEmpty => this == empty;
  bool get isNotEmpty => this != empty;

  int get memberCount => memberIds.length;
  bool get isFull => maxMembers != null && memberIds.length >= maxMembers!;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);
  Map<String, dynamic> toJson() => _$GroupToJson(this);

  factory Group.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Group(
      id: documentId,
      name: data['name'] as String? ?? '',
      emoji: data['emoji'] as String?,
      inviteCode: data['invite_code'] as String? ?? '',
      creatorId: data['creator_id'] as String? ?? '',
      memberIds: List<String>.from(data['member_ids'] as List? ?? []),
      maxMembers: (data['max_members'] as num?)?.toInt(),
      groupStreak: (data['group_streak'] as num?)?.toInt() ?? 0,
      longestGroupStreak:
          (data['longest_group_streak'] as num?)?.toInt() ?? 0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'emoji': emoji,
      'invite_code': inviteCode,
      'creator_id': creatorId,
      'member_ids': memberIds,
      'max_members': maxMembers,
      'group_streak': groupStreak,
      'longest_group_streak': longestGroupStreak,
      'created_at': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
    };
  }

  Group copyWith({
    String? id,
    String? name,
    String? emoji,
    String? inviteCode,
    String? creatorId,
    List<String>? memberIds,
    int? maxMembers,
    int? groupStreak,
    int? longestGroupStreak,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      inviteCode: inviteCode ?? this.inviteCode,
      creatorId: creatorId ?? this.creatorId,
      memberIds: memberIds ?? this.memberIds,
      maxMembers: maxMembers ?? this.maxMembers,
      groupStreak: groupStreak ?? this.groupStreak,
      longestGroupStreak: longestGroupStreak ?? this.longestGroupStreak,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        emoji,
        inviteCode,
        creatorId,
        memberIds,
        maxMembers,
        groupStreak,
        longestGroupStreak,
        createdAt,
      ];
}
