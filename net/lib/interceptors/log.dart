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
    if (!['post', 'put'].contains(request.method.toLowerCase()) || request.headers['content-type'] != 'application/json') {
      log(str);
      return;
    }
    str += '\nbody: ${const JsonEncoder().convert(await request.data)}';
    log(str);
  }

  /// 记录响应
  _logResponse(Response res) {
    final jsonString = json.encode(res.data);
    log("---- 响应 ----\npath: ${res.requestOptions.path}\ndata: $jsonString");
  }

  /// 记录错误
  _logError(DioException exception) async {
    final message = "---- 😈响应错误😈 ----\npath: ${exception.requestOptions.path} statusCode: ${exception.response?.statusCode} response: ${json.encode(exception.response?.data)} error: $exception";
    log(message);
  }
}