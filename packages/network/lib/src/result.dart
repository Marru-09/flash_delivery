class Void {
  const Void();
}

/// {@template result}
/// A value that represents either a success or a failure, including
/// an associated value in each case.
/// {@endtemplate}
class Result<Success, Failure extends Exception> {
  //#region Initializers

  /// {@macro result}
  Result({this.success, this.failure});

  /// {@macro result}
  Result.failure(this.failure) : success = null;

  /// {@macro result}
  Result.success(this.success) : failure = null;

  //#endregion

  /// Represents the result of a operation.
  ///
  /// This class contains a [Failure] object, which represents a
  /// failure of the operation, or null if the operation was successful.
  final Failure? failure;

  /// Represents the result of a operation.
  ///
  /// This class contains a [Success] object, which represents a
  /// successful operation, or null if the operation was not successful.
  final Success? success;

  /// Whether the [Result] is a failure.
  bool get isFailure => failure != null;

  /// Whether the [Result] is a success.
  bool get isSuccess => success != null;

  //#region Instance mehtods

  /// Returns a new result, mapping any failure value using the given
  /// transformation.
  Result<Success, E> mapError<E extends Exception>(
    E Function(Failure) transform,
  ) {
    if (failure != null) {
      return Result(failure: transform(failure!));
    }

    return Result(success: success);
  }

  /// Evaluates the specified closure when the result of this [Result] is
  /// a success, passing the unwrapped
  Result<S, Failure> mapSuccess<S>(S Function(Success) transform) {
    if (success != null) {
      return Result(success: transform(success as Success));
    }

    return Result(failure: failure);
  }

  //#endregion
}
