import 'package:shelf/shelf.dart';

Middleware errorHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      var response = await innerHandler(request);
      return response;
    };
  };
}
