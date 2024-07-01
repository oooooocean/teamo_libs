import 'package:dio/browser.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'interceptors/log.dart';
import 'interceptors/modify.dart';

class Net2 {
  static final Net2 _instance = Net2._init();

  Net2._init();

  factory Net2() => _instance;

  String baseUrl = '';
  Map<String, dynamic> extraHeaders = {};

  late final dio = Dio(
    BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 20),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
    ),
  )..interceptors.addAll([
      Net2Interceptor(),
      Net2LogInterceptor(),
    ]);

  config({required String baseUrl, required Map<String, dynamic> extraHeaders}) {
    this.baseUrl = baseUrl;
    this.extraHeaders = extraHeaders;
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate = (_, __, ___) => true;
    }
  }
}
