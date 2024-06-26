import 'package:get/get.dart';
import 'package:teamo_helper/modules/login/page.dart';
import '../../routes/routes.dart';
import 'change_account/controller.dart';
import 'change_account/page.dart';
import 'controller.dart';

final loginRoutes = [
  GetPage(
      name: AppRoute.login(),
      page: () => const LoginPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => LoginController()))),
  GetPage(
      name: AppRoute.userListPage(),
      page: () => const UserListPage(),
      binding: BindingsBuilder(() => Get.lazyPut(() => UserListController()))),

];