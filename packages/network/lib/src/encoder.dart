import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:network/network.dart';

/// The enum [Destination] represents the possible destinations for
/// the parameters in the network requests.
enum Destination {
  /// Sets encoded query string result as the HTTP body of the URL request.
  httpBody,

  /// Applies encoded query string result to existing query string for
  /// GET, and DELETE requests and sets as the
  /// HTTP body for requests with any other HTTP method.
  methodDependent,

  /// Sets or appends encoded query string result to existing query string.
  queryString
}

/// Extension on [Destination] to provide additional functionality.
extension DestinationX on Destination {
  /// Returns whether the destination encodes parameters in the URL
  bool encodesParametersInURL(HTTPMethod method) {
    switch (this) {
      case Destination.methodDependent:
        return [HTTPMethod.delete.rawValue, HTTPMethod.get].contains(method);

      case Destination.queryString:
        return true;

      case Destination.httpBody:
        return false;
    }
  }
}

class _QueryComponent {
  //#region Initializers

  _QueryComponent({required this.key, required this.value});

  //#endregion

  /// The key of this component.
  final String key;

  /// The value of this component.
  final String value;
}

/// {@template encoder}
/// A type that can encode any [Map] type into a [HttpClientRequest].
/// {@endtemplate}
// ignore: one_member_abstracts
abstract class Encoder {
  /// Encodes a [HttpClientRequest] by encoding [parameters],
  /// applying them on the passed request.
  ///
  /// - Parameters:
  ///   - request: The [HttpClientRequest] to configure.
  ///   - parameters: The parameters to encode into the [HttpClientRequest].
  /// - Returns: A [Future] with the configured [HttpClientRequest].
  Future<void> encode(Request request, Map<String, dynamic>? parameters);
}

/// {@template json_parameter_encoder}
/// A class that implements the [Encoder] interface for encoding
/// parameters into JSON format.
///
/// This class is responsible for encoding parameters into JSON
/// format for network requests.
/// {@endtemplate}
class JSONParameterEncoder implements Encoder {
  /// The JSON encoder.
  final jsonEncoder = const JsonEncoder();

  //#region ParameterEncoding

  /// Encodes a [HttpClientRequest] by encoding parameters and headers, applying
  /// them on the passed request.
  ///
  /// - Parameters:
  ///   - request: The [HttpClientRequest] to configure.
  ///   - parameters: The parameters to encode into the [HttpClientRequest].
  /// - Returns: A [Future] with the configured [HttpClientRequest].
  @override
  Future<void> encode(Request request, Map<String, dynamic>? parameters) async {
    if (parameters == null || parameters.isEmpty) return;

    if (request is DataRequest) {
      try {
        final body = jsonEncoder.convert(parameters);
        final contentLength = utf8.encode(body).length;
        final headers = request.headers ?? HTTPHeaders();

        request
          ..body = body
          ..contentLength = contentLength;

        if (headers.headerForKey('Content-Length') == null) {
          headers.append(HTTPHeader.contentLength(contentLength));
        }

        if (headers.headerForKey('Content-Type') == null) {
          headers.append(
            HTTPHeader.contentType('application/json; charset=utf-8'),
          );
        }
        request.headers = headers;
      } catch (error) {
        rethrow;
      }
    }
  }

  //#endregion
}

/// {@template url_parameter_encoder}
/// A class that implements the [Encoder] interface for encoding URL parameters.
///
/// This class provides functionality to encode URL parameters.
/// {@endtemplate}
class URLParameterEncoder implements Encoder {
  //#region Initializers

  /// {@macro url_parameter_encoder}
  URLParameterEncoder({this.destination = Destination.methodDependent});

  //#endregion

  /// The parameters destination
  final Destination destination;

  //#region ParameterEncoding

  /// Encodes a [HttpClientRequest] by encoding parameters and headers, applying
  /// them on the passed request.
  ///
  /// - Parameters:
  ///   - request: The [HttpClientRequest] to configure.
  ///   - parameters: The parameters to encode into the [HttpClientRequest].
  /// - Returns: A [Future] with the configured [HttpClientRequest].
  @override
  Future<void> encode(Request request, Map<String, dynamic>? parameters) async {
    if (parameters != null && parameters.isNotEmpty) {
      if (destination.encodesParametersInURL(request.method)) {
        final pairs = <List<dynamic>>[];

        parameters.forEach(
          (key, value) => pairs.add(
            [
              Uri.encodeQueryComponent(key),
              if (value is String) Uri.encodeQueryComponent(value) else value,
            ],
          ),
        );

        request.encodedQuery = request.url.query +
            pairs.map((pair) => '${pair[0]}=${pair[1]}').join('&');
      } else if (request is DataRequest) {
        final sortedKeys = parameters.keys.toList(growable: false)..sort();
        final sortedParameters = LinkedHashMap<String, dynamic>.fromIterable(
          sortedKeys,
          key: (k) => k as String,
          value: (k) => parameters[k],
        );

        final query = <_QueryComponent>[];

        sortedParameters.forEach((key, value) {
          query.addAll(_queryComponents(key: key, value: value));
        });

        final body = query
            .map((component) => '${component.key}=${component.value}')
            .join('&');

        final contentLength = utf8.encode(body).length;
        final headers = request.headers ?? HTTPHeaders();

        request
          ..body = body
          ..contentLength = contentLength;

        if (headers.headerForKey('Content-Length') == null) {
          headers.append(HTTPHeader.contentLength(contentLength));
        }

        if (headers.headerForKey('Content-Type') == null) {
          headers.append(
            HTTPHeader.contentType(
              'application/x-www-form-urlencoded; charset=utf-8',
            ),
          );
        }
        request.headers = headers;
      }
    }
  }

  //#endregion

  //#region Private methods

  List<_QueryComponent> _queryComponents({
    required String key,
    required dynamic value,
  }) {
    final components = <_QueryComponent>[];

    if (value is Map<String, dynamic>) {
      value.forEach((key, value) {
        components.addAll(_queryComponents(key: key, value: value));
      });
    } else if (value is List) {
      for (final val in value) {
        components.addAll(_queryComponents(key: key, value: val));
      }
    } else {
      components.add(
        _QueryComponent(
          key: Uri.encodeQueryComponent(key),
          value: Uri.encodeQueryComponent(value as String),
        ),
      );
    }

    return components;
  }

  //#endregion
}
