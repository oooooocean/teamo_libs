import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../components/widgets/delete_widget.dart';
import '../../../../models/user/user.dart';
import '../../../../utils/colors.dart';

class ItemUser extends StatelessWidget {
  final User user;
  final ValueSetter<User> onTap;
  final ValueSetter<User>? onDelete;

  const ItemUser({Key? key, required this.user, required this.onTap, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (onDelete == null) {
      return InkWell(
        onTap: () => onTap(user),
        child: _bodyContainer,
      );
    }

    return InkWell(
      onTap: () => onTap(user),
      child: DeleteButtonWidget(
        onDelete: () => onDelete!(user),
        child: _bodyContainer,
      ),
    );
  }

  Widget get _bodyContainer {
    // 生成一个0到4的随机数
    int randomNumber = Random().nextInt(5);
    return Container(
      decoration: BoxDecoration(color: Palette.colorBg[randomNumber].$1, borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            user.username,
            style: TextStyle(fontSize: 16, color: Palette.colorBg[randomNumber].$2, fontWeight: FontWeight.w600),
          ),
          Text(
            user.role.name,
            style: TextStyle(fontSize: 16, color: Palette.colorBg[randomNumber].$2, fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
