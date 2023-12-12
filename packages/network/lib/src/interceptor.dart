import 'package:network/network.dart';

/// Outcome of the retry type.
enum RetryResultType {
  /// Retry should be attempted immediately.
  retry,

  /// Do not retry.
  doNotRetry,
}

/// {@template retry_result}
/// Outcome of determination whether retry is necessary.
/// {@endtemplate}
class RetryResult {
  //#region Initializers

  /// {@macro retry_result}
  RetryResult._({
    required this.type,
    this.delay = Duration.zero,
    this.error,
  });

  /// {@macro retry_result}
  factory RetryResult.doNotRetry({Exception? error}) {
    return RetryResult._(
      type: RetryResultType.doNotRetry,
      error: error,
    );
  }

  /// {@macro retry_result}
  factory RetryResult.retry({Duration delay = Duration.zero}) {
    return RetryResult._(type: RetryResultType.retry, delay: delay);
  }

  //#endregion

  /// A delay for the next retry attempt.
  final Duration delay;

  /// The underlying error.
  final Exception? error;

  /// The outcome of the retry type.
  final RetryResultType type;
}

/// {@template request_retrier}
/// A type that determines whether a request should be retried after
/// being executed by the specified connection manager and
/// encountering an error.
/// {@endtemplate}
abstract class RequestRetrier {
  /// Determines whether the `Request` should be retried by calling
  /// the `completion` closure.
  ///
  /// This operation is fully asynchronous. Any amount of time can be taken
  /// to determine whether the request needs to be retried. The one requirement
  /// is that the completion closure is called to ensure the request is properly
  /// cleaned up after.
  Future<RetryResult> retry(
    Request request, {
    required Connection connection,
    required Exception error,
  }) async {
    return RetryResult.doNotRetry();
  }
}

/// {@template request_interceptor}
/// A type that can inspect a [Request] in some manner if necessary.
/// {@endtemplate}
abstract class RequestInterceptor extends RequestRetrier {
  /// Inspects and adapts the specified [Request] in some
  /// manner and returns the Result.
  Future<void> intercept(Request request);
}

/// {@template interceptor}
/// A concrete implemenation of the [RequestInterceptor] that
/// allow composable interceptors.
/// {@endtemplate}
class Interceptor extends RequestInterceptor {
  //#region Initializers

  /// {@macro interceptor}
  Interceptor({this.interceptors = const [], this.retriers = const []});

  /// {@macro interceptor}
  Interceptor.fromInterceptor(
    RequestInterceptor interceptor,
  )   : interceptors = [interceptor],
        retriers = [];

  //#endregion

  /// The interceptors to apply.
  final List<RequestInterceptor> interceptors;

  /// The retriers to apply.
  final List<RequestRetrier> retriers;

  //#region RequestInterceptor

  /// Inspects and adapts the specified [Request] in some
  /// manner and returns the Result.
  @override
  Future<void> intercept(Request request) async {
    for (final interceptor in interceptors) {
      await interceptor.intercept(request);
    }
  }

  /// Determines whether the `Request` should be retried by calling
  /// the `completion` closure.
  ///
  /// This operation is fully asynchronous. Any amount of time can be taken
  /// to determine whether the request needs to be retried. The one requirement
  /// is that the completion closure is called to ensure the request is properly
  /// cleaned up after.
  @override
  Future<RetryResult> retry(
    Request request, {
    required Connection connection,
    required Exception error,
  }) async {
    return _retry(
      request,
      connection: connection,
      error: error,
      retriers: retriers,
    );
  }

  //#endregion

  //#region Private methods

  Future<RetryResult> _retry(
    Request request, {
    required Connection connection,
    required Exception error,
    required List<RequestRetrier> retriers,
  }) async {
    if (retriers.isEmpty) return RetryResult.doNotRetry();

    final retrier = retriers.removeAt(0);
    final retryResult = await retrier.retry(
      request,
      connection: connection,
      error: error,
    );

    switch (retryResult.type) {
      case RetryResultType.doNotRetry:
        if (retriers.isEmpty) return retryResult;

        return _retry(
          request,
          connection: connection,
          error: error,
          retriers: retriers,
        );

      case RetryResultType.retry:
        return retryResult;
    }
  }

  //#endregion
}
