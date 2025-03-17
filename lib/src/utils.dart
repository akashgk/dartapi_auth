extension TokenHelpers on Map<String, String> {
  String? authorization(String type) {
    final value = this['Authorization']?.split(' ');

    if (value != null && value.length == 2 && value.first == type) {
      return value.last;
    }

    return null;
  }

  String? bearer() => authorization('Bearer');
  String? basic() => authorization('Basic');

  String? getToken() {
    return bearer() ?? basic();
  }

  Map<String, String>? cookies() {
    final cookieString = this['Cookie'];
    if (cookieString == null) return null;

    final cookiesEntries = cookieString.split('; ').map((cookie) {
      final [key, value] = cookie.split('=');
      return MapEntry(key, value);
    });

    return Map.fromEntries(cookiesEntries);
  }
}
