import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:test/test.dart';

// ---------------------------------------------------------------------------
// Test RSA key pair (2048-bit, NOT for production use)
// ---------------------------------------------------------------------------
const _rsaPrivateKey = '''-----BEGIN PRIVATE KEY-----
MIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC/eo6D0o33u4sK
j450oXMwmFajpRUyYUrW/TpSPMZ+oB8tgfnrYUJc6C1k3DYH0qfN8ubq7RQUyXq4
GY8q3qmEuct9HYd6rI12cYm4+KQwVs2t2vx2uVHeoIwk4nD8V5aaNigo+MGLjDd9
JkWaONB9Ox1jpt0z7h0mnDQVd5x0Zevo0hIn22Hpa3YuIPy9wa5IAulfQKOJoV5u
LmjnROqnNYHvlmW+QOXBQU/Ozf5AGuSE3rXj/3bmtBnzeBqYWlGdXpJEGLlNUoGU
xiCXSbuHmUVeMUtQU8NL99S5LYzVDxs5+RPhpCknJKBnUQkn/70TGZrLKXhYfg0A
jIIMo3r1AgMBAAECggEAGJEoZNhod5773WyCygsG5Pa+svtUx2R9Pi06RN/gVdHE
fkm9X4pYgeQWIukwE3vfJMjkAMNPPsWE9cbtvAHafRl7dr+JqN8nvUke8vkP09Xn
SMWee7sWOnqd0IOvHGk+fOWy7GLSLk3ctrVo27srYM3rXORFYErOOaxz8Ecq7zIF
Tfv/tr1zhl3WR5VU1PcPrx/P1VQy30JZ26B/pB6RS6prUXfYQb4WQ55HPWk0xdZ1
AO3H0XsxI/dxhNzZXIjp0dgFLiO5F9tOI3T81vr8cbquMFhvYfV8+k6RMbmfVQkg
B3Ss5Xqer56dPhCTQ6F36lfTiLi42uwrn+WASr3ANwKBgQD4L3PPCPukA/0+Ktw6
VnoK5loyaDxjIntlN8eIlAas2E/BgUNWmz/2YbX95P3jURUE1178PgJiNpEMZ1Vd
ru7dutPXfb5RO2uvXkXypmagylD+I3rIK8CFsknxTEnp+O4Po12gPDEe0FmNlVav
EiDJRxEw+7VuG28Acm6ypk3vDwKBgQDFggJfOsmRyVGFAvX0P6x0HAAIif2foyok
FI0L70EPauSgLXC8jQy3mzNeGdeW1G/nlO+iiEnvvNxMXLSvr9Ls/SQNQv/evlzT
3TsisT8RKGKpYmzXvRR7sy0HPEYEyFsp3SCzUW9SLs8wFogBFlnX/aqs/JSs0+Jq
KE2iVUx1uwKBgQCDLCFbVXYas/kO+Hw5YSdTx3f4mFsCUmFBl/+f0gzNIe7VaUp7
5cYipHYZ4QPHNz2St3n+e4+q9QgotBzMTP72th3tEQqbyHob0AnMO+KWLRgtmfb1
ARraDudB335ZaTX5kfCUFfwoOxp52GpeUYh+mU8ewoqbzWgXpmOXjIo4RQKBgQCr
B5TkP/TysIFODC1Nz6GXffOtcUjV5yYDzmQBVLJjFm5aIl9Ad2fuyo+lyfz9mII6
6KbGePyFhGbEHXc9t6SQIfkJHt6RVQjvUeD2fsQdKHqfMSMNgqdtItA4NsJvO8xt
qRW7Eiay5OP3QVuOjXtJZVlZqPNZ4bVrtfDcRL8MJwKBgQDcAm8zo+8Q5dpV4fO0
E3Jxh1sH9Rum3QWBwjzzqM41Z1J5/ZBiUneBEOgl7VXRar8RkOtwcR76uBBO6KE+
3NG5i25FwFQJ4+NZQWP7G9QLbLMlHYWmi48ilZ1APxl8LI8Q67G7dT/Z0cgvN8+S
8cx6AuCCtyMC28/yMCUpS/Y7oA==
-----END PRIVATE KEY-----''';

