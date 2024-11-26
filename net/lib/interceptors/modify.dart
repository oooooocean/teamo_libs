import 'package:dio/dio.dart';
import 'package:net/net_dio.dart';
import 'package:net/response.dart';

class TimeoutError extends DioException {
  TimeoutError({required super.requestOptions});

  @override
  String toString() => '请求超时';
}

class Net2Interceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll(Net2().extraHeaders);
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if ([DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout, DioExceptionType.sendTimeout]
        .contains(err.type)) {
      super.onError(TimeoutError(requestOptions: err.requestOptions), handler);
      return;
    }
    if (err.response?.statusCode != null && Net2().errorHandler != null) {
      final netCode = NetCode.fromStatusCode(err.response!.statusCode!);
      Net2().errorHandler!(netCode);
    }
    super.onError(err, handler);
  }
}
