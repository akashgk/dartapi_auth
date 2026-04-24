/// DEPRECATED: `dartapi_auth` has been merged into `dartapi_core ^0.1.0`.
///
/// Replace your dependency:
/// ```yaml
/// # Before
/// dependencies:
///   dartapi_auth: ^0.0.10
///
/// # After
/// dependencies:
///   dartapi_core: ^0.1.0
/// ```
///
/// And update your imports:
/// ```dart
/// // Before
/// import 'package:dartapi_auth/dartapi_auth.dart';
///
/// // After
/// import 'package:dartapi_core/dartapi_core.dart';
/// ```
///
/// This shim re-exports all auth symbols from `dartapi_core` for one-version
/// backwards compatibility and will be removed in the next release.
@Deprecated(
  'dartapi_auth is merged into dartapi_core ^0.1.0. '
  'Replace `dartapi_auth` with `dartapi_core` in your pubspec '
  'and update imports accordingly.',
)
library;

export 'package:dartapi_core/dartapi_core.dart'
    show
        JwtService,
        TokenStore,
        InMemoryTokenStore,
        authMiddleware,
        apiKeyMiddleware,
        TokenHelpers;
