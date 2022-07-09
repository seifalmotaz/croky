import 'dart:io';
import 'package:croky/src/common/mimetypes.dart';
import 'package:croky/src/constants.dart';
import 'package:meta/meta.dart';
import 'dart:convert';

part './resp_writer.dart';

class Response {
  /// bare [HttpResponse]
  late final HttpResponse _httpResponse;

  /// response writer helper
  @protected
  ResponseWriter? writer;
  int status = 200;
  int get nativeStatus => _httpResponse.statusCode;

  /// function that will be run in the background when the response is closed
  Function()? _bgTask;
  bgTask(Function() task) => _bgTask = task;

  /// init new response
  Response(this._httpResponse);

  /// Returns the response [HttpHeaders].
  ///
  /// The response headers can be modified until the response body is
  /// written to or closed. After that they become immutable.
  HttpHeaders get headers => _httpResponse.headers;

  /// Gets information about the client connection. Returns `null` if the
  /// socket is not available.
  HttpConnectionInfo? get connectionInfo => _httpResponse.connectionInfo;

  /// Cookies to set in the client (in the 'set-cookie' header).
  List<Cookie> get cookies => _httpResponse.cookies;

  /// send a json content type response
  void send(String txt) => writer = TextResponse(txt);

  /// send a json content type response
  void sendJson(Map json) => writer = JsonResponse(json);

  /// send a html content type response
  void render(String htmlOrDir) => writer = HtmlResponse(htmlOrDir);

  /// send a file as stream
  void sendFile(String dir) => writer = FileStreamResponse(dir);
}
