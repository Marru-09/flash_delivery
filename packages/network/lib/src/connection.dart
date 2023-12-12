import 'dart:async';
import 'dart:developer';
import 'dart:typed_data';

import 'package:dio/dio.dart' as dio;
import 'package:meta/meta.dart';
import 'package:network/network.dart';

/// {@template connection}
/// A client that prepares an http client to communicate with a remote server.
/// {@endtemplate}
abstract class Connection {
  /// The base url used accross [Request]s.
  String get baseUrl;

  /// Sends an HTTP DELETE request.
  ///
  /// The HTTP method is set to DELETE and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  Future<DataRequest> delete(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Sends an HTTP GET request.
  ///
  /// The HTTP method is set to GET and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  Future<DataRequest> get(
    String path, {
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Sends an HTTP PATCH request.
  ///
  /// The HTTP method is set to PATCH and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  Future<DataRequest> patch(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Sends an HTTP POST request.
  ///
  /// The HTTP method is set to POST and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  Future<DataRequest> post(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Sends an HTTP PUT request.
  ///
  /// The HTTP method is set to PUT and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  Future<DataRequest> put(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Sends the configured request with options.
  ///
  /// The HTTP method is specified in [method] and the path to use in the url in
  /// [path] including a possible body or query parameters throughout
  /// the [parameters], the [headers] to be added to the request and
  /// a [interceptor] to observe the request lifecycle.
  Future<DataRequest> request(
    String path, {
    required HTTPMethod method,
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  });

  /// Creates an [UploadRequest] for the prebuilt [MultiPartFormFile]
  /// value and [RequestInterceptor].
  ///
  /// - Parameters:
  ///   - path: The path for the url.
  ///   - method: The [HTTPMethod] to perform on the [UploadRequest].
  ///   - files: The files to be uploaded.
  ///   - headers: Extra headers to be added to the request.
  ///   - interceptor: The interceptor to use to modify the request.
  /// - Returns: A new [UploadRequest] instance.
  Future<UploadRequest> upload(
    String path, {
    required HTTPMethod method,
    required MultiPartFormFile file,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
  });

  /// Sets the new header into the connection.
  void setHeader(HTTPHeader header);
}

/// {@macro connection}
class ConnectionManager implements Connection, RequestDelegate {
  //#region Initializers

  /// {@macro connection}
  ConnectionManager(
    String url, {
    this.interceptor,
    List<RequestMonitor> monitors = const [],
  })  : monitor = CompositeRequestMonitor(monitors),
        _client = dio.Dio(dio.BaseOptions(baseUrl: url));

  /// {@macro connection}
  @visibleForTesting
  ConnectionManager.manager({
    required dio.Dio client,
    this.interceptor,
    List<RequestMonitor> monitors = const [],
  })  : monitor = CompositeRequestMonitor(monitors),
        _client = client;

  //endregion

  final dio.Dio _client;
  final Map<int, Request> _requests = {};
  final HTTPHeaders _headers = HTTPHeaders.defaultHeaders();

  /// The base url used accross [Request]s.
  @override
  String get baseUrl => _client.options.baseUrl;

  /// [CompositeRequestMonitor] used to compose defaultEventMonitors
  /// and any passed [RequestMonitor]s.
  final CompositeRequestMonitor monitor;

  /// [RequestInterceptor] used for all [Request]´s created by the instance.
  final RequestInterceptor? interceptor;

  //#region Connection

  /// Sends an HTTP DELETE request.
  ///
  /// The HTTP method is set to DELETE and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  @override
  Future<DataRequest> delete(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) {
    return request(
      path,
      encoder: encoder,
      headers: headers,
      interceptor: interceptor,
      method: HTTPMethod.delete,
      parameters: parameters,
    );
  }

