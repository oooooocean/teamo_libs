import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:net/request_mixin.dart';
import 'package:net/s3_mixin.dart';
import 'package:net/simple_request_mixin.dart';
import 'package:teamo_helper/components/mixins/take_photo_mixin.dart';
import 'login_mixin.dart';
import 'package:package_info_plus/package_info_plus.dart';


class LoginController extends GetxController with RequestMixin, SimpleRequestMixin, LoginMixin, TakePhotoMixin, S3Mixin {
  final usernameCtl = TextEditingController();
  final passwordCtl = TextEditingController();
  var version = ''.obs;

  @override
  void onReady() {
    getVersion();
    super.onReady();
  }

  startLogin() {
    if(usernameCtl.text.toString().isEmpty){
      EasyLoading.showToast("username is empty");
      return;
    }
    if(passwordCtl.text.toString().isEmpty){
      EasyLoading.showToast("password is empty");
      return;
    }
    login(username: usernameCtl.text, password: passwordCtl.text);
  }

  var fileName = 'test.jpeg'.obs;
  startTakePhone() async {
    final result = (await chosePhotos(maxCount: 1))?.first;
    if (result == null) return;
    final bytes = result.bytes;
    // final res = await uploadFiles([bytes], '/upload/', (data) => data); // res是path数组
    final fileName = await uploadFileToS3(fileName: await result.entity.titleAsync ?? '', bytes: bytes);
    if (fileName == null) return;
    this.fileName.value = fileName;
  }

  getVersion() async {
    PackageInfo.fromPlatform().then((value) => version.value = value.version);
  }

}
