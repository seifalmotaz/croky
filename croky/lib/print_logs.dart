import 'package:croky/src/context/request.dart';
import 'package:croky/src/context/response.dart';
import 'package:croky/src/core/pipeline.dart';
import 'package:croky/src/err/http_exception.dart';

Future printLogs(Request req, Response resp, Handler next) async {
  var dateTime = DateTime.now();
  var result = await next(req, resp);
  print("[$dateTime] ${req.client?.remoteAddress.host} "
      "${req.method} ${req.uri.path} => ${resp.nativeStatus}");
  return result;
}

Future printErrLogs(
  Request req,
  Response resp,
  HTTPException e,
  ErrHandler next,
) async {
  var dateTime = DateTime.now();
  var result = await next(req, resp, e);
  print("[$dateTime] ${req.client?.remoteAddress.host} "
      "${req.method} ${req.uri.path} => ${resp.nativeStatus}");
  return result;
}
