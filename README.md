# DartAPI Auth

**DartAPI Auth** is a lightweight authentication package for Dart-based backend applications. It provides JWT-based authentication with built-in support for **access tokens**, **refresh tokens**, and **middleware protection**.

## 🚀 Features
- ✅ **JWT Authentication** (Signed JSON Web Tokens using `dart_jsonwebtoken`)
- ✅ **Access & Refresh Tokens** (With Expiry & Rotation Support)
- ✅ **Issuer (`iss`) & Audience (`aud`) Validation** for Security
- ✅ **Middleware Protection** for Securing Routes
- ✅ **Unit Tested** for Maximum Reliability

---

## 📌 Installation

Add `dartapi_auth` as a dependency in your Dart project:

```sh
dart pub add dartapi_auth
```

Or, add it manually to your `pubspec.yaml`:

```yaml
dependencies:
  dartapi_auth: ^1.0.0
```

---

## 🔑 Usage

### **1️⃣ Setting Up `JwtService`**
```dart
import 'package:dartapi_auth/jwt_service.dart';

void main() {
  final jwtService = JwtService(
    accessTokenSecret: 'your-very-secure-secret',
    refreshTokenSecret: 'your-super-secure-refresh-secret',
    issuer: 'dartapi-auth',
    audience: 'dartapi-users',
  );

  // ✅ Generate Access Token
  final accessToken = jwtService.generateAccessToken(claims: {
    'sub': 'user-123',
    'username': 'john_doe',
  });

  print('Access Token: \$accessToken');
}
```

---

### **2️⃣ Verifying Access Tokens**
```dart
final payload = jwtService.verifyAccessToken(accessToken);
if (payload != null) {
  print('Token is valid! User: \${payload['username']}');
} else {
  print('Invalid token!');
}
```

---

### **3️⃣ Generating & Verifying Refresh Tokens**
```dart
final refreshToken = jwtService.generateRefreshToken(accessToken: accessToken);
final verifiedPayload = jwtService.verifyRefreshToken(refreshToken);

if (verifiedPayload != null) {
  print('Refresh Token Verified! User: \${verifiedPayload['username']}');
} else {
  print('Invalid Refresh Token!');
}
```

---

### **4️⃣ Protecting Routes with Authentication Middleware**
```dart
import 'package:dartapi_auth/auth_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

void main() async {
  final handler = Pipeline()
      .addMiddleware(authMiddleware(jwtService))
      .addHandler((Request request) {
    final user = request.context['user'];
    return Response.ok('Hello, \${user?['username']}!');
  });

  final server = await io.serve(handler, 'localhost', 8080);
  print('🚀 Server running on http://localhost:8080');
}
```

---


Example **Login Response:**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ...",
  "expires_in": 3600
}
```

---

## 🛠 **Testing the Package**
Run tests using:
```sh
dart test
```

---

## 📜 License
This package is open-source and licensed under the **BSD-3-Clause License**.

© 2025 Akash G Krishnan. All rights reserved.