const _rsaPublicKey = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAv3qOg9KN97uLCo+OdKFz
MJhWo6UVMmFK1v06UjzGfqAfLYH562FCXOgtZNw2B9KnzfLm6u0UFMl6uBmPKt6p
hLnLfR2HeqyNdnGJuPikMFbNrdr8drlR3qCMJOJw/FeWmjYoKPjBi4w3fSZFmjjQ
fTsdY6bdM+4dJpw0FXecdGXr6NISJ9th6Wt2LiD8vcGuSALpX0CjiaFebi5o50Tq
pzWB75ZlvkDlwUFPzs3+QBrkhN614/925rQZ83gamFpRnV6SRBi5TVKBlMYgl0m7
h5lFXjFLUFPDS/fUuS2M1Q8bOfkT4aQpJySgZ1EJJ/+9Exmayyl4WH4NAIyCDKN6
9QIDAQAB
-----END PUBLIC KEY-----''';

// A different public key to test rejection.
const _wrongPublicKey = '''-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyLlNE1CVKoepSs9X9GRC
x6RTNi27YkMGPKwsV2qP6Pb5X8K0W0RZeNqBMfxPxCDiMoN/3FijkRNvXvEACAVi
1XjBhiJuX1jIJT1oVMl8gbXBwjnEFHSuLnS1HFgqiFEE8RIbDmBVBL8vvGfaFo8g
L10fMo2W3FLQ0b7mJFH9g4OqFcmEJL13DKSxV3a0UeAFPBCIYGJ3+VeJQhWklvqS
h2J2aPi4OQpYNWvdG/yDI07Hh/6DynJz4RqnUi0yYb/LGN/VEpPZFbHVeSvGBGe4
jJGZS4jQ6+c1dASRqQW6ggP/EvtmDp3vkLGBRE65pz3LFI7T4YXJGhfb0qO6XQID
AQAB
-----END PUBLIC KEY-----''';

void main() {
  late JwtService jwtServiceHs256;

  const accessSecret = 'test-access-secret';
  const refreshSecret = 'test-refresh-secret';
  const issuer = 'dartapi-auth';
  const audience = 'dartapi-users';

  setUp(() {
    jwtServiceHs256 = JwtService(
      accessTokenSecret: accessSecret,
      refreshTokenSecret: refreshSecret,
      issuer: issuer,
      audience: audience,
    );
  });

  // ---------------------------------------------------------------------------
  // HS256 — existing behaviour
  // ---------------------------------------------------------------------------
  group('JwtService (HS256)', () {
    test('generates a valid access token', () {
      final token = jwtServiceHs256.generateAccessToken(
        claims: {'sub': '123', 'username': 'testuser'},
      );
      expect(token, isNotEmpty);
    });

    test('verifies a valid access token', () async {
      final token = jwtServiceHs256.generateAccessToken(
        claims: {'sub': '123', 'username': 'testuser'},
      );
      final payload = await jwtServiceHs256.verifyAccessToken(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals('123'));
      expect(payload['username'], equals('testuser'));
      expect(payload['type'], equals('access'));
      expect(payload['iss'], equals(issuer));
      expect(payload['aud'], equals(audience));
      expect(payload['jti'], isNotEmpty);
    });

    test('generates a valid refresh token', () {
      final access = jwtServiceHs256.generateAccessToken(
        claims: {'sub': '123', 'username': 'testuser'},
      );
      final refresh = jwtServiceHs256.generateRefreshToken(accessToken: access);
      expect(refresh, isNotEmpty);
    });

    test('verifies a valid refresh token', () async {
      final access = jwtServiceHs256.generateAccessToken(
        claims: {'sub': '123', 'username': 'testuser'},
      );
      final refresh = jwtServiceHs256.generateRefreshToken(accessToken: access);
      final payload = await jwtServiceHs256.verifyRefreshToken(refresh);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals('123'));
      expect(payload['type'], equals('refresh'));
    });

    test('rejects an expired access token', () async {
      final expired = JWT({
        'sub': '123',
        'username': 'testuser',
        'type': 'access',
        'iat': DateTime.now().subtract(const Duration(hours: 2)).millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().subtract(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'iss': issuer,
        'aud': audience,
        'jti': 'expired-id',
      }).sign(SecretKey(accessSecret));
      expect(await jwtServiceHs256.verifyAccessToken(expired), isNull);
    });

    test('rejects wrong issuer', () async {
      final token = JWT({
        'sub': '123',
        'username': 'u',
        'type': 'access',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'iss': 'wrong-issuer',
        'aud': audience,
        'jti': 'id',
      }).sign(SecretKey(accessSecret));
      expect(await jwtServiceHs256.verifyAccessToken(token), isNull);
    });

    test('rejects wrong audience', () async {
      final token = JWT({
        'sub': '123',
        'username': 'u',
        'type': 'access',
        'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
        'exp': DateTime.now().add(const Duration(hours: 1)).millisecondsSinceEpoch ~/ 1000,
        'iss': issuer,
        'aud': 'wrong-audience',
        'jti': 'id',
      }).sign(SecretKey(accessSecret));
      expect(await jwtServiceHs256.verifyAccessToken(token), isNull);
    });

    test('rejects token with missing required claims', () async {
      final token = JWT({'username': 'u', 'type': 'access'})
          .sign(SecretKey(accessSecret));
      expect(await jwtServiceHs256.verifyAccessToken(token), isNull);
    });

    test('rejects tampered token', () async {
      final token = jwtServiceHs256.generateAccessToken(
        claims: {'sub': '123', 'username': 'testuser'},
      );
      final parts = token.split('.');
      final modifiedPayload = base64Url.encode(
        utf8.encode('{"sub":"hacker","type":"access"}'),
      );
      final tampered = '${parts[0]}.$modifiedPayload.${parts[2]}';
      expect(await jwtServiceHs256.verifyAccessToken(tampered), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // RS256 — asymmetric key support
  // ---------------------------------------------------------------------------
  group('JwtService (RS256)', () {
    late JwtService rs256;

    setUp(() {
      rs256 = JwtService.rs256(
        privateKeyPem: _rsaPrivateKey,
        publicKeyPem: _rsaPublicKey,
        issuer: issuer,
        audience: audience,
      );
    });

    test('algorithm is RS256', () {
      expect(rs256.algorithm, equals(JWTAlgorithm.RS256));
    });

    test('generates access token verifiable with public key', () async {
      final token = rs256.generateAccessToken(claims: {'sub': 'u1'});
      expect(token, isNotEmpty);
      final payload = await rs256.verifyAccessToken(token);
      expect(payload, isNotNull);
      expect(payload!['sub'], equals('u1'));
      expect(payload['type'], equals('access'));
    });

    test('generates refresh token verifiable with public key', () async {
      final access = rs256.generateAccessToken(claims: {'sub': 'u1'});
      final refresh = rs256.generateRefreshToken(accessToken: access);
      final payload = await rs256.verifyRefreshToken(refresh);
      expect(payload, isNotNull);
      expect(payload!['type'], equals('refresh'));
    });

    test('rejects RS256 token when verified with wrong public key', () async {
      final token = rs256.generateAccessToken(claims: {'sub': 'u1'});
      final wrongService = JwtService.rs256(
        privateKeyPem: _rsaPrivateKey,
        publicKeyPem: _wrongPublicKey,
        issuer: issuer,
        audience: audience,
      );
      expect(await wrongService.verifyAccessToken(token), isNull);
    });

    test('rejects HS256 token when verifying with RS256 service', () async {
      final hs256Token = jwtServiceHs256.generateAccessToken(
        claims: {'sub': 'u1'},
      );
      expect(await rs256.verifyAccessToken(hs256Token), isNull);
    });
  });

  // ---------------------------------------------------------------------------
  // Token revocation
  // ---------------------------------------------------------------------------
  group('JwtService — token revocation', () {
    late JwtService svc;
    late InMemoryTokenStore store;

    setUp(() {
      store = InMemoryTokenStore();
      svc = JwtService(
        accessTokenSecret: accessSecret,
        refreshTokenSecret: refreshSecret,
        issuer: issuer,
        audience: audience,
        tokenStore: store,
      );
    });

    test('valid unrevoked token verifies normally', () async {
      final token = svc.generateAccessToken(claims: {'sub': 'u1'});
      expect(await svc.verifyAccessToken(token), isNotNull);
    });

    test('revoked token returns null on verify', () async {
      final token = svc.generateAccessToken(claims: {'sub': 'u1'});
      await svc.revokeToken(token);
      expect(await svc.verifyAccessToken(token), isNull);
    });

    test('revoking one token does not affect other tokens', () async {
      final t1 = svc.generateAccessToken(claims: {'sub': 'u1'});
      final t2 = svc.generateAccessToken(claims: {'sub': 'u2'});
      await svc.revokeToken(t1);
      expect(await svc.verifyAccessToken(t1), isNull);
      expect(await svc.verifyAccessToken(t2), isNotNull);
    });

    test('revoking a refresh token prevents its verification', () async {
      final access = svc.generateAccessToken(claims: {'sub': 'u1'});
      final refresh = svc.generateRefreshToken(accessToken: access);
      await svc.revokeToken(refresh);
      expect(await svc.verifyRefreshToken(refresh), isNull);
    });

    test('revokeToken is a no-op when no tokenStore is configured', () async {
      final noStore = JwtService(
        accessTokenSecret: accessSecret,
        refreshTokenSecret: refreshSecret,
        issuer: issuer,
        audience: audience,
      );
      final token = noStore.generateAccessToken(claims: {'sub': 'u1'});
      await noStore.revokeToken(token); // should not throw
      expect(await noStore.verifyAccessToken(token), isNotNull);
    });

    test('revokeToken is silent on malformed token', () async {
      await svc.revokeToken('not.a.jwt'); // should not throw
    });
  });

  // ---------------------------------------------------------------------------
  // JTI uniqueness under concurrency
  // ---------------------------------------------------------------------------
  group('JwtService — JTI uniqueness', () {
    test('1000 concurrently generated tokens all have unique JTIs', () async {
      final svc = JwtService(
        accessTokenSecret: accessSecret,
        refreshTokenSecret: refreshSecret,
        issuer: issuer,
        audience: audience,
      );

      final tokens = await Future.wait(
        List.generate(
          1000,
          (_) => Future(() => svc.generateAccessToken(claims: {'sub': 'u1'})),
        ),
      );

      final payloads = await Future.wait(
        tokens.map((t) => svc.verifyAccessToken(t)),
      );

      final jtis = payloads.map((p) => p!['jti'] as String).toList();
      expect(jtis.toSet().length, equals(jtis.length),
          reason: 'All 1000 JTIs must be unique');
    });
  });
}
