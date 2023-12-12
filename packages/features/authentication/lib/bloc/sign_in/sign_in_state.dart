part of 'sign_in_bloc.dart';

/// {@template sign_in_state}
///
/// Represents the State of the [SignInBloc].
///
/// {@endtemplate}
class SignInState extends Equatable {
  /// The username entered by the user.
  final String email;

  /// The reason of the failure.
  final String? errorReason;

  /// The password entered by the user.
  final String password;

  /// Current input status for the form.
  final DataLoadStatus status;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [
        email,
        errorReason,
        password,
        status,
      ];

  //#region Initializers

  /// {@macro sign_in_state}
  const SignInState({
    required this.email,
    required this.errorReason,
    required this.password,
    required this.status,
  });

  /// {@macro sign_in_state}
  factory SignInState.initial() {
    return const SignInState(
      email: '',
      errorReason: '',
      password: '',
      status: DataLoadStatus.initial,
    );
  }

  //#endregion

  //#region Instance methods

  /// Creates a copy of this [SignInState] with the given fields replaced
  /// by the new values.
  SignInState copyWith({
    String? email,
    String? errorReason,
    String? password,
    DataLoadStatus? status,
  }) {
    return SignInState(
      email: email ?? this.email,
      errorReason: errorReason ?? this.errorReason,
      password: password ?? this.password,
      status: status ?? this.status,
    );
  }

  //#endregion
}
