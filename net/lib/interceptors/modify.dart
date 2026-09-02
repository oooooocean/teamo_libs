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
      // 通知完仍要**终结** handler: 只 return 会让拦截器链断在这里, 调用方的
      // Future 既不 resolve 也不 reject, 永久挂起 —— 冷启动时 Launcher.init()
      // 正 await 着 updateIfNeed(), token 一过期 runApp 就永不执行, App 卡死
      // 在闪屏。护栏 test/unauthorized_interceptor_test.dart
      super.onError(err, handler);
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
