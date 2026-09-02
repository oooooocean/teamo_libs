import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:net/interceptors/modify.dart';
import 'package:net/net_dio.dart';

/// 401 的拦截器分支必须**终结** ErrorInterceptorHandler。
///
/// 此前它只调 `Net2().onError(...)` 就 `return`, 既不 next 也不 reject ——
/// dio 的拦截器链就此断掉, 那个请求的 Future 既不 resolve 也不 reject,
/// 调用方的 await **永久挂起**。
///
/// 后果不止于某一页转圈: 冷启动时 `Launcher.init()` 正 await 着
/// `updateIfNeed()` 的 `GET /user/<id>/`, token 一过期就永远等不到结果,
/// `runApp` 永不执行 —— App 卡死在闪屏, 只能清数据。
///
/// 判据是**调用方拿不拿得到结果**, 不是 onError 有没有被调到: 后者在旧代码
/// 里同样成立, 拿它当断言会平凡通过。
void main() {
  test('401: 调用方拿到 DioException, 而不是一个永不完成的 Future', () async {
    var notified = false;
    Net2().config(
      baseUrl: 'http://localhost/',
      extraHeaders: {},
      onError: (_) => notified = true,
    );

    final dio = Dio()
      ..interceptors.add(Net2Interceptor())
      ..httpClientAdapter = _StatusAdapter(401);

    // 前置断言: 证明这条用例真的走到了 401 分支, 而不是别的错误提前返回
    await expectLater(
      dio.get<dynamic>('/any').timeout(const Duration(seconds: 3)),
      throwsA(isA<DioException>()),
    );
    expect(notified, isTrue, reason: '401 分支应当通知 Net2().onError');
  });

  test('非 401 的错误照旧 reject（防止修复把别的分支一起改坏）', () async {
    Net2().config(
      baseUrl: 'http://localhost/',
      extraHeaders: {},
      onError: (_) => fail('500 不该走 401 分支'),
    );

    final dio = Dio()
      ..interceptors.add(Net2Interceptor())
      ..httpClientAdapter = _StatusAdapter(500);

    await expectLater(
      dio.get<dynamic>('/any').timeout(const Duration(seconds: 3)),
      throwsA(isA<DioException>()),
    );
  });
}

class _StatusAdapter implements HttpClientAdapter {
  _StatusAdapter(this.statusCode);

  final int statusCode;

  @override
  Future<ResponseBody> fetch(RequestOptions options,
          Stream<Uint8List>? requestStream, Future<void>? cancelFuture) async =>
      ResponseBody.fromString('{"code":$statusCode,"message":"x"}', statusCode,
          headers: {
            Headers.contentTypeHeader: [Headers.jsonContentType]
          });

  @override
  void close({bool force = false}) {}
}
