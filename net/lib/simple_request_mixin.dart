import 'package:flutter/cupertino.dart';
import 'request_mixin.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

typedef RequestChecker = String? Function();

mixin SimpleRequestMixin on RequestMixin {
  Future<T?> request<T>({
    required ValueGetter<Future<T>> api,
    ValueSetter<T>? success,
    ValueSetter<Error>? fail,
    bool showSuccessTip = true,
    String? failTip,
  }) async {
    var needDismissByThisSession = true;
    if (!EasyLoading.isShow) {
      EasyLoading.show();
    } else {
      // 此时弹窗已经由其他业务弹出来了, 这里就不需要处理dismiss, 否则会导致其他业务页面弹框不正常
      needDismissByThisSession = false;
    }
    return api().then((value) async {
      if (showSuccessTip) {
        EasyLoading.showSuccess('Success');
      } else if (needDismissByThisSession) {
        await EasyLoading.dismiss();
      }
      if (success != null) success(value);
      return value;
    });
  }
}
