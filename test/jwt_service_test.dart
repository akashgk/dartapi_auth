import 'dart:convert';
import 'package:test/test.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

void main() {
  late JwtService jwtService;
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
  });


  test('Generates a valid access token', () {
    final token = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    expect(token, isNotEmpty);
  });


  test('Verifies a valid access token', () {
    final token = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    final payload = jwtService.verifyAccessToken(token);
    expect(payload, isNotNull);
    expect(payload!['sub'], '123');
    expect(payload['username'], 'testuser');
    expect(payload['type'], 'access');
    expect(payload['iss'], issuer);
    expect(payload['aud'], audience);
    expect(payload['jti'], isNotEmpty);
  });


  test('Generates a valid refresh token', () {
    final accessToken = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
    expect(refreshToken, isNotEmpty);
  });

  test('Verifies a valid refresh token', () {
    final accessToken = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
    final payload = jwtService.verifyRefreshToken(refreshToken);

    expect(payload, isNotNull);
    expect(payload!['sub'], '123');
    expect(payload['username'], 'testuser');
    expect(payload['type'], 'refresh');
    expect(payload['iss'], issuer);
    expect(payload['aud'], audience);
    expect(payload['jti'], isNotEmpty);
  });


  test('Rejects an expired access token', () {
    final expiredToken = JWT({
      'sub': '123',
      'username': 'testuser',
      'type': 'access',
      'iat': DateTime.now().subtract(Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().subtract(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'iss': issuer,
      'aud': audience,
      'jti': 'expired-token-id'
    }).sign(SecretKey(accessSecret));

    final payload = jwtService.verifyAccessToken(expiredToken);
    expect(payload, isNull);
  });


  test('Fails verification when issuer is incorrect', () {
    final badIssuerToken = JWT({
      'sub': '123',
      'username': 'testuser',
      'type': 'access',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'iss': 'wrong-issuer',
      'aud': audience,
      'jti': 'token-id',
    }).sign(SecretKey(accessSecret));

    final payload = jwtService.verifyAccessToken(badIssuerToken);
    expect(payload, isNull);
  });


  test('Fails verification when audience is incorrect', () {
    final badAudienceToken = JWT({
      'sub': '123',
      'username': 'testuser',
      'type': 'access',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': DateTime.now().add(Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
      'iss': issuer,
      'aud': 'wrong-audience',
      'jti': 'token-id',
    }).sign(SecretKey(accessSecret));

    final payload = jwtService.verifyAccessToken(badAudienceToken);
    expect(payload, isNull);
  });


  test('Rejects an access token with missing required claims', () {
    final invalidToken = JWT({
      'username': 'testuser',
      'type': 'access',
    }).sign(SecretKey(accessSecret));

    final payload = jwtService.verifyAccessToken(invalidToken);
    expect(payload, isNull);
  });

  test('Fails verification when access token is tampered with and re-signed', () {
    final originalToken = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    // Decode original token payload
    final parts = originalToken.split('.');
    final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

    // Modify payload
    payload['username'] = 'hacker';

    // Encode the modified payload back
    final modifiedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));

    // Reconstruct the token with a different secret key (simulating an attack)
    final modifiedToken =
        '${parts[0]}.$modifiedPayload.${JWT(payload).sign(SecretKey("wrong-secret"))}';

    final payloadAfterTampering = jwtService.verifyAccessToken(modifiedToken);
    expect(payloadAfterTampering, isNull);
  });

  test('Fails verification when refresh token is tampered with and re-signed', () {
    final accessToken = jwtService.generateAccessToken(claims: {
      'sub': '123',
      'username': 'testuser',
    });

    final originalRefreshToken =
        jwtService.generateRefreshToken(accessToken: accessToken);

    // Decode original refresh token payload
    final parts = originalRefreshToken.split('.');
    final payload = jsonDecode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))));

    // Modify payload
    payload['username'] = 'hacker';

    // Encode the modified payload back
    final modifiedPayload = base64Url.encode(utf8.encode(jsonEncode(payload)));

    // Reconstruct the token with a different secret key (simulating an attack)
    final modifiedToken =
        '${parts[0]}.$modifiedPayload.${JWT(payload).sign(SecretKey("wrong-secret"))}';

    final payloadAfterTampering = jwtService.verifyRefreshToken(modifiedToken);
    expect(payloadAfterTampering, isNull);
  });
}