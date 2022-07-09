// ignore_for_file: invalid_use_of_protected_member

import 'dart:io';

import 'package:croky/src/context/request.dart';
import 'package:croky/src/context/response.dart';
import 'package:croky/src/core/router.dart';
import 'package:croky/src/err/http_exception.dart';
import 'package:croky/src/path/handler.dart';
import 'package:croky/src/core/pipeline.dart';

startServer(Pipeline pipeline, Router router) async {
  final List<Path> paths = router.paths;

  Future onReq(Request req, Response resp, Handler next) async {
    Iterable<Path> matches = paths.where((e) => e.pattern.match(req.uri.path));

    if (matches.isEmpty) {
      resp.status = 404;
      return;
    }
    await matches.first.call(req, resp);
  }

  Future onErr(
    Request req,
    Response resp,
    HTTPException e,
    ErrHandler next,
  ) async {
    resp.status = e.status;
    resp.sendJson({
      "title": e.title,
      if (e.details != null) "details": e.details,
      if (e.stackTrace != null) "stack_trace": e.stackTrace,
    });
  }

  pipeline.use(onReq);
  pipeline.use(onErr);

  var server = await HttpServer.bind('127.0.0.1', 8080);
  server.autoCompress = true;
  server.idleTimeout = Duration(seconds: 30);

  await for (HttpRequest httpRequest in server) {
    late final Request request;
    late final Response response;
    try {
      request = Request(httpRequest);
      response = Response(httpRequest.response);
    } catch (e, stackTrace) {
      if (e is HTTPException) {
        e.stackTrace = stackTrace;
        await pipeline.errNext(request, response, e);
        return;
      }
      print(e);
      print(stackTrace);
    }

    try {
      await pipeline.next(request, response);
    } catch (e, stackTrace) {
      if (e is HTTPException) {
        try {
          e.stackTrace = stackTrace;
          await pipeline.errNext(request, response, e);
          return;
        } catch (e) {
          response.status = 500;
        }
      }
      print(e);
      print(stackTrace);
    }

    response.write(httpRequest);
  }
}
