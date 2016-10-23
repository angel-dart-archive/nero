import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:angel_route/angel_route.dart';
import 'package:json_god/json_god.dart' as god;
import 'package:heaven/heaven.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class Response {
  ContentType contentType;
  final List<Cookie> cookies = [];
  final Map<String, String> headers = {};
  int statusCode = 200;

  Response();
  factory Response.blob(List<int> blob) => new _BlobResponse(blob);
  factory Response.download(File file) => new _FileResponse(file)
    ..headers['Content-Disposition'] =
        'attachment; filename="${basename(file.path)}"';
  factory Response.empty() => new _EmptyResponse();
  factory Response.file(File file) => new _FileResponse(file);
  factory Response.html(String html) => new _HtmlResponse(html);
  factory Response.text(String text) => new _TextResponse(text);
  factory Response.json(data, {bool useGod: true}) =>
      new _JsonResponse(data, useGod: useGod);
  factory Response.jsonp(String callbackName, data, {bool useGod: true}) =>
      new _JsonpResponse(callbackName, data, useGod: useGod);
  factory Response.redirect(String to, {int code}) =>
      new _RedirectResponse(to, code: code);
  factory Response.route(Route to, [Map params]) =>
      new _RedirectResponse('/' + to.makeUri(params));
  factory Response.stream(Stream<List<int>> stream) =>
      new _StreamResponse(stream);
  factory Response.view(StandardElement root) => new _ViewResponse(root);

  Future send(HttpResponse response) async {
    response.cookies.addAll(cookies);
    headers.forEach((k, v) => response.headers.set(k, v));
    response.statusCode = statusCode;

    if (contentType != null) response.headers.contentType = contentType;
  }
}

class _BlobResponse extends Response {
  final List<int> blob;

  _BlobResponse(this.blob);

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.add(blob);
  }
}

class _EmptyResponse extends Response {
  @override
  Future send(HttpResponse response) => new Future(() {});
}

class _FileResponse extends Response {
  final File file;

  _FileResponse(this.file) {
    headers[HttpHeaders.CONTENT_TYPE] = lookupMimeType(file.path);
  }

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    await response.addStream(file.openRead());
  }
}

class _JsonResponse extends Response {
  final dynamic data;
  final bool useGod;

  _JsonResponse(this.data, {this.useGod: true}) {
    contentType = ContentType.JSON;
  }

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.write(useGod ? god.serialize(data) : JSON.encode(data));
  }
}

class _JsonpResponse extends Response {
  final String callbackName;
  final dynamic data;
  final bool useGod;

  _JsonpResponse(this.callbackName, this.data, {this.useGod: true}) {
    contentType = new ContentType('application', 'javascript');
  }

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.write('$callbackName(');
    response.write(useGod ? god.serialize(data) : JSON.encode(data));
    response.write(')');
  }
}

class _HtmlResponse extends Response {
  final String html;

  _HtmlResponse(this.html) {
    contentType = ContentType.HTML;
  }

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.write(html);
  }
}

class _TextResponse extends Response {
  final String text;

  _TextResponse(this.text);

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.write(text);
  }
}

class _ViewResponse extends Response {
  final StandardElement root;

  _ViewResponse(this.root) {
    contentType = ContentType.HTML;
  }

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    response.write(root.render());
  }
}

class _RedirectResponse extends Response {
  String to;

  _RedirectResponse(this.to, {int code}) {
    statusCode = code ?? 301;
    headers[HttpHeaders.LOCATION] = to;
  }
}

class _StreamResponse extends Response {
  final Stream<List<int>> stream;

  _StreamResponse(this.stream);

  @override
  Future send(HttpResponse response) async {
    await super.send(response);
    await response.addStream(stream);
  }
}
