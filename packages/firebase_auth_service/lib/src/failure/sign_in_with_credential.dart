/// {@template sign_in_with_google_failure}
/// Thrown during the sign in with google process if a failure occurs.
/// https://firebase.google.com/docs/reference/js/v8/firebase.auth.Auth#signinwithcredential
/// {@endtemplate}
class SignInWithCredentialFailure implements Exception {
  /// {@macro sign_in_with_google_failure}
  const SignInWithCredentialFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory SignInWithCredentialFailure.fromCode(String code) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const SignInWithCredentialFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const SignInWithCredentialFailure(
          'The credential received is malformed or has expired.',
        );
      case 'operation-not-allowed':
        return const SignInWithCredentialFailure(
          'Operation is not allowed.  Please contact support.',
        );
      case 'user-disabled':
        return const SignInWithCredentialFailure(
          'This user has been disabled. Please contact support for help.',
        );
      case 'user-not-found':
        return const SignInWithCredentialFailure(
          'Email is not found, please create an account.',
        );
      case 'wrong-password':
        return const SignInWithCredentialFailure(
          'Incorrect password, please try again.',
        );
      case 'invalid-verification-code':
        return const SignInWithCredentialFailure(
          'The credential verification code received is invalid.',
        );
      case 'invalid-verification-id':
        return const SignInWithCredentialFailure(
          'The credential verification ID received is invalid.',
        );
      default:
        return const SignInWithCredentialFailure();
    }
  }

  /// The associated error message.
  final String message;
}
