import 'package:dio/dio.dart';
import 'package:net/net_dio.dart';

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
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      Net2().onError(err.response!);
      return;
    }
    if ([DioExceptionType.connectionTimeout, DioExceptionType.receiveTimeout, DioExceptionType.sendTimeout]
        .contains(err.type)) {
      super.onError(TimeoutError(requestOptions: err.requestOptions), handler);
      return;
    }
    super.onError(err, handler);
  }
}
