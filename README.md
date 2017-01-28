# nero
Microframework based on Express and angel_route. This framework is unrelated to
[Angel](https://github.com/angel-dart/angel).

This is an experimental library, don't expect any future support.

```dart
main() {
  final app = new Nero();
  
  app.get('/', (req) => new Response.text('Hello, world!'));
  
  app.chain((req, next) async {
    req.properties['user'] = await someQuery(req.params.id);
  }).get('/user/:id', (req) {
    return new Response.json(req.user);
  });
}
```