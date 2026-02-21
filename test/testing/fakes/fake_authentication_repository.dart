import 'package:bod_squad/data/repositories/authentication_repository.dart';
import 'package:bod_squad/domain/models/user.dart';

/// A fake [AuthenticationRepository] for testing phone-only auth flows.
class FakeAuthenticationRepository implements AuthenticationRepository {
  bool shouldThrowOnPhoneCodeSend = false;
  bool shouldThrowOnPhoneCodeVerify = false;
  bool shouldThrowOnLogOut = false;
  Duration delay = Duration.zero;

  String? lastPhoneNumber;
  String? lastVerificationId;
  List<String> loginAttempts = [];

  int _verificationCounter = 0;

  @override
  Stream<User> get user => const Stream.empty();

  @override
  User get currentUser => User.empty;

  @override
  Future<void> logOut() async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    if (shouldThrowOnLogOut) throw const LogOutFailure();
  }

  @override
  Future<String> sendPhoneCode(String phoneNumber) async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    loginAttempts.add('phone-$phoneNumber');
    lastPhoneNumber = phoneNumber;

    if (shouldThrowOnPhoneCodeSend) {
      throw const PhoneAuthenticationFailure('Failed to send phone code.');
    }

    _verificationCounter++;
    lastVerificationId = 'fake-verification-id-$_verificationCounter';
    return lastVerificationId!;
  }

  @override
  Future<void> verifyPhoneCode({
    required String verificationId,
    required String smsCode,
  }) async {
    if (delay != Duration.zero) await Future<void>.delayed(delay);

    if (shouldThrowOnPhoneCodeVerify) {
      throw const VerifyPhoneCodeFailure('Invalid verification code.');
    }
  }
}
