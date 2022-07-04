import 'dart:io';

import 'package:cruky/context/request.dart';
import 'package:cruky/context/response.dart';
import 'package:cruky/err/http_exception.dart';
import 'package:cruky/pipeline.dart';

import 'pattern.dart';

class Path {
  final PathPattern pattern;
  final Map<String, PathMethod> methods = {};
  Path(String path) : pattern = PathPattern.parse(path);

  Future<void> call(Request req, Response resp) async {
    PathMethod? pathMethod = methods[req.method] ?? methods['ALL'];

    if (pathMethod == null) {
      resp.status = 405;
      resp.sendJson({"msg": "Method not allowed"});
      return;
    }

    if (req.contentType != null &&
        !pathMethod.acceptedContentType.contains(req.contentType?.mimeType)) {
      resp.status = 406;
      resp.sendJson({"msg": "Unsupported content type"});
      return;
    }

    return pathMethod.next(req, resp);
  }
}

class PathMethod extends Pipeline {
  final Handler handler;
  final List<String> acceptedContentType;
  PathMethod(
    super.handlers, {
    required this.handler,
    required this.acceptedContentType,
  });

  @override
  handle(HttpRequest httpRequest) async {}

  @override
  Future next(Request req, Response resp) async {
    int index = (req.read(#subReqMiddlewareI) ?? 0) as int;
    if (index <= (reqHandlers.length - 1)) {
      req.set(index + 1, #subReqMiddlewareI);
      var result = await reqHandlers[index](req, resp, next);
      return result;
    }
    // continue to the main handler
    return await handler(req, resp);
  }

  @override
  Future errNext(Request req, Response resp, HTTPException e) async {
    int index = (req.read(#subErrMiddlewareI) ?? 0) as int;
    req.set(index + 1, #subErrMiddlewareI);
    var result = await errHandlers[index](req, resp, e, errNext);
    return result;
  }
}
