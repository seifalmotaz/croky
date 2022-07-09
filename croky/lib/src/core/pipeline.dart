import 'package:croky/print_logs.dart';
import 'package:meta/meta.dart';

import '../context/request.dart';
import '../context/response.dart';
import '../err/http_exception.dart';

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

  /// init new [Pipeline] with logs printer middleware
  Pipeline.log()
      : reqHandlers = [printLogs],
        errHandlers = [printErrLogs];

  final List<Middleware> reqHandlers;
  final List<ErrMiddleware> errHandlers;

  void use<T>(T f) {
    if (f is Middleware) {
      reqHandlers.add(f);
      return;
    }
    if (f is ErrMiddleware) {
      errHandlers.add(f);
      return;
    }
    throw "This method is not type of `Middleware` or `ErrMiddleware`";
  }

  @internal
  @protected
  Future next(Request req, Response resp) async {
    int index = (req.read(#reqMiddlewareI) ?? 0) as int;
    req.set(index + 1, #reqMiddlewareI);
    var result = await reqHandlers[index](req, resp, next);
    return result;
  }

  @internal
  @protected
  Future errNext(Request req, Response resp, HTTPException e) async {
    int index = (req.read(#errMiddlewareI) ?? 0) as int;
    req.set(index + 1, #errMiddlewareI);
    var result = await errHandlers[index](req, resp, e, errNext);
    return result;
  }
}
