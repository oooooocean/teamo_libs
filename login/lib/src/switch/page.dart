import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:teamo_helper/components/widgets/empty_view.dart';
import 'controller.dart';
import 'widgets/item_user.dart';

class UserListPage extends GetView<UserListController> {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Change Login User')),
      body: controller.obx(
        (state) => _list,
        onLoading: const Center(child: CupertinoActivityIndicator()),
      ),
    );
  }

  get _list => controller.items.isEmpty
      ? const EmptyView()
      : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 10.0,
            childAspectRatio: 1.0,
          ),
          itemCount: controller.items.length,
          itemBuilder: _itemBuilder,
          padding: const EdgeInsets.all(10.0),
        );

  Widget _itemBuilder(BuildContext context, int index) {
    final user = controller.items[index];
    return ItemUser(user: user, onTap: controller.onTapChangeAccount);
  }


}
