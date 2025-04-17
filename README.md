# dartapi_auth

**`dartapi_auth`** is a lightweight authentication and authorization package designed for the [DartAPI](https://pub.dev/packages/dartapi) ecosystem. It provides JWT-based authentication utilities, middleware for request protection, and token lifecycle management.

It is fully compatible with projects generated using the [DartAPI CLI](https://pub.dev/packages/dartapi), and integrates seamlessly with `ApiRoute<ApiInput, ApiOutput>`.

---

## ✨ Features

- 🔐 JWT Access & Refresh Token generation
- 🧾 Token verification with expiration, type, and issuer checks
- 🛡️ Plug-and-play authentication middleware for protected routes
- 🧠 Helpers to extract tokens from headers or cookies
- ✅ Works perfectly with `dartapi_core` and `dartapi`

---

## 📦 Installation

```yaml
dependencies:
  dartapi_auth: ^0.0.4
```

---

# 🚀 Usage

### 🔑 Setup JwtService

```dart
final jwtService = JwtService(
  accessTokenSecret: 'my-secret',
  refreshTokenSecret: 'my-refresh-secret',
  issuer: 'dartapi',
  audience: 'api-clients',
);
```

### 🧪 Generate Tokens

```dart
final accessToken = jwtService.generateAccessToken(claims: {
  'sub': 'user-123',
  'username': 'akash',
});

final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
```

### 🔍 Verify Tokens

```dart
final accessPayload = jwtService.verifyAccessToken(accessToken);
final refreshPayload = jwtService.verifyRefreshToken(refreshToken);
```

---

## 🔒 Use Middleware to Protect Routes

### Import middleware

```dart
import 'package:dartapi_auth/dartapi_auth.dart';
```

### Apply per-route:

```dart
ApiRoute<void, List<UserDTO>>(
  method: ApiMethod.get,
  path: '/users',
  typedHandler: getUsers,
  middlewares: [authMiddleware(jwtService)],
);
```


## 📄 Example Use in dartapi CLI Project

`bin/main.dart`

```dart
final jwtService = JwtService(...);
final app = DartAPI();

app.addControllers([
  UserController(jwtService),
  AuthController(jwtService),
]);
```

`UserController`

```dart
ApiRoute<void, List<UserDTO>>(
  method: ApiMethod.get,
  path: '/users',
  typedHandler: getAllUsers,
  middlewares: [authMiddleware(jwtService)],
);
```

---

## 📁 Exports

- `JwtService`
- `authMiddleware()`
- `utils.dart`

---

## 📄 License

BSD 3-Clause License © 2025 Akash G Krishnan  
[LICENSE](./LICENSE)

---

## 🔗 Related

- [dartapi](https://pub.dev/packages/dartapi) - CLI to generate projects using this
- [dartapi_core](https://pub.dev/packages/dartapi_core) - Type-safe API routing & controller logic
- [dartapi_db](https://pub.dev/packages/dartapi_db) - DB abstraction layer