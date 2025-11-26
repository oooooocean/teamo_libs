import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/log.dart';
import 'interceptors/modify.dart';

class Net2 {
  static final Net2 _instance = Net2._init();

  Net2._init();

  factory Net2() => _instance;

  late String baseUrl;
  late Map<String, dynamic> extraHeaders;
  late ValueSetter<Response> onError;

  late final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 60),
      sendTimeout: const Duration(seconds: 20),
    ),
  )..interceptors.addAll([
      Net2Interceptor(),
      Net2LogInterceptor(),
    ]);

  clear() {
    extraHeaders.clear();
  }

  config({required String baseUrl, required Map<String, dynamic> extraHeaders, required ValueSetter<Response> onError}) {
    this.baseUrl = baseUrl;
    this.extraHeaders = extraHeaders;
    this.onError = onError;
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate = (_, __, ___) => true;
    }
  }
}
