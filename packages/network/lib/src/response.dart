import 'package:network/network.dart';

/// {@template response}
/// An HTTP response where the entire response body is known in advance.
/// {@endtemplate}
class Response<Success, Failure extends Exception> {
  //#region Initializers

  /// {@macro response}
  Response({
    required this.result,
    this.data,
    this.response,
  });

  //#endregion

  /// The data returned by the server.
  final List<int>? data;

  /// Returns the associated error value if the result if it is a failure,
  /// `null` otherwise.
  Failure? get error => result.failure;

  /// The server's response to the URL request.
  final HTTPResponse? response;

  /// The result of response serialization.
  final Result<Success, Failure> result;

  /// Returns the associated value of the result if it is a success,
  /// `null` otherwise.
  Success? get value => result.success;

  //#region Instance methods

  /// Returns a new result, mapping any failure value using the given
  /// transformation.
  Response<Success, E> mapError<E extends Exception>(
    E Function(Failure) transform,
  ) {
    return Response(
      data: data,
      response: response,
      result: result.mapError(transform),
    );
  }

  /// Evaluates the specified closure when the result of this [Response] is
  /// a success, passing the unwrapped
  Response<S, Failure> mapSuccess<S>(S Function(Success) transform) {
    return Response(
      data: data,
      response: response,
      result: result.mapSuccess(transform),
    );
  }

  //#endregion
}
