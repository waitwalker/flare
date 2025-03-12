import 'dart:convert';

import 'package:flare/src/repositories/auth_repository.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shelf/shelf.dart';

class AuthController {
  final AuthRepository _authRepository = AuthRepository();

  Future<Response> getVerifyMobileCode(Request request) async {
    try {
      String body = '${request.context['body']}';
      if (body.isNotEmpty) {
        Map<String, dynamic>? bodyMap = jsonDecode(body);
        if (bodyMap != null && bodyMap['mobile'] != null && bodyMap['mobile'].runtimeType == int) {
          bool isValid = PhoneNumber.parse('${bodyMap['mobile']}', callerCountry: IsoCode.CN).isValid();
          if (!isValid) {
            return Response(400, body: jsonEncode({'code': 400, 'message': '请检查参数名称或者类型等按要求填写'}));
          }
          int? result = await _authRepository.findVerifyCodeByMobile(bodyMap['mobile']);
          if (result != null) {
            return Response.ok(jsonEncode({'code': 0, 'message': 'success', 'data': '获取成功'}));
          } else {
            return Response.ok(jsonEncode({'code': 500, 'message': 'success', 'data': 'Server Interval Error'}));
          }
        } else {
          return Response(400, body: jsonEncode({'code': 400, 'message': '请检查参数名称或者类型等按要求填写'}));
        }
      } else {
        return Response(400, body: jsonEncode({'code': 400, 'message': '参数不对'}));
      }
    } catch (e) {
      print("server interval error = $e");
      rethrow;
    }
  }
}
