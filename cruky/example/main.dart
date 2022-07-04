import 'dart:math';

import 'package:cruky/context/request.dart';
import 'package:cruky/context/response.dart';
import 'package:cruky/cruky.dart';
import 'package:cruky/pipeline.dart';

void main() {
  Server server = Server();
  server.use(middlewareExample);

  server.path('/my/path');
  server.get(example, [subMiddlewareExample]);

  server.static('./lib', '/static/**');

  server.run();
}

Future<void> example(req, resp) async {
  print('Main request handler');
  String str = '';
  for (var i = 0; i < 10; i++) {
    str += String.fromCharCode(Random().nextInt(255));
  }
  resp.send(str);
}

Future<void> middlewareExample(Request req, Response resp, Handler next) async {
  print('main middleware example: Start');
  await next(req, resp);
  print('main middleware example: End');
}

Future<void> subMiddlewareExample(
    Request req, Response resp, Handler next) async {
  print('sub middleware example: Start');
  await next(req, resp);
  print('sub middleware example: End');
}
