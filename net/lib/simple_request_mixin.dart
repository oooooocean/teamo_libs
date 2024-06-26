import 'package:flutter/cupertino.dart';
import 'request_mixin.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

typedef RequestChecker = String? Function();

mixin SimpleRequestMixin on RequestMixin {
  Future<T?> request<T>({
    required ValueGetter<Future<T>> api,
    ValueSetter<T>? success,
    ValueSetter<Error>? fail,
    String? failTip,
  }) async {
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    }
    return api().then((value) {
      EasyLoading.dismiss();
      if (success != null) success(value);

      return value;
    }).catchError((error) {
      EasyLoading.dismiss();
      EasyLoading.showToast(failTip ?? error.toString());
      if (fail != null) fail(error);
      if (!const bool.fromEnvironment("dart.vm.product")) throw error;
    });
  }
}
