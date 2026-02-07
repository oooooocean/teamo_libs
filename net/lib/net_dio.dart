import 'dart:async';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:net/response.dart';
import 'interceptors/log.dart';
import 'interceptors/modify.dart';

class Net2 {
  ValueSetter<NetCode>? errorHandler;
  final _errorStreamController = StreamController<NetErrorEvent>.broadcast();
  Stream<NetErrorEvent> get errorStream => _errorStreamController.stream;

  void addError(NetErrorEvent event) => _errorStreamController.add(event);

  static final Net2 _instance = Net2._init();

  Net2._init();

  factory Net2() => _instance;

  late String baseUrl;
  late Map<String, dynamic> extraHeaders;

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

  config(
      {required String baseUrl,
      required Map<String, dynamic> extraHeaders,
      ValueSetter<NetCode>? defaultErrorHandler}) {
    this.baseUrl = baseUrl;
    this.extraHeaders = extraHeaders;
    errorHandler = defaultErrorHandler;
    if (!kIsWeb) {
      (dio.httpClientAdapter as IOHttpClientAdapter).validateCertificate = (_, __, ___) => true;
    }
  }
}
