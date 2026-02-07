import 'dart:convert';

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

class NetErrorEvent {
  final String method;
  final Uri uri;
  final Map<String, dynamic> headers;
  final dynamic requestBody;
  final int? statusCode;
  final dynamic responseBody;
  final String errorMessage;
  final DateTime timestamp;

  NetErrorEvent({
    required this.method,
    required this.uri,
    required this.headers,
    this.requestBody,
    this.statusCode,
    this.responseBody,
    required this.errorMessage,
    required this.timestamp,
  });

  @override
  String toString() => '''
[Net Error] $timestamp
$method $uri
Headers: ${json.encode(headers)}
Request Body: ${json.encode(requestBody)}
Status: $statusCode
Response: ${json.encode(responseBody)}
Error: $errorMessage''';
}

class FileUploadError extends Error {
  final String message;

  FileUploadError({required this.message});

  @override
  String toString() => '文件上传失败, 错误信息:\n$message';
}
