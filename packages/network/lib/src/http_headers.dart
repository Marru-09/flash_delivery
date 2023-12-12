import 'dart:io';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

/// {@template http_header}
/// A representation of a single HTTP header's name / value pair.
/// {@endtemplate}
class HTTPHeader extends Equatable {
  //region Initializers

  /// {@macro http_header}
  const HTTPHeader({required this.name, required this.value});

  /// Returns the Accept [HTTPHeader].
  factory HTTPHeader.accept(String value) {
    return HTTPHeader(name: 'Accept', value: value);
  }

  /// Returns the Accept-Language [HTTPHeader].
  factory HTTPHeader.acceptLanguage(String value) {
    return HTTPHeader(name: 'Accept-Language', value: value);
  }

  /// Returns the Authorization [HTTPHeader].
  factory HTTPHeader.authorization(String value) {
    return HTTPHeader(name: 'Authorization', value: value);
  }

  /// Returns the Bearer Authorization [HTTPHeader]
  /// using the provided bearerToken.
  factory HTTPHeader.bearerToken(String value) {
    return HTTPHeader(name: 'Authorization', value: 'Bearer $value');
  }

  /// Returns the Content-Disposition [HTTPHeader].
  factory HTTPHeader.contentDisposition(String value) {
    return HTTPHeader(name: 'Content-Disposition', value: value);
  }

  /// Returns the Content-Length [HTTPHeader].
  factory HTTPHeader.contentLength(int value) {
    return HTTPHeader(name: 'Content-Length', value: '$value');
  }

  /// Returns the Content-Type [HTTPHeader].
  factory HTTPHeader.contentType(String value) {
    return HTTPHeader(name: 'Content-Type', value: value);
  }

  /// Returns the default `Accept-Language` header.
  factory HTTPHeader.defaultAcceptLanguage() {
    const kIsWeb = bool.fromEnvironment('dart.library.js_util');

    if (kIsWeb) {
      return HTTPHeader.acceptLanguage('');
    }

    return HTTPHeader.acceptLanguage('${Platform.localeName};q=1');
  }

  //#endregion

  /// The name of the header.
  final String name;

  /// The value of the header.
  final String value;

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [
        name,
        value,
      ];
}

/// {@template http_headers}
/// An order-preserving and case-insensitive representation of HTTP headers.
/// {@endtemplate}
class HTTPHeaders extends Equatable {
  //#region Initializers

  /// {@macro http_headers}
  HTTPHeaders({List<HTTPHeader> array = const []}) {
    for (final header in array) {
      _insertOrReplace(header);
    }
  }

  /// {@macro http_headers}
  HTTPHeaders.fromDictionary(Map<String, String> dictionary) {
    dictionary.entries
        .map((e) => HTTPHeader(name: e.key, value: e.value))
        .forEach(_insertOrReplace);
  }

  /// The default [HTTPHeaders] used.
  factory HTTPHeaders.defaultHeaders() {
    return HTTPHeaders(array: [HTTPHeader.defaultAcceptLanguage()]);
  }

  //#endregion

  final List<HTTPHeader> _headers = [];

  /// Return the number of headers.
  int get length => _headers.length;

  /// The dictionary representation of all headers.
  Map<String, String> get dictionary {
    final headers = <String, String>{};

    for (final header in _headers) {
      if (!headers.containsKey(header.name)) {
        headers[header.name] = header.value;
      }
    }

    return headers;
  }

  /// The list of properties that will be used to determine whether
  /// two instances are equal.
  @override
  List<Object?> get props => [
        dictionary,
        length,
      ];

  //#region Instance methods

  /// Case-insensitively updates or appends the provided [HTTPHeader]
  /// into the instance.
  void append(HTTPHeader header) {
    _insertOrReplace(header);
  }

  /// Case-insensitively return the [HTTPHeader] value associated to
  /// the given key.
  String? headerForKey(String key) {
    return _headers
        .firstWhereOrNull((e) => e.name.toLowerCase() == key.toLowerCase())
        ?.value;
  }

  /// Case-insensitively removes an [HTTPHeader], if it exists,
  /// from the instance.
  void removeHeaderForKey(String key) {
    final index = _headers.indexWhere(
      (element) => element.name.toLowerCase() == key.toLowerCase(),
    );

    if (index >= 0) {
      _headers.removeAt(index);
    }
  }

  /// Case-insensitively updates or appends an [HTTPHeader] into the instance
  /// using the provided header and key.
  void setHeader({required String key, required String header}) {
    _insertOrReplace(HTTPHeader(name: key, value: header));
  }

  //#endregion

  //#region Operators

  /// Case-insensitively updates or appends the provided [HTTPHeader].
  HTTPHeaders operator +(HTTPHeaders rhs) {
    final headers = {...dictionary, ...rhs.dictionary};
    return HTTPHeaders.fromDictionary(headers);
  }

  //#endregion

  //#region: Private methods

  void _insertOrReplace(HTTPHeader header) {
    final index = _headers.indexWhere(
      (element) => element.name.toLowerCase() == header.name.toLowerCase(),
    );

    if (index >= 0) {
      _headers.replaceRange(index, index + 1, [header]);
    } else {
      _headers.add(header);
    }
  }

  //#endregion
}
