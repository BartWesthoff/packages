import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:firebase_auth_repository/firebase_authentication_repository.dart';
import 'package:firebase_auth_repository/src/failure/sign_in_with_phone.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meta/meta.dart';

/// AuthenticationStatus kinds,
enum AuthenticationStatus {
  /// authenticated: user is authenticated (signged in)
  authenticated,

  /// [unauthenticated]: user is not authenticated (not signged in)
  unauthenticated,

  /// [unknown]: status is not known
  unknown,
}

/// {@template authentication_repository}
/// Repository which manages user authentication.
/// {@endtemplate}
class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository();

  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.standard();
  final _controller = StreamController<AuthenticationStatus>();

  /// Whether or not the current environment is web
  /// Should only be overriden for testing purposes. Otherwise,
  /// defaults to [kIsWeb]
  @visibleForTesting
  bool isWeb = kIsWeb;

  /// Stream of [AppUser] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [AppUser.empty] if the user is not authenticated.
  Stream<AppUser> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? AppUser.empty : firebaseUser.toUser;
      return user;
    });
  }

  /// Stream of [AuthenticationStatus] which yields the current
  /// status
  Stream<AuthenticationStatus> get status async* {
    yield* _controller.stream;
  }

  /// disposes streamcontroller holder auth status
  void dispose() => _controller.close();

  /// Returns the current cached user.
  /// Defaults to [AppUser.empty] if there is no cached user.
  AppUser get currentUser {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      return AppUser.empty;
    } else {
      return user.toUser;
    }
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signUp({required String email, required String password}) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [SignInWithGoogleFailure] if an exception occurs.
  Future<void> signInWithGoogle() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (isWeb) {
        final googleProvider = firebase_auth.GoogleAuthProvider();
        final userCredential = await _firebaseAuth.signInWithPopup(
          googleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final googleUser = await _googleSignIn.signIn();
        final googleAuth = await googleUser!.authentication;
        credential = firebase_auth.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
      }

      await _firebaseAuth.signInWithCredential(credential);
      _controller.add(AuthenticationStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      throw SignInWithGoogleFailure.fromCode(e.code);
    } catch (_) {
      throw const SignInWithGoogleFailure();
    }
  }

  /// Signs in with the provided [phoneNumber].
  ///
  /// Throws a [SignInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signInWithPhoneNumber({
    required String phoneNumber,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _firebaseAuth.signInWithCredential(credential);
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        codeSent: (String verificationId, int? forceResendingToken) {},
        verificationFailed: (FirebaseAuthException error) {
          throw SignInWithEmailAndPasswordFailure.fromCode(error.code);
        },
      );
      _controller.add(AuthenticationStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      throw SignInWithPhoneNumberFailure.fromCode(e.code);
    } catch (_) {
      throw const SignInWithPhoneNumberFailure();
    }
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [SignInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _controller.add(AuthenticationStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      throw SignInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignInWithEmailAndPasswordFailure();
    }
  }

  /// Signs in with the provided [credential].
  ///
  /// Throws a [SignInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> signInWithCredential({
    required AuthCredential credential,
  }) async {
    try {
      await _firebaseAuth.signInWithCredential(credential);
      _controller.add(AuthenticationStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      throw SignInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignInWithEmailAndPasswordFailure();
    }
  }

  ///

  Future<void> signInAnonymously() async {
    try {
      await _firebaseAuth.signInAnonymously();
      _controller.add(AuthenticationStatus.authenticated);
    } on FirebaseAuthException catch (e) {
      throw SignInWithEmailAndPasswordFailure.fromCode(e.code);
    } catch (_) {
      throw const SignInWithEmailAndPasswordFailure();
    }
  }

  /// Signs out the current user which will emit
  /// [AppUser.empty] from the [user] Stream.
  ///
  /// Throws a [SignOutFailure] if an exception occurs.
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
      _controller.add(AuthenticationStatus.unauthenticated);
    } catch (_) {
      throw SignOutFailure();
    }
  }
}

extension on firebase_auth.User {
  AppUser get toUser {
    return AppUser(id: uid, email: email, name: displayName, photo: photoURL);
  }
}
