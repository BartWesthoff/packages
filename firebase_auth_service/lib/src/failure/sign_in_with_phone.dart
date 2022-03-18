/// {@template log_in_with_phone_number_failure}
/// Thrown during the login process if a failure occurs.
/// https://firebase.google.com/docs/reference/js/v8/firebase.auth.Auth#signinwithphonenumber
/// {@endtemplate}
class SignInWithPhoneNumberFailure implements Exception {
  /// {@macro log_in_with_email_and_password_failure}
  const SignInWithPhoneNumberFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory SignInWithPhoneNumberFailure.fromCode(String code) {
    switch (code) {
      case 'captcha-check-failed':
        return const SignInWithPhoneNumberFailure(
          'Captcha check failed. Please try again.',
        );
      case 'user-disabled':
        return const SignInWithPhoneNumberFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'missing-phone-number':
        return const SignInWithPhoneNumberFailure(
          'Phone number not found, please add phone number.',
        );
      case 'invalid-phone-number':
        return const SignInWithPhoneNumberFailure(
          'Invalid phone number, please enter new phone number',
        );
      case 'quota-exceeded':
        return const SignInWithPhoneNumberFailure(
          'Quota exceeded, please contact support.',
        );
      case 'operation-not-allowed':
        return const SignInWithPhoneNumberFailure(
          'Operation is not allowed.  Please contact support.',
        );

      default:
        return const SignInWithPhoneNumberFailure();
    }
  }

  /// The associated error message.
  final String message;
}
