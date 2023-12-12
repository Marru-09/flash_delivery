import 'dart:convert';

import 'package:network/network.dart';

/// {@template serializer}
/// The type to which all data response serializers must conform in
/// order to serialize a response.
/// {@endtemplate}
abstract class Serializer<ResponseObject> {
  //#region Instance methods

  /// Return the default list of empty codes.
  static List<int> get defaultEmptyCodes => [204, 205];

  /// Serializes the response [data] into the provided [ResponseObject]
  /// otherwise it will throw an error if the request has failed.
  ResponseObject serialize(
    List<int>? data,
    HTTPResponse? response,
    Exception? error,
  );

  //#endregion
}

/// {@macro serializer}
class DataResponseSerializer extends Serializer {
  //#region Initializers

  /// {@macro serializer}
  DataResponseSerializer({
    List<int>? emptyResponseCodes,
  }) : emptyResponseCodes = emptyResponseCodes ?? Serializer.defaultEmptyCodes;

  //#endregion

  /// HTTP status codes for which empty responses are always valid.
  /// `[204, 205]` by default.
  final List<int> emptyResponseCodes;

  //#region Serializer

  /// Returns the received [data] from the request
  /// otherwise it will throw an error if the request has failed.
  @override
  dynamic serialize(List<int>? data, HTTPResponse? response, Exception? error) {
    if (error != null) {
      throw error;
    }

    if (data != null && data.isNotEmpty) {
      return data;
    }

    if (emptyResponseCodes.contains(response?.statusCode ?? -1)) {
      return null;
    }

    throw const SerializationFailed(
      SerializationFailureReason.inputDataNilOrEmpty,
    );
  }

  //#endregion
}

/// {@macro serializer}
class StringResponseSerializer extends Serializer {
  //#region Initializers

  /// {@macro serializer}
  StringResponseSerializer({
    List<int>? emptyResponseCodes,
  }) : emptyResponseCodes = emptyResponseCodes ?? Serializer.defaultEmptyCodes;

  /// HTTP status codes for which empty responses are always valid.
  /// `[204, 205]` by default.
  final List<int> emptyResponseCodes;

  //#endregion

  //#region Serializer

  /// Serializes the response [data] into a String
  /// otherwise it will throw an error if the request has failed.
  @override
  dynamic serialize(List<int>? data, HTTPResponse? response, Exception? error) {
    if (error != null) {
      throw error;
    }

    if (data != null && data.isNotEmpty) {
      return utf8.decode(data);
    }

    if (emptyResponseCodes.contains(response?.statusCode ?? -1)) {
      return null;
    }

    throw const SerializationFailed(
      SerializationFailureReason.inputDataNilOrEmpty,
    );
  }

  //#endregion
}

/// {@macro serializer}
class JSONResponseSerializer extends Serializer {
  //#region Initializers

  /// {@macro serializer}
  JSONResponseSerializer({
    JsonDecoder? decoder,
    List<int>? emptyResponseCodes,
  })  : _decoder = decoder ?? const JsonDecoder(),
        emptyResponseCodes = emptyResponseCodes ?? Serializer.defaultEmptyCodes;

  //#endregion

  final JsonDecoder _decoder;

  /// HTTP status codes for which empty responses are always valid.
  /// `[204, 205]` by default.
  final List<int> emptyResponseCodes;

  //#region Serializer

  /// Serializes the response [data] into a JSON object
  /// otherwise it will throw an error if the request has failed.
  @override
  dynamic serialize(List<int>? data, HTTPResponse? response, Exception? error) {
    if (error != null) {
      throw error;
    }

    if (data != null && data.isNotEmpty) {
      try {
        final stringJSON = utf8.decode(data);
        return _decoder.convert(stringJSON);
      } catch (error) {
        throw SerializationFailed(
          SerializationFailureReason.jsonSerializationFailed,
          error: error,
        );
      }
    }

    if (emptyResponseCodes.contains(response?.statusCode ?? -1)) {
      return null;
    }

    throw const SerializationFailed(
      SerializationFailureReason.inputDataNilOrEmpty,
    );
  }

  //#endregion
}

/// {@macro serializer}
class ObjectResponseSerializer<T> extends Serializer<T?> {
  //#region Initializers

  /// {@macro serializer}
  ObjectResponseSerializer(
    this.fromJson, {
    List<int>? emptyResponseCodes,
  }) : emptyResponseCodes = emptyResponseCodes ?? Serializer.defaultEmptyCodes;

  //#endregion

  final _decoder = const JsonDecoder();

  /// HTTP status codes for which empty responses are always valid.
  /// `[204, 205]` by default.
  final List<int> emptyResponseCodes;

  /// The deserialization function to invoke when transforming
  /// the server response into an object.
  final T Function(dynamic) fromJson;

  //#region Serializer

  /// Serializes the response [data] into the provided [T] object
  /// otherwise it will throw an error if the request has failed.
  @override
  T? serialize(List<int>? data, HTTPResponse? response, Exception? error) {
    if (error != null) {
      throw error;
    }

    if (data != null && data.isNotEmpty) {
      try {
        final stringJSON = utf8.decode(data);
        final json = _decoder.convert(stringJSON);
        return fromJson(json);
      } catch (error) {
        throw SerializationFailed(
          SerializationFailureReason.jsonSerializationFailed,
          error: error,
        );
      }
    }

    if (emptyResponseCodes.contains(response?.statusCode ?? -1)) {
      return null;
    }

    throw const SerializationFailed(
      SerializationFailureReason.inputDataNilOrEmpty,
    );
  }

  //#endregion
}
