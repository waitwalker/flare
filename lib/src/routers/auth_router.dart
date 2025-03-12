import 'package:flare/src/controllers/auth_controller.dart';
import 'package:shelf_router/shelf_router.dart';

class AuthRouter {
  final Router _router = Router();
  final AuthController _authController = AuthController();

  Router getAuthRouter() {
    callHandle();
    return _router;
  }

  void callHandle() {
    _handleVerifyCodeRoute();
  }

  void _handleVerifyCodeRoute() {
    _router.post('/verify/mobile/code', _authController.getVerifyMobileCode);
  }
}
