
import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

enum NetCode {
  success,
  clientError,
  authFail,
  serverError,
  unknownError;

  bool get shouldRelaunch => [NetCode.authFail].contains(this);

  static fromStatusCode(int statusCode) {
    if (statusCode >= 200 && statusCode < 300) {
      return NetCode.success;
    } else if (statusCode == 401) {
      return NetCode.authFail;
    } else if (statusCode >= 400 && statusCode < 500) {
      return NetCode.clientError;
    } else if (statusCode >= 500) {
      return NetCode.serverError;
    } else {
      return NetCode.unknownError;
    }
  }
}

@JsonSerializable()
class NetError extends Error {
  @JsonKey(includeFromJson: false, includeToJson: false)
  NetCode code = NetCode.unknownError;
  @JsonKey(includeToJson: false, includeFromJson: false)
  String? message;
  String? exception;
  String? errorId;

  @override
  String toString() => message ?? exception ?? '';

  NetError();

  factory NetError.fromJson(Map<String, dynamic> json) {
    final error = _$NetErrorFromJson(json);
    if (json['messages'] is List<String>) {
      error.message = (json['messages'] as List<String>).firstOrNull ?? '';
    }
    return error;
  }
}

class FileUploadError extends Error {
  final String message;

  FileUploadError({required this.message});

  @override
  String toString() => '文件上传失败, 错误信息:\n$message';
}
