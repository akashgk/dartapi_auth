import 'dart:convert';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'dart:math';

String getRandomLetter() {
  const letters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
  final random = Random();
  return letters[random.nextInt(letters.length)];
}

List<String> generateRandomArray(String inputString) {
  int length = inputString.length;
  return List.generate(length, (_) => getRandomLetter());
}

void main() {
  late JwtService jwtService;
  late Handler protectedHandler;
  const accessSecret = 'test-access-secret';
  const refreshSecret = 'test-refresh-secret';
  const issuer = 'dartapi-auth';
  const audience = 'dartapi-users';

  setUp(() {
    jwtService = JwtService(
      accessTokenSecret: accessSecret,
      refreshTokenSecret: refreshSecret,
      issuer: issuer,
      audience: audience,
    );

    protectedHandler = authMiddleware(jwtService)((request) {
      return Response.ok(jsonEncode({'message': 'Access granted'}));
    });
  });

  /// ✅ Test: Request with a valid token should succeed
  test('Allows request with a valid token', () async {
    final token = jwtService.generateAccessToken(
      claims: {'sub': '123', 'username': 'testuser'},
    );

    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/protected'),
      headers: {'Authorization': 'Bearer $token'},
    );

    final response = await protectedHandler(request);

    expect(response.statusCode, equals(200));
    expect(await response.readAsString(), contains('Access granted'));
  });

  /// ❌ Test: Request with no Authorization header should be rejected
  test('Rejects request with no Authorization header', () async {
    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/protected'),
    );

    final response = await protectedHandler(request);

    expect(response.statusCode, equals(403));
    expect(await response.readAsString(), contains('Missing or invalid token'));
  });

  /// ❌ Test: Request with an expired token should be rejected
  test('Rejects request with an expired token', () async {
    final expiredToken = jwtService.generateAccessToken(
      claims: {
        'sub': '123',
        'username': 'testuser',
        'iat':
            DateTime.now()
                .subtract(Duration(hours: 2))
                .millisecondsSinceEpoch ~/
            1000,
        'exp':
            DateTime.now()
                .subtract(Duration(hours: 1))
                .millisecondsSinceEpoch ~/
            1000,
      },
    );

    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/protected'),
      headers: {'Authorization': 'Bearer $expiredToken'},
    );

    final response = await protectedHandler(request);

    expect(response.statusCode, equals(403));
    expect(await response.readAsString(), contains('Invalid token'));
  });

  /// ❌ Test: Request with a tampered token should be rejected
  test('Rejects request with a tampered token', () async {
    final token = jwtService.generateAccessToken(
      claims: {'sub': '123', 'username': 'testuser'},
    );

    final parts = token.split('.');
    final manipulatedPayload = generateRandomArray(parts[1]).join();
    final modifiedToken = '${parts[0]}.$manipulatedPayload.${parts[2]}';

    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/protected'),
      headers: {'Authorization': 'Bearer $modifiedToken'},
    );

    final response = await protectedHandler(request);

    expect(response.statusCode, equals(403));
    expect(await response.readAsString(), contains('Invalid token'));
  });

  /// ❌ Test: Request with an invalid token format should be rejected
  test('Rejects request with an invalid token format', () async {
    final request = Request(
      'GET',
      Uri.parse('http://localhost:8080/protected'),
      headers: {'Authorization': 'Bearer invalid.token.format'},
    );

    final response = await protectedHandler(request);

    expect(response.statusCode, equals(403));
    expect(await response.readAsString(), contains('Invalid token'));
  });
}
