import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:network/network.dart';

part 'request_validations.dart';

/// A typedef representing a void callback function.
typedef VoidCallback = void Function();

/// A typedef representing a validation callback function.
///
/// The validation callback takes no arguments and returns a [Result] object
/// that contains either a [void] value or an [Exception] if validation fails.
typedef ValidationCallback = Result<void, Exception> Function(
  HTTPResponse,
  List<int>? data,
);

/// Represents all possibles HTTP methods
enum HTTPMethod {
  /// Represents a DELETE HTTPMethod.
  delete,

  /// Represents a GET HTTPMethod.
  get,

  /// Represents a PATCH HTTPMethod.
  patch,

  /// Represents a POST HTTPMethod.
  post,

  /// Represents a PUT HTTPMethod.
  put,
}

extension _HeadersX on dio.Headers {
  /// Returns the [HTTPHeaders] transformation
  HTTPHeaders asHTTPHeaders() {
    final headers = HTTPHeaders();
    forEach((name, values) {
      headers.append(HTTPHeader(name: name, value: values.last));
    });

    return headers;
  }
}

/// Extension on [HTTPMethod] enum to provide additional functionality.
extension HTTPMethodX on HTTPMethod {
  /// Returns the raw value
  String get rawValue {
    switch (this) {
      case HTTPMethod.delete:
        return 'DELETE';

      case HTTPMethod.get:
        return 'GET';

      case HTTPMethod.patch:
        return 'PATCH';

      case HTTPMethod.post:
        return 'POST';

      case HTTPMethod.put:
        return 'PUT';
    }
  }
}

/// Represents all the possibles states of a [Request]
/// during it's lifecycle
enum RequestState {
  /// State set when cancel is called.
  cancelled,

  /// State set when all response serialization completion closures have been
  /// cleared on the [Request] and enqueued on their respective queues.
  finished,

  /// Initial state of the [Request].
  initialized,

  /// State set when the [Request] is resumed.
  resumed,
}

/// Determines whether this can be transitioned to the provided [RequestState].
extension _Transition on RequestState {
  bool canTransition(RequestState newState) {
    final states = <RequestState, List<RequestState>>{
      RequestState.cancelled: [],
      RequestState.finished: [],
      RequestState.initialized: [
        RequestState.cancelled,
        RequestState.finished,
        RequestState.initialized,
        RequestState.resumed,
      ],
      RequestState.resumed: [
        RequestState.cancelled,
        RequestState.finished,
        RequestState.resumed,
      ],
    };

    final acceptedStates = states[this] ?? [];
    return acceptedStates.contains(newState);
  }
}

/// {@template request_delegate}
/// Abstraction for [Request]'s communication back to the delegate.
/// {@endtemplate}
abstract class RequestDelegate {
  /// Asynchronously ask the delegate whether a [Request] will be retried.
  Future<RetryResult> retryResult(
    Request request, {
    required ConnectionError error,
  });

  /// Asynchronously retry the `Request`.
  void retryRequest(Request request, {required Duration delay});
}

/// {@template request}
/// [Request] Is the common superclass of all requests types and
/// provides common state handling.
/// {@endtemplate}
class Request {
  // #region Initializers

  /// {@macro request}
  Request({
    required this.method,
    required this.url,
    this.delegate,
    this.headers,
    this.interceptor,
    this.monitor,
    this.query,
  });

  //#endregion

  Future<dio.Response<Uint8List>>? _clientRequest;
  final List<VoidCallback> _responseSerializers = [];

  /// int providing a unique identifier for the [Request].
  final int id = DateTime.now().millisecondsSinceEpoch;

  /// Returns the absolute [Uri] of the request
  ///
  /// The absolute url could include the query parameters
  /// if any
  Uri get absoluteUrl => url.replace(query: encodedQuery);

  /// The [Request]'s delegate.
  final RequestDelegate? delegate;

  /// The url encoded query.
  String? encodedQuery;

  /// Final [ConnectionError] for the [Request].
  ConnectionError? get error => _error;
  ConnectionError? _error;

  /// Headers of this [Request].
  HTTPHeaders? headers;

  /// The [Request] interceptor.
  final RequestInterceptor? interceptor;

  /// Returns true if the [Request] has been
  /// initialized correctly.
  bool get isReady => _clientRequest != null;

  /// The HTTP method of the request.
  final HTTPMethod method;

  /// [RequestMonitor] used for events.
  final RequestMonitor? monitor;

