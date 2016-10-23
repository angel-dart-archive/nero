import 'dart:io';
import 'package:heaven/heaven.dart';
import 'package:heaven/ui.dart';
import 'package:nero/nero.dart';

main() {
  final app = new Nero();
  final indexFile = new File('basic/hello.html');

  app.get('/', (req) => new Response.file(indexFile));

  app.get(new RegExp(r'^file/([^$]+)$'), (req) async {
    final file = new File(req.match[1]);

    if (!await file.exists()) {
      return new Response.html('''
      <!DOCTYPE html>
      <html>
        <head>
          <meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0">
          <title>404 Not Found</title>
        </head>
        <body>
          <h1>404 Not Found</h1>
          <i>The file '${req.match[1]}' does not exist on this server.</i>
        </body>
      </html>
      ''')..statusCode = HttpStatus.NOT_FOUND;
    } else
      return new Response.blob(file.readAsBytesSync());
  });

  app.get('heaven', (req) {
    final state = new State();
    return new Response.view(document(state, [
      head(state, [
        title(state, [text('Hello?')])
      ]),
      body(state, {}, [
        h1(state, {}, [text('Hello?')]),
        a(state, href: '/google', children: [text('Click to visit Google')])
      ])
    ]));
  });

  app.get('google', (req) => new Response.redirect('https://google.com'));

  return app.listen(InternetAddress.LOOPBACK_IP_V4, 3000);
}
