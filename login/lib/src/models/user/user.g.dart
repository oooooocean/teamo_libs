// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      (json['id'] as num).toInt(),
      json['username'] as String,
      $enumDecode(_$UserRoleEnumMap, json['role']),
      json['permissions'] as String?,
      json['email'] as String?,
      json['store'] == null
          ? null
          : Store.fromJson(json['store'] as Map<String, dynamic>),
      (json['manageStores'] as List<dynamic>?)
          ?.map((e) => Store.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'role': _$UserRoleEnumMap[instance.role]!,
      'permissions': instance.permissions,
      'email': instance.email,
      'store': instance.store,
      'manageStores': instance.manageStores,
    };

const _$UserRoleEnumMap = {
  UserRole.admin: 0,
  UserRole.manager: 1,
  UserRole.staff: 2,
};
