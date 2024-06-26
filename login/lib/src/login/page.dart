import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:net/s3_mixin.dart';
import 'package:teamo_helper/app/env.dart';
import 'package:teamo_helper/modules/login/controller.dart';
import '../../components/mixins/keyboard_manage_mixin.dart';

class LoginPage extends StatelessWidget with KeyboardManageMixin, S3Mixin {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LoginController(),
      builder: (ctl) => Scaffold(
        body: GestureDetector(
          onTap: unFocus,
          behavior: HitTestBehavior.opaque,
          child: _bodyReality(ctl),
        ),
      ),
    );
  }

  Widget _bodyReality(LoginController ctl) => Center(
        child: SizedBox(
            width: 500,
            child: ListView(
              children: [
                const SizedBox(
                  height: 100,
                ),
                TextField(
                  controller: ctl.usernameCtl,
                  decoration: const InputDecoration(hintText: 'enter username'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: ctl.passwordCtl,
                  decoration: const InputDecoration(hintText: 'enter password'),
                  textInputAction: TextInputAction.done,
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: unFocusDecoratorForVoidCallback(ctl.startLogin),
                  style: ButtonStyle(fixedSize: MaterialStatePropertyAll(Size.fromWidth(Get.width))),
                  child: const Text('Login'),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Obx(() => Text("V${ctl.version} Env: ${currentEnvironment.name}")),
                ),
              ],
            )),
      );
}
