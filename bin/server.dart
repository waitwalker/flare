import 'dart:io';
import 'package:flare/src/constant/route_path.dart';
import 'package:flare/src/database/database_connection.dart';
import 'package:flare/src/middleware/log_middleware.dart';
import 'package:flare/src/routers/auth_router.dart';
import 'package:flare/src/routers/user_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';
import 'package:shelf_router/shelf_router.dart';

void main(List<String> args) async {
  var mainRouter =
      Router()
        ..mount(authRoutePrefix, AuthRouter().getAuthRouter().call)
        ..mount(userRoutePrefix, UserRouter().router().call);

  var handler = Pipeline().addMiddleware(loggerHandler()).addHandler(mainRouter.call);
  try {
    await DatabaseConnection.initialize();
  } catch (e) {
    print('data pool init error = $e');
  }
  HttpServer server = await serve(handler, InternetAddress.anyIPv4, 8080);
  print('Server running on ${server.address}:${server.port}');
}
