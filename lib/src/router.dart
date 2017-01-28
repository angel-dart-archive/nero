import 'package:angel_route/angel_route.dart' as angel;
import 'defs.dart';

class Router extends angel.Router {
  Router() : super();

  @override
  angel.Route group(Pattern path, void callback(Router router),
      {Iterable middleware: const [],
      String name: null,
      String namespace: null}) {
    return super.group(path, callback,
        middleware: middleware, name: name, namespace: namespace);
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
  angel.SymlinkRoute mount(Pattern path, Router router,
          {bool hooked: true, String namespace: null}) =>
      super.mount(path, router, hooked: hooked, namespace: namespace);
}