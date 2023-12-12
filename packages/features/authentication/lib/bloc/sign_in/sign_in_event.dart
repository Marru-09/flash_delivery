part of 'sign_in_bloc.dart';

abstract class SignInEvent extends Equatable {
  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [];

  //#region Initializers

  /// {@macro sign_in_event}
  const SignInEvent();

  //#endregion
}

/// {@template sign_in_email_changed_event}
/// Subclass of [SignInEvent]
///
/// This event is emmited when an username is entered.
/// {@endtemplate}
class SignInEmailChangedEvent extends SignInEvent {
  /// The entered email by the user.
  final String email;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [email];

  //#region Initializers

  /// {@macro sign_in_email_changed_event}
  const SignInEmailChangedEvent(this.email);

  //#endregion
}

/// {@template sign_in_password_changed_event}
/// Subclass of [SignInEvent]
///
/// This event is emmited when the password is entered.
/// {@endtemplate}
class SignInPasswordChangedEvent extends SignInEvent {
  /// The entered password by the user.
  final String password;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [password];

  //#region Initializers

  /// {@macro sign_in_password_changed_event}
  const SignInPasswordChangedEvent(this.password);

  //#endregion
}

/// {@template sign_in_submitted_event}
/// Subclass of [SignInEvent]
///
/// This event is emitted when the email has already
/// been obtained and it is the password in order
/// to call cognito and perform the signin
/// {@endtemplate}
class SignInSubmittedEvent extends SignInEvent {}