  /// The query parameters used in this [Request].
  Map<String, String>? query;

  /// Number of times the `Request` has been retried.
  int get retryCount => _retryCount;
  int _retryCount = 0;

  /// [HTTPResponse] received from the server.
  HTTPResponse? get response => _response;
  HTTPResponse? _response;

  /// The URL to which the request will be sent.
  final Uri url;

  /// The current [RequestState] of this [Request].
  RequestState get state => _state;
  RequestState _state = RequestState.initialized;
  set state(RequestState newState) {
    if (!_state.canTransition(newState)) {
      throw StateError("Can't transition to $newState.");
    }

    _state = newState;
  }

  /// Callback closures that store the validation calls enqueued.
  List<VoidCallback> get validators => _validators;
  final List<VoidCallback> _validators = [];

  //#region Instance methods

  /// Cancels the instance.
  void cancel() {
    if (state.canTransition(RequestState.cancelled)) {
      state = RequestState.cancelled;
    }

    didCancel();
  }

  /// Called to determine whether retry will be triggered for the particular
  /// error, or whether the instance should call finish().
  ///
  /// - Parameter error: The possible [ConnectionError] which may trigger retry.
  Future<void> retryOrComplete(ConnectionError? error) async {
    if (error == null) {
      didComplete();
      return;
    }

    if (delegate == null) didComplete();

    final retryResult = await delegate!.retryResult(this, error: error);

    switch (retryResult.type) {
      case RetryResultType.doNotRetry:
        if (retryResult.error != null && retryResult.error is ConnectionError) {
          _error = retryResult.error! as ConnectionError;
        }

        didComplete();

      case RetryResultType.retry:
        delegate?.retryRequest(this, delay: retryResult.delay);
    }
  }

  //#endregion

  //#region Overriden methods

  @override
  String toString() => '$method $absoluteUrl';

  //#endregion

  //#region Instance methods

  /// Appends the response serialization closure to the instance.
  void appendResponseSerializer(VoidCallback callback) {
    _responseSerializers.add(callback);
    resume();
  }

  /// Called when cancellation is completed.
  void didCancel() {
    _error = error ?? const RequestCancelled();
    monitor?.requestDidCancel(this);
  }

  /// Invoked when the request finish.
  void didComplete() {
    if (state.canTransition(RequestState.finished)) {
      state = RequestState.finished;
    }

    for (final validator in _validators) {
      validator();
    }

    for (final serializer in _responseSerializers) {
      serializer();
    }

    monitor?.requestDidComplete(this);
  }

  /// Stores the given request.
  void didCreateRequest(Future<dio.Response<Uint8List>> request) {
    _clientRequest = request;
    monitor?.requestDidInitialize(this);
  }

  /// Invoked when the request creation throws a error in.
  void didFailToCreateURLRequest(ConnectionError error) {
    _error = error;
    monitor?.requestDidFailToInitialize(this, error: error);
  }

  /// Called when the [RequestDelegate] is going to retry this [Request].
  void prepareForRetry() {
    _retryCount += 1;
  }

  /// Resumes the instance.
  Future<void> resume() async {
    throw UnimplementedError();
  }

  //#endregion
}

/// {@template data_request}
/// [Request] subclass which handles in-memory Data download.
/// {@endtemplate}
class DataRequest extends Request {
  //#region Initializers

  /// {@macro data_request}
  DataRequest({
    required super.method,
    required super.url,
    super.delegate,
    super.headers,
    super.interceptor,
    super.monitor,
  });

  //#endregion

  /// The [DataRequest] body.
  String? body;

  /// The content length of the body.
  int contentLength = -1;

  /// Data read from the server so far.
  List<int>? get data => _data;
  List<int>? _data;

  //#region Instance methods

  /// Validates the [DataRequest] using the specified [callback].
  void customValidation(ValidationCallback callback) {
    void validation() {
      if (response != null && error == null) {
        final result = callback(response!, data);

        if (result.isFailure) {
          _error = result.failure is ConnectionError
              ? result.failure! as ConnectionError
              : CustomResponseValidationFailed(error: result.failure);
        }

        monitor?.dataRequestDidValidate(
          this,
          response: response!,
          data: data,
          result: result,
        );
      }
    }

    validators.add(validation);
  }

  /// Called when the [data] is received by this instance.
  void didReceive(List<int> data) {
    _data ??= [];
    _data?.addAll(data);
  }

