import 'dart:convert';
import 'package:net/simple_request_mixin.dart';
import 'package:teamo_helper/app/launcher.dart';
import '../../app/store.dart';
import '../../models/user/user.dart';

mixin LoginMixin on SimpleRequestMixin {
  login({required String username, required String password}) {
    request(
      api: () => post('user/login/', {'username': username, 'password': password}, (data) {
        final token = data['accessToken'];
        final user = User.fromJson(data['user']);
        StoreService.token.save(token);
        StoreService.user.save(const JsonEncoder().convert(data['user']));
        return (user, token);
      }),
      success: (data) {
        Launcher().login(data.$1, data.$2);
      },
    );
  }
}
