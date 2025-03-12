import 'dart:convert';
import 'package:flare/src/services/user_service.dart';
import 'package:shelf/shelf.dart';

class UserController {
  final UserService _userService = UserService();
  Future<Response> getUserInfoHandler(Request request, String id) async {
    var user = await _userService.getUserInfo(int.parse(id));
    if (user == null) {
      return Response.notFound('User not found');
    }
    return Response.ok(jsonEncode(user.toJson), headers: {'Content-Type': 'application/json'});
  }
}
