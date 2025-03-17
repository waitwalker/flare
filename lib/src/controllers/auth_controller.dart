import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flare/config/jwt_config.dart';
import 'package:flare/src/repositories/auth_repository.dart';
import 'package:phone_numbers_parser/phone_numbers_parser.dart';
import 'package:shelf/shelf.dart';

enum AuthType {
  apple('apple'),
  google('google'),
  facebook('facebook'),
  line('line'),
  kakao('kakao'),
  wechat('wechat'),
  email('email'),
  mobile('mobile'),
  accountName('account_name');

  final String value;

  const AuthType(this.value);
}

class AuthController {
  final AuthRepository _authRepository = AuthRepository();

  /// 获取验证码
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
            String msg = result == 0 ? "获取成功" : "验证码未过期，请稍后重新获取";
            return Response.ok(jsonEncode({'code': 0, 'message': msg, 'data': null}));
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

  Future<Response> issueToken(Request request, String type) async {
    if (type == AuthType.mobile.value) {
      return Response.ok(jsonEncode({'code': 400}));
    } else {
      return Response.notFound(jsonEncode({'code': 404, 'data': 'not found'}));
    }
  }

  String _generateAccessToken(String phone) {
    final jwt = JWT({
      'sub': phone,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
    });
    return jwt.sign(SecretKey(jwtSecret));
  }

  String _generateRefreshToken(String phone) {
    final jwt = JWT({
      'sub': phone,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(days: 7)).millisecondsSinceEpoch ~/ 1000,
    });
    return jwt.sign(SecretKey(jwtSecret));
  }
}
