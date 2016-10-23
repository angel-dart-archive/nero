import 'dart:io';
import 'package:nero/nero.dart';

main() {
  final app = new Nero();

  app.chain((req, next) {
    print('ZOMG MIDDLEWAREZ!');
    return next();
  }).chain((req, next) {
    print('Another one?');
    return next();
  }).get('/', (req) => new Response.json({'foo': 'bar'}));

  app.chain((req, next) {
    print('MAYDAY!');
    return next();
  }).group('a', (router) {
    router.get('b', (req) => new Response.text('c'));
    router.get('d',
        (req) => new Response.route(req.route.resolve('../b')));
  });

  app.dumpTree();

  return app.listen(InternetAddress.LOOPBACK_IP_V4, 3000);
}