  /// Sends an HTTP GET request.
  ///
  /// The HTTP method is set to GET and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  @override
  Future<DataRequest> get(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) {
    return request(
      path,
      encoder: encoder,
      headers: headers,
      interceptor: interceptor,
      method: HTTPMethod.get,
      parameters: parameters,
    );
  }

  /// Sends an HTTP PATCH request.
  ///
  /// The HTTP method is set to PATCH and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  @override
  Future<DataRequest> patch(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) {
    return request(
      path,
      encoder: encoder,
      headers: headers,
      interceptor: interceptor,
      method: HTTPMethod.patch,
      parameters: parameters,
    );
  }

  /// Sends an HTTP POST request.
  ///
  /// The HTTP method is set to POST and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  @override
  Future<DataRequest> post(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) {
    return request(
      path,
      encoder: encoder,
      headers: headers,
      interceptor: interceptor,
      method: HTTPMethod.post,
      parameters: parameters,
    );
  }

  /// Sends an HTTP PUT request.
  ///
  /// The HTTP method is set to PUT and the [path]
  /// (including a possible query throughout the [parameters]) to use with the
  /// url, the [headers] to be added to the request and a [interceptor] to
  /// observe the request lifecycle.
  ///
  ///
  /// For more fine-grained control over the request, use [request] instead.
  @override
  Future<DataRequest> put(
    String path, {
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) {
    return request(
      path,
      encoder: encoder,
      headers: headers,
      interceptor: interceptor,
      method: HTTPMethod.put,
      parameters: parameters,
    );
  }

  /// Sends the configured request with options.
  ///
  /// The HTTP method is specified in [method] and the path to use in the url in
  /// [path] including a possible body or query parameters throughout
  /// the [parameters], the [headers] to be added to the request and
  /// a [interceptor] to observe the request lifecycle.
  @override
  Future<DataRequest> request(
    String path, {
    required HTTPMethod method,
    Encoder? encoder,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
    Map<String, dynamic>? parameters,
  }) async {
    final request = DataRequest(
      delegate: this,
      headers: (headers ?? HTTPHeaders()) + _headers,
      method: method,
      url: Uri.parse('${_client.options.baseUrl}/$path'),
      interceptor: interceptor,
      monitor: monitor,
    );

    final effectiveEncoder = encoder ??
        (Destination.methodDependent.encodesParametersInURL(method)
            ? URLParameterEncoder()
            : JSONParameterEncoder());

    try {
      await effectiveEncoder.encode(request, parameters);
      await _prepareRequest(request, interceptor: interceptor);
      log('request ready $request');
    } catch (error) {
      final wrappedError = error is ConnectionError
          ? error
          : CreateURLRequestFailed(error: error);

      request.didFailToCreateURLRequest(wrappedError);

      unawaited(request.resume());
    }

    return request;
  }

  /// Creates an [UploadRequest] for the prebuilt [MultiPartFormFile]
  /// value and [RequestInterceptor].
  ///
  /// - Parameters:
  ///   - path: The path for the url.
  ///   - form: [MultiPartFormFile] instance to upload..
  ///   - headers: Extra headers to be added to the request.
  ///   - interceptor: The interceptor to use to modify the request.
  ///   - method: The [HTTPMethod] to perform on the [UploadRequest].
  /// - Returns: A new [UploadRequest] instance.
  @override
  Future<UploadRequest> upload(
    String path, {
    required HTTPMethod method,
    required MultiPartFormFile file,
    HTTPHeaders? headers,
    RequestInterceptor? interceptor,
  }) async {
    final uploadRequest = UploadRequest(
      method: method,
      url: Uri.parse('$baseUrl/$path'),
      headers: headers,
    );

    await _prepareUploadRequest(
      uploadRequest,
      file: file,
      interceptor: interceptor,
    );

    log('request ready $uploadRequest');
    return uploadRequest;
  }

  /// Sets the new header into the connection.
  @override
  void setHeader(HTTPHeader header) {
    _headers.append(header);
  }

  //#endregion

  //#region RequestDelegate

  /// Asynchronously ask the delegate whether a [Request] will be retried.
  @override
  Future<RetryResult> retryResult(
    Request request, {
    required ConnectionError error,
  }) async {
    final retrier = _retrierForRequest(request);

    if (retrier == null) return RetryResult.doNotRetry();

    try {
      final retryResult = await retrier.retry(
        request,
        connection: this,
        error: error,
      );

      if (retryResult.error == null) return retryResult;

      final retryError = RequestRetryFailed(error: retryResult.error);
      return RetryResult.doNotRetry(error: retryError);
    } catch (e) {
      return RetryResult.doNotRetry(error: error);
    }
  }

  /// Asynchronously retry the `Request`.
  @override
  Future<void> retryRequest(Request request, {required Duration delay}) async {
    await Future<void>.delayed(delay);

    if (request.state == RequestState.cancelled) return;

    request.prepareForRetry();
    await _prepareRequest(request);
  }

  //#endregion

  //#region Private methods

  void _didCreateURLRequest(
    Future<dio.Response<Uint8List>> clientRequest, {
    required Request request,
  }) {
    if (request.state == RequestState.cancelled) {
      return;
    }

    _requests[request.id] = request;
    request.didCreateRequest(clientRequest);
  }

  Future<void> _interceptRequest(
    Request request, {
    required RequestInterceptor? interceptor,
  }) async {
    final requestIterceptor = _interceptorWith(interceptor);

    if (requestIterceptor != null) {
      await requestIterceptor.intercept(request);
    }
  }

  RequestInterceptor? _interceptorWith(RequestInterceptor? requestInterceptor) {
    if (requestInterceptor != null && interceptor != null) {
      return Interceptor(interceptors: [requestInterceptor, interceptor!]);
    }

    return requestInterceptor ?? interceptor;
  }

  Future<void> _prepareRequest(
    Request request, {
    RequestInterceptor? interceptor,
  }) async {
    try {
      await _interceptRequest(request, interceptor: interceptor);

      final options = dio.Options(
        method: request.method.rawValue,
        headers: request.headers?.dictionary,
        responseType: dio.ResponseType.bytes,
      );

      final clientRequest = _client.requestUri<Uint8List>(
        request.absoluteUrl,
        data: request is DataRequest ? request.body : null,
        options: options,
      );

      _didCreateURLRequest(clientRequest, request: request);
    } catch (error) {
      final wrappedError = error is ConnectionError
          ? error
          : CreateURLRequestFailed(error: error);

      request.didFailToCreateURLRequest(wrappedError);

      await request.resume();
    }
  }

  Future<void> _prepareUploadRequest(
    UploadRequest request, {
    required MultiPartFormFile file,
    RequestInterceptor? interceptor,
  }) async {
    try {
      await _interceptRequest(interceptor: interceptor, request);

      final data = dio.FormData.fromMap(
        {
          'file': await dio.MultipartFile.fromFile(
            file.path,
            contentType: file.mediaType,
            filename: file.getName(),
          ),
        },
      );

      final options = dio.Options(
        method: request.method.rawValue,
        headers: request.headers?.dictionary,
        responseType: dio.ResponseType.bytes,
      );

      final clientRequest = _client.requestUri<Uint8List>(
        request.url,
        data: data,
        options: options,
      );

      _didCreateURLRequest(clientRequest, request: request);
    } catch (error) {
      final wrappedError = error is ConnectionError
          ? error
          : CreateURLRequestFailed(error: error);

      request.didFailToCreateURLRequest(wrappedError);

      await request.resume();
    }
  }

  RequestRetrier? _retrierForRequest(Request request) {
    if (interceptor != null && request.interceptor != null) {
      return Interceptor(retriers: [request.interceptor!, interceptor!]);
    }

    return request.interceptor ?? interceptor;
  }

  //#endregion
}
