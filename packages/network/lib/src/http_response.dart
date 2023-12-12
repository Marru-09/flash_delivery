import 'package:network/network.dart';

/// {@template http_response}
/// HTTP response for a client connection.
/// {@endtemplate}
class HTTPResponse {
  //#region Initializers

  /// {@macro http_response}
  HTTPResponse({
    required this.contentLength,
    required this.headers,
    required this.reasonPhrase,
    required this.statusCode,
    required this.url,
  });

  //#endregion

  /// Returns the content length of the response body. Returns -1 if the size of
  /// the response body is not known in advance.
  ///
  /// If the content length needs to be set, it must be set before the
  /// body is written to. Setting the content length after writing to the body
  /// will throw a `StateError`.
  final int contentLength;

  /// Returns the client response headers.
  ///
  /// The client response headers are immutable.
  final HTTPHeaders headers;

  /// Returns the reason phrase associated with the status code.
  ///
  /// The reason phrase must be set before the body is written
  /// to. Setting the reason phrase after writing to the body will throw
  /// a `StateError`.
  final String? reasonPhrase;

  /// Returns the status code.
  ///
  /// The status code must be set before the body is written
  /// to. Setting the status code after writing to the body will throw
  /// a `StateError`.
  final int statusCode;

  /// Return the final real request uri (maybe redirect).
  final Uri url;
}
