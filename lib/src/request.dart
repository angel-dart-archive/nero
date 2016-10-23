import 'dart:async';
import 'dart:io';
import 'package:angel_route/angel_route.dart';
import 'package:angel_route/src/extensible.dart';
import 'package:body_parser/body_parser.dart';

class Request extends Extensible {
  BodyParseResult _body;
  Match _match;
  Map _params;
  final HttpRequest io;
  final Route route;

  Map get body => _body.body;
  List<Cookie> get cookies => io.cookies;
  List<FileUploadInfo> get files => _body.files;
  Match get match => _match;
  String get method => method;
  Map get params => _params;
  Map get query => uri.queryParameters;
  HttpSession get session => io.session;
  Uri get uri => io.uri;

  Request._(this.io, this.route) {
    _match = route?.match(io.uri.toString());
    _params = route?.parseParameters(io.uri.toString());
  }

  static Future<Request> from(HttpRequest request, Route route) async {
    final req = new Request._(request, route);
    req._body = await parseBody(request);
    return req;
  }
}