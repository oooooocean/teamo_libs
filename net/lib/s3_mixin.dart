import 'dart:math';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:net/net_dio.dart';

const bucket = 'public-teamo-com';

typedef UploadFileItem = ({Uint8List bytes, String fileName});

mixin S3Mixin {
  Future<String?> uploadFileToS3({required Uint8List bytes, required String fileName, int count = 0}) async {
    final randomName = '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1024)}_${fileName}';
    try {
      final url = (await Net2().dio.post('file/url/', data: [randomName], options: Options(contentType: 'application/json'))).data['data'][0];
      await Dio().putUri(Uri.parse(url), data: bytes, options: Options(contentType: 'application/octet-stream'));
      return randomName;
    } catch (error) {
      print('S3文件上传失败: $error');
      if (count >= 1) {
        return null;
      }
      return uploadFileToS3(bytes: bytes, fileName: fileName, count: 1); // 重试一次
    }
  }

  Future<String?> uploadFileStreamToS3({required Stream<Uint8List> data, required String fileName, required int fileLength}) async {
    final randomName = '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1024)}_${fileName}';
    try {
      final url = (await Net2().dio.post('file/url/', data: [randomName], options: Options(contentType: 'application/json'))).data['data'][0];
      await Dio().putUri(Uri.parse(url),
          data: data, options: Options(contentType: 'application/octet-stream', headers: {Headers.contentLengthHeader: fileLength.toString()}));
      return randomName;
    } catch (error) {
      print('S3文件上传失败: $error');
      return null;
    }
  }

  Future<List<String>?> uploadFilesToS3(List<UploadFileItem> files) async {
    final results = (await Future.wait(files.map((e) => uploadFileToS3(bytes: e.bytes, fileName: e.fileName)).toList()))
        .where((e) => e != null)
        .cast<String>()
        .toList();
    if (results.length != files.length) {
      return null;
    }
    return results;
  }

  String getFileUrlFromS3({required String fileName}) => 'https://public-teamo-com.s3.amazonaws.com/$fileName';
}
