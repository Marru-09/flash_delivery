part of 'request.dart';

extension _RequestValidations on Request {
  //#region Private methods

  Result<void, ConnectionError> _validateStatusCodes({
    required List<int> acceptableStatusCodes,
    required HTTPResponse response,
  }) {
    if (acceptableStatusCodes.contains(response.statusCode)) {
      return Result.success(null);
    }

    return Result.failure(
      ResponseValidationUnacceptableStatusCode(response.statusCode),
    );
  }

  //#endregion
}

/// Extension on [DataRequest] for performing validations.
///
/// This extension provides additional methods for validating [DataRequest]
/// objects. It can be used to ensure that the request data meets certain
/// after receiving the server response.
extension DataRequestValidation on DataRequest {
  //#region Instance methods

  /// Validates that the response has a status code in the specified sequence.
  void validateAcceptableStatusCodes(List<int> acceptableStatusCodes) {
    return customValidation((response, data) {
      return _validateStatusCodes(
        acceptableStatusCodes: acceptableStatusCodes,
        response: response,
      );
    });
  }

  //#endregion
}
