# Cruky
__pronunciation: croky__

## Features
[x] Simple code to start serving you api
[x] Fast performance
[x] Get into the point without any struggling
[x] Static files handler
[x] Web socket support
[ ] HTTPS support

# Example

```dart
import 'package:cruky/cruky.dart';

void main() {
  Server server = Server();

  // An application level middlawre
  server.use(middleware);

  server.path('/my/path');

  // this method will handle the '/my/path' path
  // on GET method
  server.get(example);

  // expose the assets folder to route `/static/`
  server.static('./assets', '/static/**');

  // serving the app
  server.run();
}

Future<void> example(Request req, Response resp) async {
  resp.send("Hello world");
}

Future<void> middleware(Request req, Response resp, Handler next) async {
  print('main middleware example: Start');
  await next(req, resp);
  print('main middleware example: End');
}

```