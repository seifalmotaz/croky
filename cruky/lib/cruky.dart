import 'dart:async';
import 'dart:io';

import 'package:cruky/context/response.dart';
import 'package:cruky/pipeline.dart';

import 'context/request.dart';
import 'path/handler.dart';
import 'package:path/path.dart' as p;

class Server {
  final Pipeline _pipeline = Pipeline();
  final List<Path> _paths = [];

  Future requestHandler(Request req, Response resp, Handler next) async {
    Iterable<Path> matches = _paths.where((e) => e.pattern.match(req.uri.path));

    if (matches.isEmpty) {
      resp.status = 404;
      return;
    }
    await matches.first.call(req, resp);
  }

  use(Middleware f) => _pipeline.reqHandlers.add(f);

  void path(String route) {
    Path p = Path(route);
    _paths.add(p);
  }

  void static(String expose, String route) {
    Path path = Path(route.replaceAll('**', "<path:.+>"));
    _paths.add(path);

    handler(Request req, Response resp) async {
      String dir = p.join(expose, req.pathParams['path']);
      resp.sendFile(dir);
    }

    path.methods["ANY"] = PathMethod(
      [],
      handler: handler,
      acceptedContentType: [],
    );
  }

  void method(Handler handler, String method, [List<Middleware>? pipeline]) {
    if (_paths.isEmpty) throw "You did not add any path to the stack.";
    Path p = _paths.last;

    p.methods[method] = PathMethod(
      pipeline,
      handler: handler,
      acceptedContentType: [],
    );
  }

  void get(Handler handler, [List<Middleware>? pipeline]) {
    if (_paths.isEmpty) throw "You did not add any path to the stack.";
    Path p = _paths.last;

    p.methods['GET'] = PathMethod(
      pipeline,
      handler: handler,
      acceptedContentType: [],
    );
  }

  void post(Handler handler, [List<Middleware>? pipeline]) {
    if (_paths.isEmpty) throw "You did not add any path to the stack.";
    Path p = _paths.last;

    p.methods['POST'] = PathMethod(
      pipeline,
      handler: handler,
      acceptedContentType: [],
    );
  }

  Future<void> run() async {
    use(requestHandler);
    var server = await HttpServer.bind('127.0.0.1', 8080);
    server.autoCompress = true;
    server.idleTimeout = Duration(seconds: 30);
    // ignore: invalid_use_of_protected_member
    server.listen(_pipeline.handle);
  }
}