  /// Returns a Object using the [ObjectResponseSerializer].
  Future<Response<T, ConnectionError>> responseOf<T>(
    T Function(dynamic) fromJson, {
    List<int>? emptyResponseCodes,
  }) {
    return serializedResponse(
      ObjectResponseSerializer<T>(
        fromJson,
        emptyResponseCodes: emptyResponseCodes ?? Serializer.defaultEmptyCodes,
      ),
    );
  }

  /// Returns a JSONObject using the [JSONResponseSerializer].
  Future<Response<dynamic, ConnectionError>> responseJSON({
    List<int>? emptyResponseCodes,
  }) {
    return serializedResponse(
      JSONResponseSerializer(
        emptyResponseCodes: emptyResponseCodes ?? Serializer.defaultEmptyCodes,
      ),
    );
  }

  /// Adds a callback to be called once the request has finished.
  Future<Response<SerializedObject, ConnectionError>>
      serializedResponse<SerializedObject, S extends Serializer>(
    S serializer,
  ) async {
    final completer = Completer<Response<SerializedObject, ConnectionError>>();

    void completion(Result<SerializedObject, ConnectionError> result) {
      final response = Response<SerializedObject, ConnectionError>(
        data: data,
        response: this.response,
        result: result,
      );

      if (!completer.isCompleted) {
        monitor?.dataRequestDidParseResponse(this, response: response);
        completer.complete(response);
      }
    }

    appendResponseSerializer(() {
      try {
        final serializedObject = serializer.serialize(data, response, error);
        completion(Result.success(serializedObject as SerializedObject));
      } catch (error) {
        final wrappedError = error is ConnectionError
            ? error
            : CreateURLRequestFailed(error: error);
        completion(Result.failure(wrappedError));
      }
    });

    return completer.future;
  }

  /// Validates the request.
  void validate() {
    return validateAcceptableStatusCodes(
      List.generate(99, (index) => 200 + index),
    );
  }

  //#endregion

  //#region Overriden methods

  @override
  Future<void> resume() async {
    if (error != null) {
      await retryOrComplete(_error);
      return;
    }

    if (state.canTransition(RequestState.resumed)) {
      state = RequestState.resumed;
      monitor?.requestDidResume(this);

      if (_clientRequest != null) {
        try {
          final httpResponse = await _clientRequest;

          if (state == RequestState.cancelled) {
            _error = const RequestCancelled();
            await retryOrComplete(_error);
            return;
          }

          if (httpResponse == null) {
            _error = const RequestFailed(
              error: 'Could not connect to the server.',
            );
            await retryOrComplete(_error);
            return;
          }

          _response = HTTPResponse(
            contentLength: httpResponse.data?.length ?? 0,
            headers: httpResponse.headers.asHTTPHeaders(),
            reasonPhrase: httpResponse.statusMessage,
            statusCode: httpResponse.statusCode ?? 0,
            url: httpResponse.realUri,
          );

          didReceive(httpResponse.data!);
          await retryOrComplete(_error);
        } on dio.DioException catch (error) {
          final data = error.response?.data;

          if (data is List<int>) {
            _response = HTTPResponse(
              contentLength: data.length,
              headers: error.response?.headers.asHTTPHeaders() ?? HTTPHeaders(),
              reasonPhrase: error.response?.statusMessage,
              statusCode: error.response?.statusCode ?? 0,
              url: error.response?.realUri ?? url,
            );

            didReceive(data);
            await retryOrComplete(_error);
          }

          _error = RequestFailed(error: error);
          await retryOrComplete(_error);
        }
      }
    }
  }

  /// A textual representation of this instance, suitable for debugging.
  @override
  String toString() {
    final components = [
      'curl --location',
      '--request ${method.rawValue} "$absoluteUrl"',
    ];

    if (headers != null) {
      for (final header in headers!.dictionary.entries) {
        final escapedValue = header.value.replaceAll('"', r'\"');
        components.add('--header "${header.key}: $escapedValue"');
      }
    }

    if (body != null) {
      final escapedBody = body!.replaceAll('"', r'\"');

      components.add('-d "$escapedBody"');
    }

    return components.join('\\\n\t');
  }

  //#endregion
}

/// {@macro upload_request}
class UploadRequest extends DataRequest {
  //#region Initializers

  /// {@macro data_request}
  UploadRequest({
    required super.method,
    required super.url,
    required super.headers,
    super.interceptor,
  });

  //#endregion
}
