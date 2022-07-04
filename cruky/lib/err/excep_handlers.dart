import 'package:cruky/context/request.dart';
import 'package:cruky/context/response.dart';
import 'package:cruky/err/http_exception.dart';

abstract class ExceptionHandlers {
  /// 404 status code error
  notFound(Request req, Response resp, HTTPException exception);

  /// 500 status code error
  serverError(Request req, Response resp, HTTPException exception);
}
