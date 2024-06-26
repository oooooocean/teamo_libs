// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'store.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Store _$StoreFromJson(Map<String, dynamic> json) => Store(
      (json['id'] as num).toInt(),
      (json['staffs'] as num).toInt(),
      (json['templates'] as num).toInt(),
      json['name'] as String,
      json['createUser'] == null
          ? null
          : User.fromJson(json['createUser'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StoreToJson(Store instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'staffs': instance.staffs,
      'templates': instance.templates,
      'createUser': instance.createUser,
    };
