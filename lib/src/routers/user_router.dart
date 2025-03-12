import 'package:flare/src/controllers/user_controller.dart';
import 'package:shelf_router/shelf_router.dart';

class UserRouter {
  final UserController _userController = UserController();
  final Router _router = Router();

  Router router() {
    getUser();

    /// 这里可以添加更多路由
    return _router;
  }

  void getUser() {
    _router.get('/<id>', _userController.getUserInfoHandler);
  }
}
