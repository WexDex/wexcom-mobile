import 'dart:convert';

import 'package:shelf/shelf.dart';

Middleware basicAuthMiddleware({
  required String username,
  required String password,
}) {
  return (innerHandler) {
    return (request) async {
      if (request.url.path == 'status' && request.url.queryParameters['ping'] == '1') {
        return innerHandler(request);
      }

      final auth = request.headers['authorization'];
      if (auth == null || !auth.toLowerCase().startsWith('basic ')) {
        return _unauthorized();
      }
      final encoded = auth.substring(6).trim();
      final decoded = utf8.decode(base64.decode(encoded), allowMalformed: true);
      final idx = decoded.indexOf(':');
      if (idx < 0) {
        return _unauthorized();
      }
      final user = decoded.substring(0, idx);
      final pass = decoded.substring(idx + 1);
      final userOk = _constantTimeEquals(user, username);
      final passOk = _constantTimeEquals(pass, password);
      if (!userOk || !passOk) {
        return _unauthorized();
      }
      return innerHandler(request);
    };
  };
}

bool _constantTimeEquals(String a, String b) {
  final aa = utf8.encode(a);
  final bb = utf8.encode(b);
  var mismatch = aa.length ^ bb.length;
  final maxLen = aa.length > bb.length ? aa.length : bb.length;
  for (var i = 0; i < maxLen; i++) {
    final av = i < aa.length ? aa[i] : 0;
    final bv = i < bb.length ? bb[i] : 0;
    mismatch |= av ^ bv;
  }
  return mismatch == 0;
}

Response _unauthorized() {
  return Response(
    401,
    body: 'Unauthorized',
    headers: const {'www-authenticate': 'Basic realm="wexcom"'},
  );
}
