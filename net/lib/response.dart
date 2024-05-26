import 'package:json_annotation/json_annotation.dart';

part 'response.g.dart';

enum NetCode {
  @JsonValue(0)
  success,
  @JsonValue(400)
  clientError,
  @JsonValue(401)
  authFail,
  @JsonValue(-1)
  unknownError;

  bool get shouldRelaunch => [NetCode.authFail].contains(this);
}

class NetError extends Error {
  String message = '';

  @override
  String toString() => message;
}

@JsonSerializable()
class NetResponse extends NetError {
  @JsonKey(unknownEnumValue: NetCode.unknownError)
  NetCode code;
  dynamic data;

  NetResponse(this.code, this.data);

  factory NetResponse.fromJson(Map<String, dynamic> json) => _$NetResponseFromJson(json);

  Map<String, dynamic> toJson() => _$NetResponseToJson(this);
}

class FileUploadError extends Error {
  final String message;

  FileUploadError({required this.message});

  @override
  String toString() => '文件上传失败, 错误信息:\n$message';
}
