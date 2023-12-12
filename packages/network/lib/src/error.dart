/// Enum representing the reasons for serialization failure.
enum SerializationFailureReason {
  /// A custom response serializer failed due to the associated `Error`.
  customSerializationFailed,

  /// The server response contained no data or the data was empty.
  inputDataNilOrEmpty,

  /// Generic serialization failed for an empty response that wasn't type
  /// `Empty` but instead the associated type.
  invalidEmptyResponse,

  /// JSON serialization failed with an underlying system error during
  /// the encoding process.
  jsonSerializationFailed
}

/// {@template connection_error}
/// Represents an error that occurs during a connection.
/// {@endtemplate}
class ConnectionError implements Exception {
  //#region Instance methods

  /// {@macro connection_error}
  const ConnectionError({this.error});

  //#endregion

  /// The underliying error.
  final Object? error;

  //#region Overriden methods

  @override
  String toString() => error.toString();

  //#endregion
}

/// {@template create_url_request_failed}
/// Subclass of [ConnectionError]
///
/// Request threw an error in createURLRequest().
/// {@endtemplate}
class CreateURLRequestFailed extends ConnectionError {
  //#region Instance methods

  /// {@macro create_url_request_failed}
  const CreateURLRequestFailed({super.error});

  //#endregion
}

/// {@template custom_response_validation_failed}
/// Subclass of [ConnectionError]
///
/// Custom response validation failed due to the associated [Exception].
/// {@endtemplate}
class CustomResponseValidationFailed extends ConnectionError {
  //#region Instance methods

  /// {@macro custom_response_validation_failed}
  const CustomResponseValidationFailed({super.error});

  //#endregion
}

/// {@template request_cancelled}
/// Subclass of [ConnectionError]
///
/// Request has been explicitly cancelled.
/// {@endtemplate}
class RequestCancelled extends ConnectionError {
  //#region Instance methods

  /// {@macro request_cancelled}
  const RequestCancelled() : super(error: 'Expliticly cancelled request');

  //#endregion
}

/// {@template request_failed}
/// Subclass of [ConnectionError]
///
/// Request has failed in the execution.
/// {@endtemplate}
class RequestFailed extends ConnectionError {
  //#region Instance methods

  /// {@macro request_failed}
  const RequestFailed({super.error});

  //#endregion
}

/// {@template request_retry_failed}
/// Subclass of [ConnectionError]
///
/// Request has failed in the retry.
/// {@endtemplate}
class RequestRetryFailed extends ConnectionError {
  //#region Instance methods

  /// {@macro request_retry_failed}
  const RequestRetryFailed({super.error});

  //#endregion
}

/// {@template response_validation_unacceptable_status_code}
/// Subclass of [ConnectionError]
///
/// Status code validation failed.
/// {@endtemplate}
class ResponseValidationUnacceptableStatusCode extends ConnectionError {
  //#region Instance methods

  /// {@macro response_validation_unacceptable_status_code}
  const ResponseValidationUnacceptableStatusCode(
    this.statusCode,
  ) : super(error: 'Unacceptable status code: $statusCode');

  //#endregion

  /// The unnaccepted status code.
  final int statusCode;
}

/// {@template serialization_failed}
/// Subclass of [ConnectionError]
///
/// Response serialization failed.
/// {@endtemplate}
class SerializationFailed extends ConnectionError {
  //#region Instance methods

  /// {@macro serialization_failed}
  const SerializationFailed(this.reason, {super.error});

  //#endregion

  /// The serializon reason.
  final SerializationFailureReason reason;
}
