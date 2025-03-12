import 'package:shelf/shelf.dart';

Middleware loggerHandler() {
  return (Handler innerHandler) {
    return (Request request) async {
      String method = request.method;
      String body = '';
      String requestFormat =
          '\n==================================== request start ==================================== \n'
          'time       = ${DateTime.fromMillisecondsSinceEpoch(DateTime.now().millisecondsSinceEpoch)}, \n'
          'path       = ${request.requestedUri}, \n'
          'method     = $method, \n'
          'headers    = ${request.headers}， \n';
      switch (method) {
        case 'GET':
          requestFormat += 'parameters = ${request.url.query}';
          break;
        case 'DELETE':
          requestFormat += 'parameters = ${request.url.query}';
          break;
        case 'POST':
          body = await request.readAsString();
          requestFormat += 'parameters = $body';
          break;
        case 'PUT':
          requestFormat += 'parameters = ${request.url.query}';
          break;
      }
      requestFormat += '\n===================================== request end ===================================== \n';
      print(requestFormat);
      Request modifiedRequest = request.change(context: {'body': body});

      Response response = await innerHandler(modifiedRequest);
      String responseBody = await response.readAsString();
      String responseFormat =
          '==================================== response start ==================================== \n'
          'statusCode = ${response.statusCode}, \n'
          'headers    = ${response.headers}, \n'
          'body       = $responseBody, '
          '\n===================================== response end ===================================== \n';
      print(responseFormat);
      return response.change(body: responseBody);
    };
  };
}
