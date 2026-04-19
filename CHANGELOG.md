## 0.0.8
- Add concurrent JTI uniqueness test: generate 1000 tokens concurrently and assert all JTIs are distinct
- Add `false_secrets` in `pubspec.yaml` to suppress pub.dev false-positive secret warnings on test RSA keys

## 0.0.7
- Improve README: better structure and clarity

## 0.0.6
- Add RS256 (asymmetric RSA) support via `JwtService.rs256()` constructor
- Add token revocation via injectable `TokenStore` interface and `InMemoryTokenStore`
- Add `apiKeyMiddleware` for API key-based authentication
- `verifyAccessToken` and `verifyRefreshToken` are now async (`Future<Map?>`)
- Add `revokeToken(String token)` method to `JwtService`

## 0.0.5
- Fix non-unique JWT token IDs (JTI): replace microsecond timestamp with 128-bit cryptographically random value

## 0.0.4
- update docs

## 0.0.3
- License change

## 0.0.2
- Fix static analysis.

## 0.0.1
- Initial version.
