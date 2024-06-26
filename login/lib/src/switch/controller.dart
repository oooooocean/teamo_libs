import 'package:net/request_mixin.dart';
import 'package:net/simple_request_mixin.dart';
import 'package:get/get.dart';
import '../../../app/launcher.dart';
import '../../../components/widgets/edit_field_alert_view.dart';
import '../../../models/user/user.dart';
import '../../../routes/routes.dart';
import '../login_mixin.dart';

class UserListController extends GetxController
    with RequestMixin, SimpleRequestMixin, StateMixin<List<User>>, LoginMixin {
  List<User> get items => state!;

  @override
  void onReady() {
    getUserList();
    super.onReady();
  }

  getUserList() async {
    change(null, status: RxStatus.loading());

    var map = <String, dynamic>{};
    final store = Launcher().user?.store;
    if (store != null) {
      map["store_id"] = store.id;
    }

    final result = await get('users/', (data) {
      return (data as List<dynamic>).map((e) => User.fromJson(e)).toList();
    }, query:map);
    change(result, status: RxStatus.success());
  }

  /// 切换用户弹窗
  onTapChangeAccount(User user) async {
    final result = await Get.toNamed(
      AppRoute.editFieldAlert(),
      arguments:
      EditFieldAlertViewInput(hint: 'change login，Please enter the password for ${user.username}', maxCount: 8),
    );
    if (result == null) return;
    login(username: user.username, password: result);
  }
}
