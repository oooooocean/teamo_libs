import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:net/net_dio.dart';

const bucket = 'public-teamo-com';

typedef UploadFileItem = ({Uint8List bytes, String fileName});

/// 上传到 S3 失败
///
/// 必须抛出而非静默返回 key: 上传失败却把 key 存进业务数据, 会得到一条
/// 永远打不开的链接, 且用户与服务端都毫不知情
class S3UploadException implements Exception {
  final List<String> fileNames;

  S3UploadException(this.fileNames);

  @override
  String toString() => 'S3 upload failed: ${fileNames.join(', ')}';
}

mixin S3Mixin {
  Future<String> uploadFileToS3(
      {required Uint8List bytes, required String fileName, int count = 0, String? bucket, String? prefix}) async {
    final ret = await uploadFilesToS3([(bytes: bytes, fileName: fileName)], bucket: bucket, prefix: prefix);
    return ret[0];
  }

  Future<String> uploadFileStreamToS3(
      {required Stream<Uint8List> data,
      required String fileName,
      required int fileLength,
      String? bucket,
      String? prefix}) async {
    // 1. 获取Key
    final keysAndNames = await _getAwsKeys([_getRandomFileName(fileName, prefix: prefix)], bucket: bucket);
    final key = keysAndNames.$1.first;
    // 2. 上传
    final ok = await _upload(key, data, 0, fileLength);
    print('图片/文件上传结果: $ok');
    if (!ok) throw S3UploadException([fileName]);
    // 3. 返回文件名
    return keysAndNames.$2.first;
  }

  Future<List<String>> uploadFilesToS3(List<UploadFileItem> files, {String? bucket, String? prefix}) async {
    // 1. 获取Key
    final keysAndNames = await _getAwsKeys(files.map((e) => e.fileName).toList(), bucket: bucket, prefix: prefix);
    final keys = keysAndNames.$1;
    // 2. 上传. 用下标而非 indexOf: 两个内容相同的 record 相等, indexOf 会取到同一个 key
    final ret = await Future.wait(
        [for (var i = 0; i < files.length; i++) _upload(keys[i], files[i].bytes)]);
    print('图片/文件上传结果: $ret');
    final failed = [
      for (var i = 0; i < ret.length; i++)
        if (!ret[i]) files[i].fileName
    ];
    if (failed.isNotEmpty) throw S3UploadException(failed);
    // 3. 返回文件名
    return keysAndNames.$2;
  }

  String getFileUrlFromS3({required String fileName, String? bucket}) =>
      'https://${(bucket != null && bucket.isNotEmpty) ? bucket : "public-teamo-com"}.s3.amazonaws.com/$fileName';

  String _getRandomFileName(String fileName, {String? prefix}) =>
      '${prefix ?? ''}${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1024)}_$fileName';

  Future<(List<String>, List<String>)> _getAwsKeys(List<String> fileNames, {String? bucket, String? prefix}) async {
    final filenames = fileNames.map((e) => _getRandomFileName(e, prefix: prefix)).toList();
    // 同时防御 null 和空串; `??` 只覆盖 null, 空串会绕过默认值导致后端 boto3 报 Invalid bucket name ""
    final effectiveBucket = (bucket != null && bucket.isNotEmpty) ? bucket : 'public-teamo-com';
    final urls = (await Net2().dio.post('file/url/',
            data: {'fileNames': filenames, 'bucket': effectiveBucket},
            options: Options(contentType: 'application/json')))
        .data['data'] as List<dynamic>;
    return (urls.cast<String>(), filenames);
  }

  Future<bool> _upload(String key, dynamic bytes, [int count = 0, int? fileLength]) async {
    final option = Options(contentType: 'application/octet-stream');
    if (fileLength != null) {
      option.headers = {Headers.contentLengthHeader: fileLength.toString()};
    }
    try {
      await Dio().putUri(Uri.parse(key), data: bytes, options: option);
      return true;
    } catch (error) {
      if (count >= 1) {
        return false;
      }
      return _upload(key, bytes, 1); // 重试一次
    }
  }
}
