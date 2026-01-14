import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:net/interceptors/modify.dart';
import 'net_dio.dart';
import 'package:dio/dio.dart';
import 'package:url_launcher/url_launcher.dart';
import 'response.dart';

typedef StreamDecoder<T> = T Function(String payload);

mixin RequestMixin {
  Dio get _net => Net2().dio;

  Future<T> get<T>(String uri, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return _net
        .get(uri, queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> post<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .post(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> patch<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .patch(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> put<T>(String uri, dynamic body, Decoder<T> decoder, {Map<String, dynamic>? query}) async {
    return await _net
        .put(uri,
            data: body, options: Options(contentType: 'application/json'), queryParameters: _correctParameters(query))
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> delete<T>(String uri, dynamic body, Decoder<T> decoder) async {
    return await _net
        .delete(uri, data: body)
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  Future<T> uploadFiles<T>(List<Uint8List> files, String path, Decoder<T> decoder,
      {Map<String, dynamic>? query}) async {
    final formData =
        FormData.fromMap({'files': files.map((e) => MultipartFile.fromBytes(e, filename: 'file.jpeg')).toList()});
    return await _net
        .post(path, data: formData, queryParameters: query)
        .then((res) => _parse(res.data, decoder))
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  /// 上传单个文件
  /// 
  /// [uri] 接口地址
  /// [fileBytes] 文件字节数组
  /// [fileName] 文件名
  /// [fieldName] 表单字段名，默认为 'file'
  /// [decoder] 响应解析器
  /// [query] 查询参数
  Future<T> uploadFile<T>(
    String uri,
    List<int> fileBytes,
    String fileName, {
    String fieldName = 'file',
    Decoder<T>? decoder,
    Map<String, dynamic>? query,
  }) async {
    final formData = FormData.fromMap({
      fieldName: MultipartFile.fromBytes(
        fileBytes,
        filename: fileName,
      ),
    });
    return await _net
        .post(
          uri,
          data: formData,
          queryParameters: _correctParameters(query),
        )
        .then((res) {
          if (decoder != null) {
            return _parse(res.data, decoder);
          }
          return res.data as T;
        })
        .catchError(_receiveError<T>, test: (error) => error is DioException);
  }

  /// 下载文件 - 直接使用系统浏览器下载
  /// 
  /// 打开系统浏览器，让浏览器处理文件下载
  /// 
  /// 返回空字符串
  Future<String> download(
    String uri, {
    Map<String, dynamic>? query,
  }) async {
    try {
      // 构建完整的下载 URL
      final baseUrl = _net.options.baseUrl;
      final fullUrl = baseUrl + uri;
      final uriObj = Uri.parse(fullUrl);
      
      // 添加查询参数
      final finalUri = query != null 
          ? uriObj.replace(queryParameters: _correctParameters(query)?.map((k, v) => MapEntry(k, v.toString())))
          : uriObj;

      // 使用 url_launcher 打开浏览器
      if (await canLaunchUrl(finalUri)) {
        await launchUrl(finalUri, mode: LaunchMode.externalApplication);
      } else {
        throw FlutterError('无法打开 URL: $finalUri');
      }

      return '';
    } catch (error) {
      throw FlutterError('下载失败: $error');
    }
  }

  T _receiveError<T>(dynamic error) {
    if ((error as DioException).response?.data != null) {
      return _parse(error.response?.data, null);
    }
    if (error is TimeoutError) {
      throw error;
    }
    throw FlutterError('网络异常: $error');
  }

  T _parse<T>(dynamic data, Decoder<T>? decoder) {
    try {
      final netRes = NetResponse.fromJson(data);
      if (netRes.code != NetCode.success || decoder == null) {
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

  Stream<T> streamSse<T>(
    String uri, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    StreamDecoder<T>? decoder,
    CancelToken? cancelToken,
  }) {
    final controller = StreamController<T>();
    final requestOptions = Options(
      method: body == null ? 'GET' : 'POST',
      responseType: ResponseType.stream,
      headers: {
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
        if (!kIsWeb) 'Connection': 'keep-alive',
        if (headers != null) ...headers,
      },
    );
    if (body != null && body is! FormData) {
      requestOptions.contentType = Headers.jsonContentType;
    }

    _net
        .request<ResponseBody>(
          uri,
          data: body,
          queryParameters: _correctParameters(query),
          options: requestOptions,
          cancelToken: cancelToken,
        )
        .then((response) {
          final responseBody = response.data;
          if (responseBody == null) {
            controller.addError(FlutterError('SSE 响应为空'));
            controller.close();
            return;
          }
          _pipeSse(responseBody.stream, controller, decoder);
        })
        .catchError(
          (error, stackTrace) => _emitStreamError(controller, error, stackTrace),
          test: (error) => error is DioException,
        );

    return controller.stream;
  }

  /// AI SSE 请求的便捷封装, 默认携带 `text/event-stream` 头.
  ///
  /// ```
  /// streamAi<String>(
  ///   '/ai/chat',
  ///   body: {'prompt': prompt},
  /// ).listen((token) => print(token));
  /// ```
  Stream<T> streamAi<T>(
    String uri, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
    StreamDecoder<T>? decoder,
    CancelToken? cancelToken,
  }) {
    return streamSse(
      uri,
      body: body,
      query: query,
      headers: headers,
      decoder: decoder,
      cancelToken: cancelToken,
    );
  }

  void _pipeSse<T>(
    Stream<List<int>> byteStream,
    StreamController<T> controller,
    StreamDecoder<T>? decoder,
  ) {
    var buffer = '';
    late final StreamSubscription<String> subscription;

    void emitAvailableEvents({bool force = false}) {
      while (true) {
        final separatorIndex = buffer.indexOf('\n\n');
        if (separatorIndex == -1) break;
        final rawEvent = buffer.substring(0, separatorIndex);
        buffer = buffer.substring(separatorIndex + 2);
        final payload = extractSsePayload(rawEvent);
        if (payload == null) continue;
        if (_shouldCloseOnPayload(payload, controller, subscription)) {
          return;
        }
        _addDecodedPayload(controller, payload, decoder);
      }

      if (force && buffer.trim().isNotEmpty) {
        final payload = extractSsePayload(buffer);
        buffer = '';
        if (payload == null) return;
        if (_shouldCloseOnPayload(payload, controller, subscription)) {
          return;
        }
        _addDecodedPayload(controller, payload, decoder);
      }
    }

    subscription = byteStream.cast<List<int>>().transform(utf8.decoder).listen(
      (chunk) {
        buffer += chunk.replaceAll('\r', '');
        emitAvailableEvents();
      },
      onDone: () {
        emitAvailableEvents(force: true);
        if (!controller.isClosed) controller.close();
      },
      onError: (error, stackTrace) {
        controller.addError(error, stackTrace);
        if (!controller.isClosed) controller.close();
      },
      cancelOnError: false,
    );

    controller.onCancel = () => subscription.cancel();
  }

  bool _shouldCloseOnPayload<T>(
    String payload,
    StreamController<T> controller,
    StreamSubscription<String> subscription,
  ) {
    if (payload == '[DONE]') {
      subscription.cancel();
      if (!controller.isClosed) controller.close();
      return true;
    }
    return controller.isClosed;
  }

  void _addDecodedPayload<T>(
    StreamController<T> controller,
    String payload,
    StreamDecoder<T>? decoder,
  ) {
    if (controller.isClosed) return;
    try {
      controller.add(decodeSsePayload(payload, decoder));
    } catch (error, stackTrace) {
      controller.addError(error, stackTrace);
    }
  }

  void _emitStreamError<T>(
    StreamController<T> controller,
    Object error,
    StackTrace stackTrace,
  ) {
    if (controller.isClosed) return;

    if (error is DioException && error.response?.data != null) {
      try {
        _parse(error.response?.data, null);
      } catch (parsedError, parsedStackTrace) {
        controller.addError(
          parsedError,
          parsedStackTrace is StackTrace ? parsedStackTrace : stackTrace,
        );
        controller.close();
        return;
      }
    }

    controller.addError(error, stackTrace);
    controller.close();
  }
}

@visibleForTesting
T decodeSsePayload<T>(String payload, StreamDecoder<T>? decoder) {
  if (decoder != null) {
    return decoder(payload);
  }

  if (T == String || T == dynamic) {
    return payload as T;
  }

  throw FlutterError('未提供 decoder, 无法将数据转换为 $T');
}

@visibleForTesting
String? extractSsePayload(String rawEvent) {
  final lines = rawEvent.split('\n');
  final payloadLines = <String>[];

  for (final line in lines) {
    if (line.isEmpty) continue;
    if (line.startsWith('data:')) {
      payloadLines.add(line.substring(5).trimLeft());
    }
  }

  if (payloadLines.isEmpty) {
    return null;
  }

  return payloadLines.join('\n');
}
