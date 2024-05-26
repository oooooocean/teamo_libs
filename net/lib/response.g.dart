// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NetResponse _$NetResponseFromJson(Map<String, dynamic> json) => NetResponse(
      $enumDecode(_$NetCodeEnumMap, json['code'],
          unknownValue: NetCode.unknownError),
      json['data'],
    )..message = json['message'] as String;

Map<String, dynamic> _$NetResponseToJson(NetResponse instance) =>
    <String, dynamic>{
      'message': instance.message,
      'code': _$NetCodeEnumMap[instance.code]!,
      'data': instance.data,
    };

const _$NetCodeEnumMap = {
  NetCode.success: 0,
  NetCode.clientError: 400,
  NetCode.authFail: 401,
  NetCode.unknownError: -1,
};
