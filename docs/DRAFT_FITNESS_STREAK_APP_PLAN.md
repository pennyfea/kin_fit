# Fitness Streak Accountability App - Implementation Plan

> A social fitness accountability app inspired by Locket. Users share daily workout check-ins with close friends to build consistency through streaks and social motivation.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Data Models](#data-models)
4. [Firebase Structure](#firebase-structure)
5. [Features & Screens](#features--screens)
6. [Implementation Phases](#implementation-phases)
7. [Technical Considerations](#technical-considerations)

---

## Project Overview

### Core Value Proposition
Friends working out together get daily accountability, motivation through streaks, and simple consistency tracking without complex fitness logging.

### Design Philosophy
- **Low friction** - One tap to check in
- **Supportive** - Encouragement over judgment
- **Private** - Small groups, not public feeds
- **Consistency over intensity** - Celebrate showing up

### Target Users
- Gym buddies
- Friends training together
- Postpartum moms
- Couples
- Accountability partners
- Beginners intimidated by traditional fitness apps

---

## Architecture

Following the Flutter template's hybrid organization:

```
lib/
├── data/                          # Data layer (shared)
│   ├── repositories/
│   │   ├── authentication_repository.dart
│   │   ├── user_repository.dart
│   │   ├── group_repository.dart
│   │   ├── check_in_repository.dart
│   │   └── streak_repository.dart
│   ├── services/
│   │   ├── storage_service.dart   # Firebase Storage for photos
│   │   ├── notification_service.dart
│   │   └── widget_service.dart    # iOS widget data
│   └── models/                    # API/Firestore models
│       ├── api_user.dart
│       ├── api_group.dart
│       └── api_check_in.dart
│
├── domain/                        # Domain layer
│   └── models/
│       ├── user.dart
│       ├── group.dart
│       ├── check_in.dart
│       ├── streak.dart
│       └── reaction.dart
│
├── ui/                            # UI layer (by feature)
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_theme.dart
│   │   │   └── streak_theme.dart  # Streak visual styles
│   │   └── widgets/
│   │       ├── streak_badge.dart
│   │       ├── avatar_circle.dart
│   │       ├── photo_card.dart
│   │       └── emoji_picker.dart
│   │
│   ├── auth/                      # Authentication feature
│   │   ├── blocs/
│   │   │   ├── auth_bloc.dart
│   │   │   └── login_cubit.dart
│   │   └── widgets/
│   │       ├── login_screen.dart
│   │       ├── signup_screen.dart
│   │       └── onboarding_screen.dart
│   │
│   ├── home/                      # Main feed feature
│   │   ├── blocs/
│   │   │   └── feed_bloc.dart
│   │   └── widgets/
│   │       ├── home_screen.dart
│   │       ├── feed_list.dart
│   │       └── check_in_card.dart
│   │
│   ├── check_in/                  # Check-in feature
│   │   ├── blocs/
│   │   │   └── check_in_cubit.dart
│   │   └── widgets/
│   │       ├── check_in_screen.dart
│   │       ├── camera_view.dart
│   │       └── caption_input.dart
│   │
│   ├── groups/                    # Groups feature
│   │   ├── blocs/
│   │   │   ├── groups_bloc.dart
│   │   │   └── group_detail_bloc.dart
│   │   └── widgets/
│   │       ├── groups_screen.dart
│   │       ├── group_detail_screen.dart
│   │       ├── create_group_screen.dart
│   │       ├── join_group_screen.dart
│   │       └── member_list.dart
│   │
│   ├── streaks/                   # Streaks feature
│   │   ├── blocs/
│   │   │   └── streak_bloc.dart
│   │   └── widgets/
│   │       ├── streak_screen.dart
│   │       ├── streak_calendar.dart
│   │       └── streak_stats.dart
│   │
│   ├── profile/                   # Profile feature
│   │   ├── blocs/
│   │   │   └── profile_cubit.dart
│   │   └── widgets/
│   │       ├── profile_screen.dart
│   │       ├── edit_profile_screen.dart
│   │       └── settings_screen.dart
│   │
│   └── notifications/             # Notifications feature
│       ├── blocs/
│       │   └── notification_cubit.dart
│       └── widgets/
│           └── notification_settings_screen.dart
│
├── routing/
│   ├── app_router.dart
│   └── routes.dart
│
└── main.dart
```

---

## Data Models

### User

```dart
class User extends Equatable {
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int currentStreak;          // Personal streak count
  final int longestStreak;          // All-time best
  final DateTime? lastCheckInDate;
  final List<String> groupIds;
  final DateTime createdAt;

  // Computed
  bool get hasCheckedInToday => ...;
}
```

### Group

```dart
class Group extends Equatable {
  final String id;
  final String name;
  final String? emoji;              // Group icon emoji
  final String inviteCode;          // 6-char code for joining
  final String creatorId;
  final List<String> memberIds;     // Max 10
  final int groupStreak;            // Resets if ANY member misses
  final int longestGroupStreak;
  final DateTime createdAt;

  // Computed
  int get memberCount => memberIds.length;
  bool get isFull => memberIds.length >= 10;
}
```

### CheckIn

```dart
class CheckIn extends Equatable {
  final String id;
  final String userId;
  final String groupId;
  final String photoUrl;
  final String? caption;            // Optional, max 100 chars
  final String? effortEmoji;        // 💪😤🔥 etc (optional)
  final DateTime createdAt;
  final List<Reaction> reactions;

  // For display
  final User? user;                 // Populated on fetch
}
```

### Reaction

```dart
class Reaction extends Equatable {
  final String id;
  final String userId;
  final String checkInId;
  final String emoji;               // Single emoji
  final DateTime createdAt;
}
```

### Streak (Computed/Cached)

```dart
class Streak extends Equatable {
  final int currentCount;
  final int longestCount;
  final DateTime? lastCheckInDate;
  final List<DateTime> checkInDates; // For calendar view

  // Weekly/monthly stats
  final int daysThisWeek;
  final int daysThisMonth;
}
```

---

## Firebase Structure

### Firestore Collections

```
/users/{userId}
  - email: string
  - displayName: string
  - photoUrl: string?
  - currentStreak: number
  - longestStreak: number
  - lastCheckInDate: timestamp?
  - groupIds: array<string>
  - createdAt: timestamp
  - fcmToken: string?              # For push notifications

/groups/{groupId}
  - name: string
  - emoji: string?
  - inviteCode: string             # Indexed for lookups
  - creatorId: string
  - memberIds: array<string>
  - groupStreak: number
  - longestGroupStreak: number
  - createdAt: timestamp

/groups/{groupId}/checkIns/{checkInId}
  - userId: string
  - photoUrl: string
  - caption: string?
  - effortEmoji: string?
  - createdAt: timestamp

/groups/{groupId}/checkIns/{checkInId}/reactions/{reactionId}
  - userId: string
  - emoji: string
  - createdAt: timestamp

/users/{userId}/checkInHistory/{date}    # Daily rollup for calendar
  - groupId: string
  - checkInId: string
  - createdAt: timestamp
```

### Firebase Storage Structure

```
/users/{userId}/profile.jpg           # Profile photo
/groups/{groupId}/checkIns/{checkInId}.jpg  # Check-in photos
```

### Security Rules (Summary)

- Users can only read/write their own user doc
- Users can read groups they're members of
- Users can only create check-ins in groups they belong to
- Users can add reactions to any check-in in their groups
- Invite codes are readable by anyone (for joining)

---

## Features & Screens

### Phase 1: Core MVP

| Screen | Description | BLoC/Cubit |
|--------|-------------|------------|
| **Login** | Email/password + Google Sign-In | `AuthBloc` |
| **Sign Up** | Create account with display name | `AuthBloc` |
| **Home Feed** | List of today's check-ins from all groups | `FeedBloc` |
| **Check-In** | Camera → photo → optional caption → post | `CheckInCubit` |
| **Groups List** | List of user's groups with streak counts | `GroupsBloc` |
| **Group Detail** | Members, group streak, recent check-ins | `GroupDetailBloc` |
| **Create Group** | Name, emoji, generates invite code | `GroupsBloc` |
| **Join Group** | Enter invite code | `GroupsBloc` |
| **Profile** | User info, personal stats, settings | `ProfileCubit` |

### Phase 2: Engagement

| Screen | Description | BLoC/Cubit |
|--------|-------------|------------|
| **Streak Detail** | Calendar view, weekly/monthly stats | `StreakBloc` |
| **Reactions** | Emoji reactions on check-ins | `CheckInCubit` |
| **Notifications Settings** | Reminder times, group alerts | `NotificationCubit` |

### Phase 3: Polish

| Feature | Description |
|---------|-------------|
| **iOS Widget** | Shows friends' latest check-ins + streak |
| **Push Notifications** | Daily reminders, streak danger alerts |
| **Onboarding** | First-time user flow |
| **Weekly Summary** | Auto-generated progress recap |

### Phase 4: Premium (Optional)

| Feature | Description |
|---------|-------------|
| Advanced Stats | Detailed analytics and trends |
| Unlimited Groups | Free tier: 3 groups max |
| Custom Streak Themes | Visual customization |
| Export Reports | PDF/CSV progress reports |

---

## Implementation Phases

### Phase 1: Foundation (Week 1-2)

**Goal:** Basic auth, data models, and infrastructure

- [ ] Set up Firebase project (Auth, Firestore, Storage)
- [ ] Implement domain models (`User`, `Group`, `CheckIn`)
- [ ] Create `AuthenticationRepository`
- [ ] Create `UserRepository`
- [ ] Create `GroupRepository`
- [ ] Implement `AuthBloc` with login/signup
- [ ] Build Login and Signup screens
- [ ] Configure GoRouter with auth guards

**Deliverable:** User can sign up, log in, and see empty home screen

### Phase 2: Groups (Week 2-3)

**Goal:** Users can create and join groups

- [ ] Implement invite code generation
- [ ] Create group screens (list, detail, create, join)
- [ ] Implement `GroupsBloc` and `GroupDetailBloc`
- [ ] Add member management
- [ ] Firestore security rules for groups

**Deliverable:** User can create group, share code, friends can join

### Phase 3: Check-Ins (Week 3-4)

**Goal:** Core check-in flow works

- [ ] Create `CheckInRepository`
- [ ] Create `StorageService` for photo uploads
- [ ] Build camera/photo picker screen
- [ ] Implement `CheckInCubit`
- [ ] Build home feed with real-time updates
- [ ] Display check-ins in group detail

**Deliverable:** User can post daily check-in, see friends' check-ins

### Phase 4: Streaks (Week 4-5)

**Goal:** Streak system fully functional

- [ ] Create `StreakRepository` with calculation logic
- [ ] Implement streak reset logic (Cloud Function or client-side)
- [ ] Build streak UI components (`StreakBadge`, calendar)
- [ ] Add group streak calculations
- [ ] Weekly/monthly stats display

**Deliverable:** Personal and group streaks track correctly

### Phase 5: Social & Engagement (Week 5-6)

**Goal:** Reactions and notifications

- [ ] Implement emoji reactions
- [ ] Set up Firebase Cloud Messaging
- [ ] Create `NotificationService`
- [ ] Daily reminder notifications
- [ ] "Streak in danger" group alerts
- [ ] Notification preferences screen

**Deliverable:** Full social experience with push notifications

### Phase 6: Widget & Polish (Week 6-7)

**Goal:** iOS widget and UX polish

- [ ] Implement iOS WidgetKit extension
- [ ] Create `WidgetService` for data sharing
- [ ] Onboarding flow for new users
- [ ] Empty states and loading states
- [ ] Error handling and edge cases
- [ ] Performance optimization

**Deliverable:** Production-ready MVP

---

## Technical Considerations

### Streak Calculation Logic

```dart
/// Calculate if streak should continue or reset
bool shouldContinueStreak(DateTime? lastCheckIn, DateTime now) {
  if (lastCheckIn == null) return false;

  final lastDate = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  // Streak continues if last check-in was today or yesterday
  return lastDate == today || lastDate == yesterday;
}

/// Determine if user has already checked in today
bool hasCheckedInToday(DateTime? lastCheckIn, DateTime now) {
  if (lastCheckIn == null) return false;

  final lastDate = DateTime(lastCheckIn.year, lastCheckIn.month, lastCheckIn.day);
  final today = DateTime(now.year, now.month, now.day);

  return lastDate == today;
}
```

### Group Streak Logic

Group streak only continues if **all members** check in daily. Options:

1. **Client-side calculation** - Check all members' `lastCheckInDate`
2. **Cloud Function** - Scheduled function at midnight to evaluate and reset
3. **Hybrid** - Client calculates for display, function handles resets

**Recommendation:** Use Cloud Function for authoritative streak resets to handle timezone edge cases.

### Photo Handling

- Compress images client-side before upload (max 1080px, 80% quality)
- Generate thumbnail for feed (400px)
- Use `cached_network_image` for efficient loading
- Consider CDN/image optimization service for scale

### Real-Time Updates

```dart
// Feed bloc subscribes to check-ins across all user's groups
Stream<List<CheckIn>> watchTodaysFeed(List<String> groupIds) {
  return Rx.combineLatestList(
    groupIds.map((groupId) =>
      _firestore
        .collection('groups/$groupId/checkIns')
        .where('createdAt', isGreaterThan: _todayStart)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(CheckIn.fromFirestore).toList())
    ),
  ).map((lists) => lists.expand((x) => x).toList()..sort(...));
}
```

### Timezone Handling

- Store all timestamps in UTC
- Calculate "today" based on user's local timezone
- Cloud Functions should process streaks per-user timezone
- Consider allowing users to set their "day reset time"

### Widget Implementation (iOS)

- Use `home_widget` package for Flutter ↔ Widget communication
- Store widget data in App Groups shared container
- Update widget on each check-in and app launch
- Background refresh for friends' check-ins

### Offline Support

- Cache recent check-ins locally
- Queue check-ins if offline, sync when connected
- Show cached data while fetching fresh
- Use Firestore offline persistence

---

## Dependencies

```yaml
dependencies:
  # State Management
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5

  # Firebase
  firebase_core: ^2.24.2
  firebase_auth: ^4.16.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0
  firebase_messaging: ^14.7.10

  # Routing
  go_router: ^13.0.0

  # Image Handling
  image_picker: ^1.0.7
  image_cropper: ^5.0.1
  flutter_image_compress: ^2.1.0
  cached_network_image: ^3.3.1

  # UI
  flutter_animate: ^4.3.0
  shimmer: ^3.0.0

  # Utilities
  intl: ^0.18.1
  rxdart: ^0.27.7
  uuid: ^4.2.2

  # Code Generation
  json_annotation: ^4.8.1
  freezed_annotation: ^2.4.1

  # Widget (iOS)
  home_widget: ^0.4.1

dev_dependencies:
  build_runner: ^2.4.8
  json_serializable: ^6.7.1
  freezed: ^2.4.6
  bloc_test: ^9.1.5
  mocktail: ^1.0.3
```

---

## Open Questions

1. **Day boundary** - What time does a "day" reset? Midnight local time? User-configurable?
2. **Streak grace period** - Should there be any forgiveness (e.g., one "skip" per month)?
3. **Group streak fairness** - If one person always misses, should they affect group streak?
4. **Check-in validation** - Any verification that photo is actually from a workout?
5. **Multiple check-ins** - Allow multiple per day or strictly once?
6. **Photo requirements** - Must include face? Any content moderation?

---

## Success Metrics

- Daily Active Users (DAU)
- Check-in completion rate
- Average streak length
- Group retention (members staying active)
- D7/D30 retention
- Notifications → Check-in conversion

---

*Document created: 2026-02-12*
*Last updated: 2026-02-12*
