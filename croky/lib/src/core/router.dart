import 'package:croky/src/common/mimetypes.dart';
import 'package:croky/src/context/request.dart';
import 'package:croky/src/context/response.dart';
import 'package:croky/src/path/handler.dart';
import 'package:croky/src/path/pattern.dart';
import 'package:croky/src/core/pipeline.dart';
import 'package:path/path.dart' as pp; // for path package

class Router {
  Router();
  final List<Path> _paths = [];
  List<Path> get paths => List<Path>.of(_paths);
  PathPrepare get p => PathPrepare(_paths.last);

  PathPrepare path(String route) {
    Path p = Path(route);
    _paths.add(p);
    return PathPrepare(p);
  }

  void mount(String prefix, Router router) {
    for (Path path in router._paths) {
      path.pattern = PathPattern.parse(pp.join(prefix, path.pattern.path));
      _paths.add(path);
    }
  }

  void static(String expose, String route) {
    Path path = Path(route.replaceAll('**', "<file_path:path>"));
    _paths.add(path);

    handler(Request req, Response resp) async {
      String dir = pp.join(expose, req.pathParams['file_path']);
      resp.sendFile(dir);
    }

    path.methods["ANY"] = PathMethod(
      [],
      handler: handler,
      acceptedContentType: [],
    );
  }
}

class MethodPrepare {
  final PathMethod _pathMethod;
  MethodPrepare(this._pathMethod);

  MethodPrepare use(Middleware f) {
    _pathMethod.reqHandlers.add(f);
    return this;
  }

  MethodPrepare uses(List<Middleware> f) {
    _pathMethod.reqHandlers.addAll(f);
    return this;
  }

  MethodPrepare accept(String type) {
    _pathMethod.acceptedContentType.add(type);
    return this;
  }

  MethodPrepare acceptJson() {
    _pathMethod.acceptedContentType.add(MimeTypes.json);
    return this;
  }

  MethodPrepare acceptUEF() {
    _pathMethod.acceptedContentType.add(MimeTypes.urlEncodedForm);
    return this;
  }

  MethodPrepare acceptForm() {
    _pathMethod.acceptedContentType.add(MimeTypes.multipartForm);
    return this;
  }
}

class PathPrepare {
  final Path _path;
  final List<Middleware> parentPipeline;
  PathPrepare(this._path) : parentPipeline = [];

  void use(Middleware f) => parentPipeline.add(f);
  void uses(List<Middleware> f) => parentPipeline.addAll(f);

  MethodPrepare on(String method, Handler handler,
      [List<Middleware>? pipeline, List<String>? acceptedContentType]) {
    var i = _path.methods[method] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare any(Handler handler,
      [List<Middleware>? pipeline, List<String>? acceptedContentType]) {
    var i = _path.methods['ANY'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare all(
    Handler handler, [
    List<Middleware>? pipeline,
    List<String>? acceptedContentType,
  ]) {
    var i = _path.methods['GET'] = _path.methods['POST'] =
        _path.methods['PUT'] = _path.methods['DELETE'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare get(
    Handler handler, [
    List<Middleware>? pipeline,
    List<String>? acceptedContentType,
  ]) {
    var i = _path.methods['GET'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare post(
    Handler handler, [
    List<Middleware>? pipeline,
    List<String>? acceptedContentType,
  ]) {
    var i = _path.methods['POST'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare put(
    Handler handler, [
    List<Middleware>? pipeline,
    List<String>? acceptedContentType,
  ]) {
    var i = _path.methods['PUT'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }

  MethodPrepare delete(
    Handler handler, [
    List<Middleware>? pipeline,
    List<String>? acceptedContentType,
  ]) {
    var i = _path.methods['DELETE'] = PathMethod(
      [...parentPipeline, ...?pipeline],
      handler: handler,
      acceptedContentType: acceptedContentType ?? [],
    );
    return MethodPrepare(i);
  }
}
