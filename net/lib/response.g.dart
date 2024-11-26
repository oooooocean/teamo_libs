// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetError _$NetErrorFromJson(Map<String, dynamic> json) => NetError()
  ..exception = json['exception'] as String?
  ..errorId = json['errorId'] as String?;

Map<String, dynamic> _$NetErrorToJson(NetError instance) => <String, dynamic>{
      'exception': instance.exception,
      'errorId': instance.errorId,
    };
