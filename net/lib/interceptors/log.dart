import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';

class Net2LogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logRequest(options);
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logResponse(response);
    super.onResponse(response, handler);
  }

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    _logError(err);
    super.onError(err, handler);
  }

  /// 记录请求
  _logRequest(RequestOptions request) async {
    var str = "---- 请求 ----\nmethod: ${request.method}\nurl: ${request.uri}\nquery: ${request.queryParameters}";
    final shouldLogBody =
        ['post', 'put', 'patch'].contains(request.method.toLowerCase()) && request.headers['content-type'] == 'application/json';
    if (shouldLogBody) {
      try {
        final body = await request.data;
        str += '\nbody: ${_encodeSafely(body)}';
      } catch (error) {
        str += '\nbody: <unserializable: $error>';
      }
    }
    log(str);
  }

  /// 记录响应
  _logResponse(Response res) {
    log("---- 响应 ----\npath: ${res.requestOptions.path}\ndata: ${_encodeSafely(res.data)}");
  }

  /// 记录错误
  _logError(DioException exception) async {
    final message =
        "---- 😈响应错误😈 ----\npath: ${exception.requestOptions.path} statusCode: ${exception.response?.statusCode} response: ${_encodeSafely(exception.response?.data)} error: $exception";
    log(message);
  }

  String _encodeSafely(dynamic data) {
    if (data == null) return 'null';
    if (data is ResponseBody) {
      return 'ResponseBody(stream: ${data.stream != null ? 'open' : 'closed'})';
    }
    try {
      return json.encode(data);
    } catch (_) {
      return data.toString();
    }
  }
}