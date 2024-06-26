import 'package:json_annotation/json_annotation.dart';
import 'package:teamo_helper/models/user/user.dart';

import '../template/template.dart';

part 'store_detail.g.dart';

@JsonSerializable()
class StoreDetail {
  final int id;
  final List<User> staffs;
  final List<Template> templates;
  final String name;
  final User? createUser;

  StoreDetail(this.id, this.staffs, this.templates, this.name, this.createUser);

  factory StoreDetail.fromJson(Map<String, dynamic> json) => _$StoreDetailFromJson(json);
}
