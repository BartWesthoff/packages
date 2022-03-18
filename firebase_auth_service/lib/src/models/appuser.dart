import 'package:equatable/equatable.dart';

/// {@template AppUser}
/// AppUser model
///
/// [AppUser.empty] represents an unauthenticated AppUser.
/// {@endtemplate}
class AppUser extends Equatable {
  /// {@macro AppUser}
  const AppUser({
    required this.id,
    this.email,
    this.name,
    this.photo,
  });

  /// The current AppUser's email address.
  final String? email;

  /// The current AppUser's id.
  final String id;

  /// The current AppUser's name (display name).
  final String? name;

  /// Url for the current AppUser's photo.
  final String? photo;

  /// Empty AppUser which represents an unauthenticated AppUser.
  static const empty = AppUser(id: '');

  /// Convenience getter to determine whether the current AppUser is empty.
  bool get isEmpty => this == AppUser.empty;

  /// Convenience getter to determine whether the current AppUser is not empty.
  bool get isNotEmpty => this != AppUser.empty;

  @override
  List<Object?> get props => [email, id, name, photo];
}
