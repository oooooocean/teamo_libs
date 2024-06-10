import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'net_dio.dart';
import 'package:dio/dio.dart';
import 'response.dart';

mixin RequestMixin {
  final _net = Net2().dio;

  Future<T> get<T>(String uri, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return _net
        .get(uri, queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError((error) => _parse((error as DioException).response?.data, decoder),
            test: (error) => error is DioException);
  }

  Future<T> post<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .post(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError((error) => _parse((error as DioException).response?.data, decoder),
            test: (error) => error is DioException);
  }

  Future<T> patch<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .patch(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError((error) => _parse((error as DioException).response?.data, decoder),
            test: (error) => error is DioException);
  }

  Future<T> put<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .put(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError((error) => _parse((error as DioException).response?.data, decoder),
            test: (error) => error is DioException);
  }

  Future<T> delete<T>(String uri, dynamic body, Decoder<T> decoder) async {
    return await _net.delete(uri, data: body).then((res) => _parse(res.data, decoder)).catchError(
        (error) => _parse((error as DioException).response?.data, decoder),
        test: (error) => error is DioException);
  }

  Future<T> uploadFiles<T>(List<Uint8List> files, String path, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    final formData =
        FormData.fromMap({'files': files.map((e) => MultipartFile.fromBytes(e, filename: 'file.jpeg')).toList()});
    return await _net
        .post(path, data: formData, queryParameters: query)
        .then((res) => _parse(res.data, decoder))
        .catchError((error) => _parse((error as DioException).response?.data, decoder),
            test: (error) => error is DioException);
  }

  T _parse<T>(dynamic data, Decoder<T> decoder) {
    try {
      final netRes = NetResponse.fromJson(data);
      if (netRes.code != NetCode.success) {
        throw netRes;
      }
      return decoder(netRes.data);
    } catch (error) {
      if (error is NetResponse) {
        rethrow;
      } else {
        if (!kReleaseMode) rethrow;
        throw FlutterError('服务端响应错误: $error');
      }
    }
  }

  Map<String, dynamic>? _correctParameters(Map<String, dynamic>? params) => params?.map((key, value) {
        var correctValue = value;
        if (value is! List) {
          correctValue = value.toString();
        }
        return MapEntry(key, correctValue);
      });
}
