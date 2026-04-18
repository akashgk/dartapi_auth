import 'dart:convert';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

Handler _makeHandler(Set<String> keys, {String headerName = 'X-API-Key'}) {
  return apiKeyMiddleware(validKeys: keys, headerName: headerName)(
    (request) => Response.ok(
      jsonEncode({'ok': true, 'key': request.context['api_key']}),
      headers: {'Content-Type': 'application/json'},
    ),
  );
}

void main() {
  group('apiKeyMiddleware', () {
    const validKey = 'secret-key-123';
    final handler = _makeHandler({validKey, 'another-key'});

    test('allows request with a valid API key', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': validKey},
      );
      final response = await handler(request);
      expect(response.statusCode, equals(200));
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['ok'], isTrue);
      expect(body['key'], equals(validKey));
    });

    test('allows any key from the valid set', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': 'another-key'},
      );
      final response = await handler(request);
      expect(response.statusCode, equals(200));
    });

    test('rejects request with missing API key header', () async {
      final request = Request('GET', Uri.parse('http://localhost/api'));
      final response = await handler(request);
      expect(response.statusCode, equals(401));
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['error'], contains('API key'));
    });

    test('rejects request with empty API key', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': ''},
      );
      final response = await handler(request);
      expect(response.statusCode, equals(401));
    });

    test('rejects request with invalid API key', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': 'wrong-key'},
      );
      final response = await handler(request);
      expect(response.statusCode, equals(401));
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['error'], contains('Invalid or missing API key'));
    });

    test('stores the validated key in request context', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': validKey},
      );
      final response = await handler(request);
      final body = jsonDecode(await response.readAsString()) as Map;
      expect(body['key'], equals(validKey));
    });

    test('supports custom header name', () async {
      final customHandler = _makeHandler({validKey}, headerName: 'X-Custom-Key');
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-Custom-Key': validKey},
      );
      final response = await customHandler(request);
      expect(response.statusCode, equals(200));
    });

    test('rejects when default header used but custom header expected', () async {
      final customHandler = _makeHandler({validKey}, headerName: 'X-Custom-Key');
      final request = Request(
        'GET',
        Uri.parse('http://localhost/api'),
        headers: {'X-API-Key': validKey},
      );
      final response = await customHandler(request);
      expect(response.statusCode, equals(401));
    });

    test('response content-type is application/json on rejection', () async {
      final request = Request('GET', Uri.parse('http://localhost/api'));
      final response = await handler(request);
      expect(
        response.headers['content-type'],
        contains('application/json'),
      );
    });
  });
}
