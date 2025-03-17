import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

class JwtService {
  final String accessTokenSecret;
  final String refreshTokenSecret;
  final String issuer;
  final String audience;
  final Duration accessTokenExpiry;
  final Duration refreshTokenExpiry;
  final JWTAlgorithm algorithm;

  JwtService({
    required this.accessTokenSecret,
    required this.refreshTokenSecret,
    required this.issuer,
    required this.audience,
    this.accessTokenExpiry = const Duration(hours: 1),
    this.refreshTokenExpiry = const Duration(days: 7),
    this.algorithm = JWTAlgorithm.HS256,
  });

  /// Generate Access token for the claims passed.
  String generateAccessToken({required Map<String, dynamic> claims}) {
    final payload = {
      'jti': _generateUniqueTokenId(),
      'iss': issuer,
      'aud': audience,
      'type': 'access',
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(accessTokenExpiry).millisecondsSinceEpoch ~/ 1000,
      ...claims,
    };

    return JWT(
      payload,
    ).sign(SecretKey(accessTokenSecret), algorithm: algorithm);
  }

  /// Generate REfresh token for the claims passed.
  String generateRefreshToken({required String accessToken}) {
    final oldPayload = verifyAccessToken(accessToken);
    if (oldPayload == null) {
      throw Exception('Invalid access token, cannot generate refresh token');
    }

    final newPayload = {
      ...oldPayload,
      'type': 'refresh',
      'jti': _generateUniqueTokenId(),
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp':
          DateTime.now().add(refreshTokenExpiry).millisecondsSinceEpoch ~/ 1000,
    };

    return JWT(
      newPayload,
    ).sign(SecretKey(refreshTokenSecret), algorithm: algorithm);
  }

  /// verifies the access token
  Map<String, dynamic>? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(accessTokenSecret));

      final payload = jwt.payload;

      if (!_isValidPayload(payload)) return null;
      if (payload['iss'] != issuer) return null;
      if (payload['aud'] != audience) return null;
      if (payload['type'] != 'access') return null;
      if (DateTime.fromMillisecondsSinceEpoch(
        payload['exp'] * 1000,
      ).isBefore(DateTime.now())) {
        return null;
      }

      return Map<String, dynamic>.from(payload);
    } catch (e) {
      return null;
    }
  }

  /// verifies the refresh token
  Map<String, dynamic>? verifyRefreshToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(refreshTokenSecret));

      final payload = jwt.payload;

      if (!_isValidPayload(payload)) return null;
      if (payload['iss'] != issuer) return null;
      if (payload['aud'] != audience) return null;
      if (payload['type'] != 'refresh') return null;
      if (DateTime.fromMillisecondsSinceEpoch(
        payload['exp'] * 1000,
      ).isBefore(DateTime.now())) {
        return null;
      }

      return Map<String, dynamic>.from(payload);
    } catch (e) {
      return null;
    }
  }

  bool _isValidPayload(Map<String, dynamic> payload) {
    final requiredClaims = ['sub', 'iat', 'exp', 'jti', 'iss', 'aud', 'type'];

    for (final claim in requiredClaims) {
      if (!payload.containsKey(claim) || payload[claim] == null) {
        return false;
      }
    }

    return true;
  }

  String _generateUniqueTokenId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
