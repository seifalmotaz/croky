import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:croky/src/common/mimetypes.dart';
import 'package:croky/src/common/string_converter.dart';
import 'package:croky/src/err/http_exception.dart';
import 'package:mime/mime.dart';

part './form_data.dart';
part './query.dart';

class Request {
  /// native [HttpRequest] class from the stream listener
  final HttpRequest _httpRequest;

  /// request query
  final QueryParameters query;

  /// request path parameters
  final Map<String, dynamic> pathParams = {};

  /// request method
  String get method => _httpRequest.method;

  /// request uri
  Uri get uri => _httpRequest.uri;

  /// request headers content type
  ContentType? get contentType => _httpRequest.headers.contentType;

  /// request session
  HttpSession get session => _httpRequest.session;

  /// request client info
  HttpConnectionInfo? get client => _httpRequest.connectionInfo;

  /// [HttpRequest] headers
  HttpHeaders get headers => _httpRequest.headers;

  /// request manipulating helper
  Request(this._httpRequest) : query = QueryParameters(_httpRequest.uri);

  /// data that passed from the middleware/dependancies
  final Map<Object, Object> _state = {};
  read<T>([Object? tag]) {
    if (tag != null) {
      return _state[tag] as T;
    }
    return _state[T];
  }

  void set<T>(dynamic data, [Object? tag]) {
    if (tag != null) {
      _state[tag] = data;
      return;
    }
    _state[T] = data;
  }

  /// Upgrades a [HttpRequest] to a [WebSocket] connection
  Future<WebSocket> upgrade({
    Function(List<String>)? protocolSelector,
    CompressionOptions compression = CompressionOptions.compressionDefault,
  }) async =>
      await WebSocketTransformer.upgrade(
        _httpRequest,
        protocolSelector: protocolSelector,
        compression: compression,
      );

  /// Get the body of the request as [Uint8List]
  Future<Uint8List> body() async {
    BytesBuilder bytesBuilder = await _httpRequest.fold<BytesBuilder>(
        BytesBuilder(copy: false), (a, b) => a..add(b));
    return bytesBuilder.takeBytes();
  }

  /// Get the body of the request as [Stream] of [Uint8List].
  ///
  /// Preferred to use if the content is to long like file or something.
  Stream<Uint8List> bodyStream() {
    return _httpRequest.asBroadcastStream();
  }

  /// covert request body to json/map it can return map or list
  Future json() async {
    String string = await utf8.decodeStream(_httpRequest);
    var body = string.isEmpty ? {} : jsonDecode(string);
    return body;
  }

  /// covert the form data to [FormData] class that contains the fields and the files if exist
  Future<FormData> form([Function()? onContentTypeError]) async {
    if (contentType?.mimeType == MimeTypes.urlEncodedForm) {
      return await _form();
    } else if (contentType?.mimeType == MimeTypes.multipartForm) {
      return await _multipartForm();
    }
    if (onContentTypeError != null) {
      onContentTypeError();
      return FormData({}, {});
    }
    throw HTTPException(415, "Cannot decode the body of the request");
  }

  /// covert request body to form data
  Future<FormData> _form() async {
    var bytes = await body();
    Map<String, List<String>> value = String.fromCharCodes(bytes).splitQuery();
    return FormData(value, {});
  }

  /// covert request body to multipart form data
  Future<FormData> _multipartForm() async {
    final Map<String, List<String>> formFields = {};
    final Map<String, List<FilePart>> formFiles = {};

    Stream<Uint8List> stream = bodyStream();

    if (contentType == null) {
      throw HTTPException(415, '');
    }
    if (contentType!.parameters['boundary'] == null) {
      throw HTTPException(400, "`boundary` not found in headers");
    }

    late Stream<MimeMultipart> parts;
    try {
      parts = MimeMultipartTransformer(contentType!.parameters['boundary']!)
          .bind(stream);
    } catch (e) {
      throw HTTPException(400, e.toString());
    }

    await for (MimeMultipart part in parts) {
      Map<String, String?> parameters;
      {
        final String contentDisposition = part.headers['content-disposition']!;
        parameters = ContentType.parse(contentDisposition).parameters;
      }

      /// get the name of form field
      String? name = parameters['name'];

      /// check if the field name exist
      if (name == null) {
        throw HTTPException(
          400,
          "Cannot find the header name field for the request content",
        );
      }

      /// check if this part is field or file
      if (!parameters.containsKey('filename')) {
        if (formFields.containsKey(name)) {
          formFields[name]!.add(await utf8.decodeStream(part));
        } else {
          formFields[name] = [await utf8.decodeStream(part)];
        }
        continue;
      }

      /// ================ handle if it's file =====================
      String? filename = parameters['filename'];
      if (filename == null) {
        throw HTTPException(
          400,
          "Cannot find the header name field for the request",
        );
      }

      /// add the file to formFiles as stream
      Stream<List<int>> streamBytes = part.asBroadcastStream();
      if (formFiles.containsKey(name)) {
        formFiles[name]!.add(FilePart(name, filename, streamBytes));
      } else {
        formFiles[name] = [FilePart(name, filename, streamBytes)];
      }
    }
    return FormData(formFields, formFiles);
  }
}
