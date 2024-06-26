import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:teamo_helper/app/store.dart';
import 'package:teamo_helper/models/user/user.dart';
import 'package:teamo_helper/routes/routes.dart';
import 'package:teamo_helper/services/net_service.dart';

class Launcher {
  static final _instance = Launcher._();

  Launcher._();

  factory Launcher() => Launcher._instance;

  User? user;

  bool get isLogin => user != null;

  final services = [NetService()];

  Future<String> init() async {
    final userJson = await StoreService.user.get();
    if (userJson != null) {
      user = User.fromJson(const JsonDecoder().convert(userJson));
    }

    _launchServices();

    return isLogin ? AppRoute.scaffold() : AppRoute.login();
  }

  login(User user, String token) async {
    this.user = user;
    _launchServices();
    Get.offAllNamed(AppRoute.scaffold());
  }

  logout() async {
    await SharedPreferences.getInstance().then((value) => value.clear());
    Get.offAllNamed(AppRoute.login());
  }

  _launchServices() async {
    for (final service in services) {
      if (service.needLogin && !isLogin) continue;

      if (service.syncExecute) {
        await service.executeInit();
      } else {
        unawaited(service.executeInit());
      }

      if (!service.permanent) {
        Future.delayed(Duration.zero, () => services.remove(service)); // prevent repetitive loading
      }
    }
  }
}
