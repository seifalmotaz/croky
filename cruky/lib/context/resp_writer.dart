part of './response.dart';

extension RespWriter on Response {
  Future<void> write(HttpRequest httpRequest) async {
    // ignore: invalid_use_of_protected_member
    var httpResponse = httpRequest.response;
    if (writer == null) {
      httpResponse.statusCode = 200;
      httpResponse.close();
      return;
    }

    prepareWriter(httpResponse);
    await writer!.writeResp();
    httpResponse.close();
    if (_bgTask != null) _bgTask!();
  }

  void prepareWriter(HttpResponse httpResponse) {
    writer!.redirect = httpResponse.redirect;
    writer!.add = httpResponse.add;
    writer!.addStream = httpResponse.addStream;

    writer!.write = httpResponse.write;
    writer!.writeAll = httpResponse.writeAll;
    writer!.writeln = httpResponse.writeln;

    writer!.headers = httpResponse.headers;
    writer!.connectionInfo = httpResponse.connectionInfo;
    writer!.cookies = httpResponse.cookies;
    writer!.setStatus = (int i) => status = i;
  }
}

/// response manipulator/writer to help developers write responses faster.
///
/// You can use [JsonResponse] to return json response, [HtmlResponse] for html file, ...etc
abstract class ResponseWriter {
  late final HttpHeaders headers;
  late final List<Cookie> cookies;
  late Function(List<int> data) add;
  late Function(Object? object) write;
  late Function([Object? object]) writeln;
  late final HttpConnectionInfo? connectionInfo;
  late Function(Stream<List<int>> stream) addStream;
  late Function(Iterable objects, [String separator]) writeAll;
  late Function(Uri location, {int status}) redirect;
  late Function(int status) setStatus;

  Future<void> writeResp();
}

/// [ResponseWriter] type to redirect the user
class RedirectResponse extends ResponseWriter {
  final String url;
  RedirectResponse(this.url);
  @override
  Future<void> writeResp() async {
    if (url.startsWith("^")) {
      var path = pathNames[url.substring(2)];
      if (path == null) {
        print("Did not find path `$path` for redirect response");
        return;
      }
      redirect(Uri.parse(path));
    }
    redirect(Uri.parse(url));
  }
}

/// [ResponseWriter] type to send plain text response
class TextResponse extends ResponseWriter {
  final String body;
  TextResponse(this.body);
  @override
  Future<void> writeResp() async {
    headers.contentType = ContentType.text;
    write(body);
  }
}

/// [ResponseWriter] type to send json response
class JsonResponse extends ResponseWriter {
  final Map body;
  JsonResponse(this.body);
  @override
  Future<void> writeResp() async {
    headers.contentType = ContentType.json;
    write(jsonEncode(body));
  }
}

/// [ResponseWriter] type to send html response
class HtmlResponse extends ResponseWriter {
  final String htmlOrDir;
  HtmlResponse(this.htmlOrDir);

  @override
  Future<void> writeResp() async {
    if (htmlOrDir.startsWith("<")) {
      headers.contentType = ContentType.html;
      await write(htmlOrDir);
      return;
    }
    File file = File(htmlOrDir);
    headers.contentType = ContentType.html;
    await addStream(file.openRead());
  }
}

/// [ResponseWriter] type to send file stream response
class FileStreamResponse extends ResponseWriter {
  final String dir;
  FileStreamResponse(this.dir);

  @override
  Future<void> writeResp() async {
    File file = File(dir);
    if (!(await file.exists())) {
      setStatus(404);
      headers.contentType = ContentType.text;
      write("File not found");
      return;
    }
    String? mimetype = MimeTypes.ofFile(file);
    if (mimetype != null) {
      List list = mimetype.split('/');
      headers.contentType = ContentType(list.first, list.last);
    } else {
      headers.contentType = ContentType.binary;
    }
    await addStream(file.openRead());
  }
}

/// [ResponseWriter] type to send streamed data response
class StreamResponse extends ResponseWriter {
  final Stream<List<int>> stream;
  StreamResponse(this.stream);

  @override
  Future<void> writeResp() async {
    await addStream(stream);
  }
}
