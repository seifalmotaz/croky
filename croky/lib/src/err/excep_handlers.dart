import 'package:croky/src/context/request.dart';
import 'package:croky/src/context/response.dart';

import 'http_exception.dart';

abstract class ExceptionHandlers {
  /// 404 status code error
  notFound(Request req, Response resp, HTTPException exception);

  /// 500 status code error
  serverError(Request req, Response resp, HTTPException exception);
}
