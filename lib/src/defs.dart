import 'request.dart';

typedef RequestHandler(Request req);
typedef RequestMiddleware(Request req, Function next);