import '../../lib/data/repositories/authentication_repository.dart';
import '../../lib/domain/models/user.dart';
import '../fixtures/user_fixtures.dart';

/// Fake implementation of [AuthenticationRepository] for testing.
///
/// This repository simulates authentication flows without requiring Firebase
/// and is useful for integration tests and testing dependent components.
class FakeAuthenticationRepository extends AuthenticationRepository {
  /// Creates a [FakeAuthenticationRepository].
  FakeAuthenticationRepository({
    User? initialUser,
    this.shouldThrowOnLogIn = false,
    this.shouldThrowOnLogOut = false,
    this.shouldThrowOnPhoneCodeSend = false,
    this.shouldThrowOnPhoneCodeVerify = false,
    this.shouldThrowOnSignUp = false,
    this.delay = Duration.zero,
  }) : _currentUser = initialUser ?? User.empty;

  User _currentUser;
  final List<User> _userHistory = [];

  /// Whether to throw an exception on login attempts.
  bool shouldThrowOnLogIn;

  /// Whether to throw an exception on logout attempts.
  bool shouldThrowOnLogOut;

  /// Whether to throw an exception on phone code send attempts.
  bool shouldThrowOnPhoneCodeSend;

  /// Whether to throw an exception on phone code verify attempts.
  bool shouldThrowOnPhoneCodeVerify;

  /// Whether to throw an exception on sign up attempts.
  bool shouldThrowOnSignUp;

  /// Artificial delay for testing async operations.
  Duration delay;

  /// Verification ID returned by [sendPhoneCode].
  String? lastVerificationId;

  /// Phone number for last [sendPhoneCode] call.
  String? lastPhoneNumber;

  /// Records of all login attempts.
  List<String> loginAttempts = [];

  /// Records of all logout attempts.
  int logoutAttempts = 0;

  @override
  Stream<User> get user => Stream.fromIterable([_currentUser]);

  @override
  User get currentUser => _currentUser;

  /// Sets the current user directly.
  ///
  /// Useful for testing state transitions.
  void setCurrentUser(User user) {
    _currentUser = user;
    _userHistory.add(user);
  }

  /// Resets to empty user.
  void reset() {
    _currentUser = User.empty;
    _userHistory.clear();
    loginAttempts.clear();
    logoutAttempts = 0;
    lastVerificationId = null;
    lastPhoneNumber = null;
  }

  @override
  Future<void> logInWithGoogle() async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnLogIn) {
      throw const LogInWithGoogleFailure('Simulated Google login failure.');
    }

    loginAttempts.add('google');
    setCurrentUser(UserFixtures.googleUser);
  }

  @override
  Future<void> logInWithApple() async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnLogIn) {
      throw const LogInWithAppleFailure('Simulated Apple login failure.');
    }

    loginAttempts.add('apple');
    setCurrentUser(UserFixtures.appleUser);
  }

  @override
  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnLogIn) {
      throw const LogInWithEmailAndPasswordFailure('Simulated email login failure.');
    }

    loginAttempts.add(email);

    final user = User(
      id: 'user-email-$email',
      email: email,
      firstName: null,
      lastName: null,
      photoUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setCurrentUser(user);
  }

  @override
  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnSignUp) {
      throw const SignUpWithEmailAndPasswordFailure('Simulated email signup failure.');
    }

    loginAttempts.add('signup-$email');

    final user = User(
      id: 'user-signup-$email',
      email: email,
      firstName: null,
      lastName: null,
      photoUrl: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    setCurrentUser(user);
  }

  @override
  Future<void> logOut() async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnLogOut) {
      throw const LogOutFailure('Simulated logout failure.');
    }

    logoutAttempts++;
    setCurrentUser(User.empty);
  }

  @override
  Future<String> sendPhoneCode(String phoneNumber) async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnPhoneCodeSend) {
      throw const PhoneAuthenticationFailure('Simulated phone code send failure.');
    }

    lastVerificationId = 'verification-id-${DateTime.now().millisecondsSinceEpoch}';
    lastPhoneNumber = phoneNumber;
    loginAttempts.add('phone-$phoneNumber');

    return lastVerificationId!;
  }

  @override
  Future<void> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (delay.inMilliseconds > 0) {
      await Future.delayed(delay);
    }

    if (shouldThrowOnPhoneCodeVerify) {
      throw const VerifyPhoneCodeFailure('Simulated phone code verify failure.');
    }

    setCurrentUser(UserFixtures.phoneUser);
  }
}
