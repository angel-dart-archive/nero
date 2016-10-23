import 'dart:async';
import 'dart:io';
import 'defs.dart';
import 'request.dart';
import 'response.dart';
import 'router.dart';

class Nero extends Router {
  Nero({bool debug: false}) {
    this.debug = debug;
  }

  Future handleRequest(HttpRequest request) async {
    final route = resolve(request.uri.toString());

    if (route == null) {
      final result = on404(await Request.from(request, null));
      final Response res = result is Future ? await result : result;
      await res.send(request.response);
      await request.response.close();
    } else {
      final req = await Request.from(request, route);
      final it = route.handlerSequence.iterator;

      if (!it.moveNext()) {
        throw new Exception('Each route must have at least one handler mapped to it.');
      } else {
        final result = pipelineCallback(it, req);
        final Response res = result is Future ? await result : result;
        await res.send(request.response);
        await request.response.close();
      }
    }
  }

  Future<HttpServer> listen([InternetAddress address, int port]) async {
    final server = await HttpServer.bind(
        address ?? InternetAddress.LOOPBACK_IP_V4, port ?? 0);
    server.listen(handleRequest);
    print('Nero listening on http://${server.address.address}:${server.port}');
    return server;
  }

  RequestHandler on404 = (Request req) => new Response.html('''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
          <title>404 Not Found</title>
        </head>
        <body>
          <h1>404 Not Found</h1>
          <i>The file '${req.uri}' does not exist on this server.</i>
        </body>
      </html>
      ''')..statusCode = HttpStatus.NOT_FOUND;

  Future<Response> pipelineCallback(Iterator it, Request req) {
    if (it.current is RequestMiddleware) {
      return it.current(req, () {
        if (it.moveNext()) {
          return pipelineCallback(it, req);
        } else {
          throw new Exception(
              'Middleware must be succeeded by another request handler.');
        }
      });
    } else if (it.current is RequestHandler) {
      final res = it.current(req);
      return res is Future ? res : new Future.value(res);
    } else {
      throw new Exception(
          'Cannot respond to request with a(n) ${it.current.runtimeType}.');
    }
  }
}
