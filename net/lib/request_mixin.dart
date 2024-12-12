import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile, Response;
import 'package:path_provider/path_provider.dart';
import 'net_dio.dart';
import 'package:dio/dio.dart';
import 'response.dart';

mixin RequestMixin {
  Dio get _net => Net2().dio;

  Future<T> get<T>(String uri, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    return _net
        .get(uri, queryParameters: _correctParameters(query))
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> post<T>(String uri, dynamic body, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    return await _net
        .post(uri,
            data: body,
            options: Options(contentType: 'application/json'),
            queryParameters: _correctParameters(query))
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> patch<T>(String uri, dynamic body, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    return await _net
        .patch(uri,
            data: body,
            options: Options(contentType: 'application/json'),
            queryParameters: _correctParameters(query))
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> put<T>(String uri, dynamic body, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    return await _net
        .put(uri,
            data: body,
            options: Options(contentType: 'application/json'),
            queryParameters: _correctParameters(query))
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> delete<T>(String uri, dynamic body, Decoder<T> decoder) async {
    return await _net
        .delete(uri, data: body)
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> uploadFiles<T>(
      List<Uint8List> files, String uri, String fileName, Decoder<T> decoder,
      {Map<String, dynamic>? query, Map<String, dynamic>? body}) async {
    final fileBytes = files
        .map((e) => MultipartFile.fromBytes(e, filename: fileName))
        .toList();
    final formData =
        FormData.fromMap({'files': fileBytes, if (body != null) ...body});
    return await _net
        .post(uri, data: formData, queryParameters: query)
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> uploadFile<T>(String filePath, String endPoint, Decoder<T> decoder,
      {Map<String, dynamic>? query,
      Map<String, dynamic>? body,
      String? fileName,
      String? contentType}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        filePath,
        filename: fileName,
        contentType:
            contentType != null ? DioMediaType.parse(contentType) : null,
      ),
      if (body != null) ...body
    });
    return await _net
        .post(endPoint, data: formData, queryParameters: query)
        .then((res) => _parse(res, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future download(String endPoint, String savePath, {Map<String, dynamic>? query, Function(int, int)? onProgress}) async {
    return _net
        .download(endPoint, savePath, queryParameters: query, onReceiveProgress: onProgress)
        .catchError(_receiveError<dynamic>, test: (error) => error is DioException);
  }

  T _receiveError<T>(dynamic error) {
    if (error.response != null) {
      return _parse(error.response!, null);
    }
    throw NetError()..message = error.toString();
  }

  T _parse<T>(Response res, Decoder<T>? decoder) {
    if (res.statusCode == null) {
      throw NetError()..message = '未知错误, 请稍后重试';
    }
    if (res.statusCode! >= 200 && res.statusCode! < 300 && decoder != null) {
      return decoder(res.data);
    }
    throw NetError.fromJson(res.data)
      ..code = NetCode.fromStatusCode(res.statusCode!);
  }

  Map<String, dynamic>? _correctParameters(Map<String, dynamic>? params) =>
      params?.map(
        (key, value) {
          var correctValue = value;
          if (value is! List) {
            correctValue = value.toString();
          }
          return MapEntry(key, correctValue);
        },
      );
}
