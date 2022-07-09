import 'dart:math';

import 'package:cruky/cruky.dart';

void main() {
  Router router = Router();
  Pipeline pipeline = Pipeline.log();

  router.path('/example/')
    ..get(example).use(subMiddlewareExample).acceptJson()
    ..post((req, resp) => resp.send("Hello World!"));

  startServer(pipeline, router);
}

Future<void> example(Req req, Resp resp) async {
  print('Main request handler');
  String str = '';
  for (var i = 0; i < 10; i++) {
    str += String.fromCharCode(Random().nextInt(255));
  }
  resp.sendJson({"random str": str});
}

Future<void> middlewareExample(Req req, Resp resp, Handler next) async {
  print('main middleware example: Start');
  await next(req, resp);
  print('main middleware example: End');
}

Future<void> subMiddlewareExample(Req req, Resp resp, Handler next) async {
  print('sub middleware example: Start');
  await next(req, resp);
  print('sub middleware example: End');
}
