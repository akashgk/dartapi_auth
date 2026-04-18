# dartapi_auth

**`dartapi_auth`** is a lightweight authentication and authorization package designed for the [DartAPI](https://pub.dev/packages/dartapi) ecosystem. It provides JWT-based authentication utilities, middleware for request protection, token revocation, and API key validation.

It is fully compatible with projects generated using the [DartAPI CLI](https://pub.dev/packages/dartapi), and integrates seamlessly with `ApiRoute<ApiInput, ApiOutput>`.

---

## Features

- JWT Access & Refresh Token generation (HS256 and RS256)
- Async token verification with expiration, type, issuer, and audience checks
- Token revocation via injectable `TokenStore` (built-in `InMemoryTokenStore`)
- Plug-and-play `authMiddleware` for protecting routes
- `apiKeyMiddleware` for API key-based auth (webhooks, service-to-service)
- Works with `dartapi_core` and `dartapi`

---

## Installation

```yaml
dependencies:
  dartapi_auth: ^0.0.6
```

---

## Usage

### Setup JwtService (HS256 — symmetric)

```dart
final jwtService = JwtService(
  accessTokenSecret: 'my-access-secret',
  refreshTokenSecret: 'my-refresh-secret',
  issuer: 'my-app',
  audience: 'api-clients',
);
```

### Setup JwtService (RS256 — asymmetric)

Use RS256 when you need to share the public key with other services for token verification without exposing the signing key.

```dart
final jwtService = JwtService.rs256(
  privateKeyPem: File('private.pem').readAsStringSync(),
  publicKeyPem: File('public.pem').readAsStringSync(),
  issuer: 'my-app',
  audience: 'api-clients',
);
```

### Generate Tokens

```dart
final accessToken = jwtService.generateAccessToken(claims: {
  'sub': 'user-123',
  'username': 'akash',
});

final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
```

### Verify Tokens

Both methods are async and return `null` on failure (expired, wrong issuer, revoked, etc.):

```dart
final accessPayload = await jwtService.verifyAccessToken(accessToken);
final refreshPayload = await jwtService.verifyRefreshToken(refreshToken);
```

---

## Token Revocation

Provide a `TokenStore` to enable revocation. The built-in `InMemoryTokenStore` is suitable for single-instance servers:

```dart
final jwtService = JwtService(
  accessTokenSecret: 'my-secret',
  refreshTokenSecret: 'my-refresh-secret',
  issuer: 'my-app',
  audience: 'api-clients',
  tokenStore: InMemoryTokenStore(),
);

// Revoke a token (e.g. on logout)
await jwtService.revokeToken(accessToken);

// Now returns null
final payload = await jwtService.verifyAccessToken(accessToken); // null
```

Implement `TokenStore` with Redis or a database for distributed setups:

```dart
class RedisTokenStore implements TokenStore {
  final RedisClient client;
  RedisTokenStore(this.client);

  @override
  Future<void> revoke(String jti) => client.set('revoked:$jti', '1');

  @override
  Future<bool> isRevoked(String jti) async {
    return await client.get('revoked:$jti') != null;
  }
}
```

---

## Protect Routes with authMiddleware

```dart
ApiRoute<void, List<UserDTO>>(
  method: ApiMethod.get,
  path: '/users',
  typedHandler: getUsers,
  middlewares: [authMiddleware(jwtService)],
);
```

The validated JWT payload is available in the handler via `request.context['user']`:

```dart
Future<UserDTO> getProfile(Request request, void _) async {
  final user = request.context['user'] as Map<String, dynamic>;
  final userId = user['sub'] as String;
  // ...
}
```

---

## API Key Middleware

Protect routes (e.g. webhooks, internal APIs) with a static key:

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

Customize the header name (default is `X-API-Key`):

```dart
apiKeyMiddleware(
  validKeys: {'my-internal-key'},
  headerName: 'X-Internal-Token',
)
```

The validated key is stored in `request.context['api_key']` for downstream handlers.

---

## Exports

- `JwtService`
- `TokenStore`, `InMemoryTokenStore`
- `authMiddleware()`
- `apiKeyMiddleware()`

---

## License

BSD 3-Clause License © 2025 Akash G Krishnan  
[LICENSE](./LICENSE)

---

## Related

- [dartapi](https://pub.dev/packages/dartapi) - CLI to generate projects using this
- [dartapi_core](https://pub.dev/packages/dartapi_core) - Type-safe API routing & controller logic
- [dartapi_db](https://pub.dev/packages/dartapi_db) - DB abstraction layer
