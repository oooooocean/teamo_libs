import 'package:json_annotation/json_annotation.dart';
import 'package:teamo_helper/models/store/store.dart';

import '../base/id_name.dart';
import '../template/template.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue(0)
  admin,
  @JsonValue(1)
  manager,
  @JsonValue(2)
  staff;

  String get name {
    switch (this) {
      case UserRole.admin:
        return 'admin';
      case UserRole.manager:
        return 'manager';
      case UserRole.staff:
        return 'staff';
    }
  }
}

@JsonSerializable()
class User {
  final int id;
  final String username;
  final UserRole role;
  final String? permissions; //0添加模版 1 添加员工 2 删除员工 3 审核task
  final String? email;
  final Store? store;
  final List<Store>? manageStores;

  User(this.id, this.username, this.role, this.permissions, this.email, this.store, this.manageStores);

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  bool hasDeleteStore() {
    if (role == UserRole.admin) {
      return true;
    }

    return false;
  }
  bool hasDeleteTemplate() {
    if (role == UserRole.admin) {
      return true;
    }

    return false;
  }

  bool hasAddTemplate() {
    if (role == UserRole.admin) {
      return true;
    }
    if (role == UserRole.staff) {
      return false;
    }
    return permissions != null && permissions!.contains("0");
  }

  bool hasAddUser() {
    if (role == UserRole.admin) {
      return true;
    }
    if (role == UserRole.staff) {
      return false;
    }
    return permissions != null && permissions!.contains("1");
  }

  bool hasDeleteUser() {
    if (role == UserRole.admin) {
      return true;
    }
    if (role == UserRole.staff) {
      return false;
    }
    return permissions != null && permissions!.contains("2");
  }

  bool hasAuditCheckTask() {
    if (role == UserRole.admin) {
      return true;
    }
    if (role == UserRole.staff) {
      return false;
    }
    return permissions != null && permissions!.contains("3");
  }
}
