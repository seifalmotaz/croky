import 'dart:io';

import 'package:meta/meta.dart';

import 'context/request.dart';
import 'context/response.dart';
import 'err/http_exception.dart';

/// prefiusly called [NextHandler]
typedef Handler = Function(Request req, Response resp);

/// prefiusly called [NextErrHandler]
typedef ErrHandler = Function(
  Request req,
  Response resp,
  HTTPException e,
);

/// prefiusly called [MiddlewareHandler]
typedef Middleware = Function(
  Request req,
  Response resp,
  Handler next,
);

/// prefiusly called [ErrMiddlewareHandler]
typedef ErrMiddleware = Function(
  Request req,
  Response resp,
  HTTPException e,
  ErrHandler next,
);

class Pipeline {
  /// init new [Pipeline]
  Pipeline([List<Middleware>? h, List<ErrMiddleware>? eh])
      : reqHandlers = h ?? [],
        errHandlers = eh ?? [];

  final List<Middleware> reqHandlers;
  final List<ErrMiddleware> errHandlers;

  void use<T>(T f) {
    if (f is Middleware) {
      reqHandlers.add(f);
      return;
    }
    f as ErrMiddleware;
    errHandlers.add(f);
  }

  @protected
  handle(HttpRequest httpRequest) async {
    late final Request request;
    late final Response response;
    try {
      request = Request(httpRequest);
      response = Response(httpRequest.response);
    } catch (e, stackTrace) {
      if (e is HTTPException) {
        e.stackTrace = stackTrace;
        await errNext(request, response, e);
        return;
      }
      print(e);
      print(stackTrace);
    }

    try {
      await next(request, response);
    } catch (e, stackTrace) {
      if (e is HTTPException) {
        e.stackTrace = stackTrace;
        await errNext(request, response, e);
        return;
      }
      print(e);
      print(stackTrace);
    }

    response.write(httpRequest);
  }

  @protected
  Future next(Request req, Response resp) async {
    int index = (req.read(#reqMiddlewareI) ?? 0) as int;
    req.set(index + 1, #reqMiddlewareI);
    var result = await reqHandlers[index](req, resp, next);
    return result;
  }

  @protected
  Future errNext(Request req, Response resp, HTTPException e) async {
    int index = (req.read(#errMiddlewareI) ?? 0) as int;
    req.set(index + 1, #errMiddlewareI);
    var result = await errHandlers[index](req, resp, e, errNext);
    return result;
  }
}
