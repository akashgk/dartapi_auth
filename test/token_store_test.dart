import 'package:dartapi_auth/dartapi_auth.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryTokenStore', () {
    late InMemoryTokenStore store;

    setUp(() {
      store = InMemoryTokenStore();
    });

    test('isRevoked returns false for unknown jti', () async {
      expect(await store.isRevoked('nonexistent-jti'), isFalse);
    });

    test('revoke marks a jti as revoked', () async {
      await store.revoke('jti-1');
      expect(await store.isRevoked('jti-1'), isTrue);
    });

    test('revoking one jti does not affect others', () async {
      await store.revoke('jti-1');
      expect(await store.isRevoked('jti-1'), isTrue);
      expect(await store.isRevoked('jti-2'), isFalse);
    });

    test('revoking the same jti twice is idempotent', () async {
      await store.revoke('jti-1');
      await store.revoke('jti-1');
      expect(await store.isRevoked('jti-1'), isTrue);
    });

    test('clear removes all revoked jtis', () async {
      await store.revoke('jti-1');
      await store.revoke('jti-2');
      store.clear();
      expect(await store.isRevoked('jti-1'), isFalse);
      expect(await store.isRevoked('jti-2'), isFalse);
    });

    test('can revoke multiple jtis independently', () async {
      await store.revoke('jti-a');
      await store.revoke('jti-b');
      await store.revoke('jti-c');
      expect(await store.isRevoked('jti-a'), isTrue);
      expect(await store.isRevoked('jti-b'), isTrue);
      expect(await store.isRevoked('jti-c'), isTrue);
      expect(await store.isRevoked('jti-d'), isFalse);
    });
  });
}
