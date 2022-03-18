/// {@template log_in_anonymously_failure}
/// Thrown during the sign in anonymously process if a failure occurs.
/// https://firebase.google.com/docs/reference/js/v8/firebase.auth.Auth#signinanonymously
/// {@endtemplate}
class LogInAnonymouslyFailure implements Exception {
  /// {@macro log_in_anonymously_failure}
  const LogInAnonymouslyFailure([
    this.message = 'An unknown exception occurred.',
  ]);

  /// Create an authentication message
  /// from a firebase authentication exception code.
  factory LogInAnonymouslyFailure.fromCode(String code) {
    switch (code) {
      case 'operation-not-allowed':
        return const LogInAnonymouslyFailure(
          'Operation is not allowed.  Please contact support.',
        );
      default:
        return const LogInAnonymouslyFailure();
    }
  }

  /// The associated error message.
  final String message;
}
