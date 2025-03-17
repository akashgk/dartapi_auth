import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'jwt_service.dart';
import 'utils.dart';

/// Middleware to protect routes using JWT authentication
Middleware authMiddleware(JwtService jwtService) {
  return (Handler innerHandler) {
    return (Request request) async {
      final token = request.headers.getToken();

      if (token == null || token.isEmpty) {
        return Response.forbidden(
          jsonEncode({'error': 'Missing or invalid token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final payload = jwtService.verifyAccessToken(token);

      if (payload == null) {
        return Response.forbidden(
          jsonEncode({'error': 'Invalid token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      request = request.change(context: {'user': payload});
      return innerHandler(request);
    };
  };
}
