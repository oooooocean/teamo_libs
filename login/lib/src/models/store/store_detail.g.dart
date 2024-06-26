// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StoreDetail _$StoreDetailFromJson(Map<String, dynamic> json) => StoreDetail(
      (json['id'] as num).toInt(),
      (json['staffs'] as List<dynamic>)
          .map((e) => User.fromJson(e as Map<String, dynamic>))
          .toList(),
      (json['templates'] as List<dynamic>).map(Template.fromJson).toList(),
      json['name'] as String,
      json['createUser'] == null
          ? null
          : User.fromJson(json['createUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreDetailToJson(StoreDetail instance) =>
    <String, dynamic>{
      'id': instance.id,
      'staffs': instance.staffs,
      'templates': instance.templates,
      'name': instance.name,
      'createUser': instance.createUser,
    };
