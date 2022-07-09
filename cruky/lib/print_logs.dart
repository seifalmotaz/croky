import 'package:cruky/src/context/request.dart';
import 'package:cruky/src/context/response.dart';
import 'package:cruky/src/core/pipeline.dart';
import 'package:cruky/src/err/http_exception.dart';

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
