import 'package:json_annotation/json_annotation.dart';
import 'package:teamo_helper/models/base/id_name.dart';

import '../../components/mixins/selectable_mixin.dart';
import '../user/user.dart';

part 'store.g.dart';

@JsonSerializable()
class Store extends IdName with SelectableMixin{
  final int staffs;
  final int templates;
  final User? createUser;

  Store(super.id, this.staffs, this.templates, super.name, this.createUser);

  factory Store.fromJson(Map<String, dynamic> json) =>
      _$StoreFromJson(json);
}
