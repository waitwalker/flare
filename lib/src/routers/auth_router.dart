import 'package:flare/src/constant/route_path.dart';
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
    _handleIssueTokenRoute();
  }

  void _handleVerifyCodeRoute() {
    _router.post(verifyMobileCode, _authController.getVerifyMobileCode);
  }

  void _handleIssueTokenRoute() {
    _router.post(issueToken, _authController.issueToken);
  }
}
