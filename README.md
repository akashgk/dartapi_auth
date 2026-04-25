# dartapi_auth

> **Deprecated.** Auth is now built into [`dartapi_core`](https://pub.dev/packages/dartapi_core) — use that instead.
> This package re-exports `JwtService`, `authMiddleware`, `apiKeyMiddleware`, `TokenStore`, `InMemoryTokenStore`, and `TokenHelpers` from `dartapi_core` for backwards compatibility, but will not receive new features.

---

## Migration

Replace:

```yaml
dependencies:
  dartapi_auth: ^0.0.11
```

With:

```yaml
dependencies:
  dartapi_core: ^0.1.3
```

Replace:

```dart
import 'package:dartapi_auth/dartapi_auth.dart';
```

With:

```dart
import 'package:dartapi_core/dartapi_core.dart';
```

All exported symbols (`JwtService`, `authMiddleware`, `apiKeyMiddleware`, `TokenStore`, `InMemoryTokenStore`, `TokenHelpers`) are identical — no other code changes are needed.

---

## Installation (legacy)

```yaml
dependencies:
  dartapi_auth: ^0.0.11
```

---

## JwtService (HS256)

Use HS256 for single-service deployments where the signing and verification key can stay on one server:

```dart
final jwtService = JwtService(
  accessTokenSecret: 'my-access-secret',
  refreshTokenSecret: 'my-refresh-secret',
  issuer: 'my-app',
  audience: 'api-clients',
);
```

## JwtService (RS256)

Use RS256 when multiple services need to verify tokens without sharing the signing key. Distribute the public key freely; keep the private key server-side only.

```dart
final jwtService = JwtService.rs256(
  privateKeyPem: File('private.pem').readAsStringSync(),
  publicKeyPem:  File('public.pem').readAsStringSync(),
  issuer: 'my-app',
  audience: 'api-clients',
);
```

---

## Generating Tokens

```dart
final accessToken = jwtService.generateAccessToken(claims: {
  'sub': 'user-123',
  'username': 'akash',
});

final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
```

## Verifying Tokens

Both methods are async and return `null` on any failure (expired, wrong issuer, invalid signature, revoked):

```dart
final payload = await jwtService.verifyAccessToken(accessToken);
if (payload == null) {
  // token is invalid
}

final refreshPayload = await jwtService.verifyRefreshToken(refreshToken);
```

---

## Token Revocation

Inject a `TokenStore` to enable revocation. `InMemoryTokenStore` works for single-instance servers:

```dart
final jwtService = JwtService(
  accessTokenSecret: 'my-secret',
  refreshTokenSecret: 'my-refresh-secret',
  issuer: 'my-app',
  audience: 'api-clients',
  tokenStore: InMemoryTokenStore(),
);

await jwtService.revokeToken(accessToken);

final payload = await jwtService.verifyAccessToken(accessToken); // null
```

For distributed deployments, implement `TokenStore` against Redis or a database:

```dart
class RedisTokenStore implements TokenStore {
  final RedisClient client;
  RedisTokenStore(this.client);

  @override
  Future<void> revoke(String jti) => client.set('revoked:$jti', '1');

  @override
  Future<bool> isRevoked(String jti) async =>
      await client.get('revoked:$jti') != null;
}
```

---

## Protecting Routes

Pass `authMiddleware` to any route's `middlewares` list:

```dart
ApiRoute<void, List<UserDTO>>(
  method: ApiMethod.get,
  path: '/users',
  typedHandler: getUsers,
  middlewares: [authMiddleware(jwtService)],
);
```

The verified JWT payload is available in the handler via `request.context['user']`:

```dart
Future<UserDTO> getProfile(Request request, void _) async {
  final user = request.context['user'] as Map<String, dynamic>;
  final userId = user['sub'] as String;
  // ...
}
```

---

## API Key Middleware

Use `apiKeyMiddleware` to protect routes with a static key — suitable for webhooks or internal service-to-service calls:

```dart
ApiRoute(
  method: ApiMethod.post,
  path: '/webhooks/stripe',
  middlewares: [
    apiKeyMiddleware(validKeys: {'whsec_abc123'}),
  ],
  typedHandler: handleStripeWebhook,
)
```

The default header is `X-API-Key`. Override with `headerName`:

```dart
apiKeyMiddleware(
  validKeys: {'my-internal-key'},
  headerName: 'X-Internal-Token',
)
```

The validated key is stored in `request.context['api_key']` for downstream handlers.

---

## Links

- [dartapi CLI](https://pub.dev/packages/dartapi)
- [dartapi_core](https://pub.dev/packages/dartapi_core)
- [dartapi_db](https://pub.dev/packages/dartapi_db)
- [GitHub](https://github.com/akashgk/dartapi_auth)

---

## License

BSD 3-Clause License © 2025 Akash G Krishnan
