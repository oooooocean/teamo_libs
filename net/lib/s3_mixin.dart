import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:s3_storage/s3_storage.dart';

final s3 = S3Storage(
  endPoint: 's3.amazonaws.com',
  accessKey: 'AKIA5FTZDOAFJPRTKUBP',
  secretKey: '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',
  region: 'us-east-1',
  signingType: SigningType.V4,
);

const bucket = 'public-teamo-com';

typedef UploadFileItem = ({Uint8List bytes, String fileName});

mixin S3Mixin {
  Future<String?> uploadFileToS3({required Uint8List bytes, required String fileName}) async {
    final randomName = '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1024)}_${fileName}';
    try {
      await s3.putObject(bucket, randomName, Stream<Uint8List>.value(bytes));
      return randomName;
    } catch (error) {
      print('S3文件上传失败: $error');
      return null;
    }
  }

  Future<String?> uploadFileStreamToS3({required Stream<Uint8List> data, required String fileName}) async {
    final randomName = '${DateTime.now().millisecondsSinceEpoch}_${Random.secure().nextInt(1024)}_${fileName}';
    try {
      await s3.putObject(bucket, randomName, data);
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

  Future<List<int>?> getFileFromS3({required String fileName}) async {
    try {
      final stream = await s3.getObject(bucket, fileName);
      final result = (await stream.toList()).reduce((f, s) => f + s);
      return result;
    } catch (error) {
      print('S3文件下载失败失败: $error');
      return null;
    }
  }

  Future<ImageProvider?> getImageFromS3({required String fileName}) async {
    final bytes = await getFileFromS3(fileName: fileName);
    if (bytes == null) return null;
    return MemoryImage(Uint8List.fromList(bytes));
  }

  String getFileUrlFromS3({required String fileName}) => 'https://public-teamo-com.s3.amazonaws.com/$fileName';
}
