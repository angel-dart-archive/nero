import 'package:angel_route/angel_route.dart' as angel;
import 'defs.dart';

class Router extends angel.Router {
  Router({angel.Route root}) : super(root: root);

  _ChainedRouter chain(RequestMiddleware middleware) =>
      new _ChainedRouter(this, middleware);

  @override
  angel.Route group(Pattern path, void callback(Router router),
      {Iterable middleware: const [],
      String method: "*",
      String name: null,
      String namespace: null}) {
    return super.group(path, callback,
        middleware: middleware,
        method: method,
        name: name,
        namespace: namespace);
  }

  @override
  angel.Route all(Pattern path, RequestHandler handler, {List middleware}) =>
      super.all(path, handler, middleware: middleware);

  @override
  angel.Route delete(Pattern path, RequestHandler handler, {List middleware}) =>
      super.delete(path, handler, middleware: middleware);

  @override
  angel.Route get(Pattern path, RequestHandler handler, {List middleware}) =>
      super.get(path, handler, middleware: middleware);

  @override
  angel.Route head(Pattern path, RequestHandler handler, {List middleware}) =>
      super.head(path, handler, middleware: middleware);

  @override
  angel.Route options(Pattern path, RequestHandler handler,
          {List middleware}) =>
      super.options(path, handler, middleware: middleware);

  @override
  angel.Route patch(Pattern path, RequestHandler handler, {List middleware}) =>
      super.patch(path, handler, middleware: middleware);

  @override
  angel.Route post(Pattern path, RequestHandler handler, {List middleware}) =>
      super.post(path, handler, middleware: middleware);

  @override
  angel.Route put(Pattern path, RequestHandler handler, {List middleware}) =>
      super.put(path, handler, middleware: middleware);

  @override
  void mount(Pattern path, Router router,
          {bool hooked: true, String namespace: null}) =>
      super.mount(path, router, hooked: hooked, namespace: namespace);
}

class _ChainedRouter extends Router {
  final List<RequestMiddleware> _handlers = [];
  Router _root;

  _ChainedRouter.empty();

  _ChainedRouter(Router root, RequestMiddleware middleware) {
    this._root = root;
    _handlers.add(middleware);
  }

  @override
  angel.Route addRoute(String method, Pattern path, RequestHandler handler,
      {List middleware}) {
    return _root.addRoute(method, path, handler,
        middleware: []..addAll(_handlers)..addAll(middleware ?? []));
  }

  @override
  angel.Route group(Pattern path, void callback(Router router),
      {Iterable middleware: const [],
      String method: "*",
      String name: null,
      String namespace: null}) {
    final route = _root.root.child(path,
        handlers: []..addAll(_handlers)..addAll(middleware),
        method: method,
        name: name);
    final router = new Router(root: route);
    callback(router);

    // Let's copy middleware, heeding the optional middleware namespace.
    String middlewarePrefix = namespace != null ? "$namespace." : "";

    Map copiedMiddleware = new Map.from(router.requestMiddleware);
    for (String middlewareName in copiedMiddleware.keys) {
      _root.requestMiddleware["$middlewarePrefix$middlewareName"] =
          copiedMiddleware[middlewareName];
    }

    return route;
  }

  @override
  void mount(Pattern path, Router router,
      {bool hooked: true, String namespace: null}) {
    // Let's copy middleware, heeding the optional middleware namespace.
    String middlewarePrefix = namespace != null ? "$namespace." : "";

    Map copiedMiddleware = new Map.from(router.requestMiddleware);
    for (String middlewareName in copiedMiddleware.keys) {
      requestMiddleware["$middlewarePrefix$middlewareName"] =
          copiedMiddleware[middlewareName];
    }

    root.child(path, debug: debug, handlers: _handlers).addChild(router.root);
  }

  @override
  _ChainedRouter chain(RequestMiddleware middleware) {
    final piped = new _ChainedRouter.empty().._root = _root;
    piped._handlers.addAll([]
      ..addAll(_handlers)
      ..add(middleware));
    return piped;
  }
}
