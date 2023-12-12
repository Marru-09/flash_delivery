import 'package:network/network.dart';

/// {@template request_monitor}
/// Abstract class outlining the lifetime events inside the connection package.
/// It includes various events from the lifetime of [Request]
/// and its subclasses.
/// {@endtemplate}
abstract class RequestMonitor {
  /// Event called when a [DataRequest] calls a validation.
  void dataRequestDidValidate(
    DataRequest request, {
    required HTTPResponse response,
    required List<int>? data,
    required Result<void, Exception> result,
  }) {}

  /// Event called when a [DataRequest] calls a [Serializer]
  /// and creates a generic [Response]`.
  void dataRequestDidParseResponse<Value>(
    DataRequest request, {
    required Response<Value, ConnectionError> response,
  }) {}

  /// Called when cancellation is completed.
  void requestDidCancel(Request request) {}

  /// Called when [Request] has been completed.
  void requestDidComplete(Request request) {}

  /// Event called when the attempt to create a request from a [Request] fails.
  void requestDidFailToInitialize(
    Request request, {
    required ConnectionError error,
  }) {}

  /// Called when the initial request has been created.
  void requestDidInitialize(Request request) {}

  /// Called when [Request] has been resumed.
  void requestDidResume(Request request) {}
}

/// {@macro request_monitor}
class CompositeRequestMonitor extends RequestMonitor {
  //#region Initializers

  /// {@macro request_monitor}
  CompositeRequestMonitor(this._monitors);

  //#endregion

  final List<RequestMonitor> _monitors;

  //#region RequestMonitor

  /// Event called when a [DataRequest] calls a validation.
  @override
  void dataRequestDidValidate(
    DataRequest request, {
    required HTTPResponse response,
    required List<int>? data,
    required Result<void, Exception> result,
  }) {
    for (final monitor in _monitors) {
      monitor.dataRequestDidValidate(
        request,
        response: response,
        data: data,
        result: result,
      );
    }
  }

  /// Event called when a [DataRequest] calls a [Serializer]
  /// and creates a generic [Response]`.
  @override
  void dataRequestDidParseResponse<Value>(
    DataRequest request, {
    required Response<Value, ConnectionError> response,
  }) {
    for (final monitor in _monitors) {
      monitor.dataRequestDidParseResponse(request, response: response);
    }
  }

  /// Called when cancellation is completed.
  @override
  void requestDidCancel(Request request) {
    for (final monitor in _monitors) {
      monitor.requestDidCancel(request);
    }
  }

  /// Called when [Request] has been completed.
  @override
  void requestDidComplete(Request request) {
    for (final monitor in _monitors) {
      monitor.requestDidComplete(request);
    }
  }

  /// Event called when the attempt to create a request from a [Request] fails.
  @override
  void requestDidFailToInitialize(
    Request request, {
    required ConnectionError error,
  }) {
    for (final monitor in _monitors) {
      monitor.requestDidFailToInitialize(request, error: error);
    }
  }

  /// Called when the initial request has been created.
  @override
  void requestDidInitialize(Request request) {
    for (final monitor in _monitors) {
      monitor.requestDidInitialize(request);
    }
  }

  /// Called when [Request] has been resumed.
  @override
  void requestDidResume(Request request) {
    for (final monitor in _monitors) {
      monitor.requestDidResume(request);
    }
  }

  //#endregion
}
