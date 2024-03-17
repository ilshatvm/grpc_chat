import 'dart:async';

import 'package:chats/data/db.dart';
import 'package:chats/env.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class GrpcInterceptors {
  static FutureOr<GrpcError?> tokenInterceptor(
    ServiceCall call,
    ServiceMethod method,
  ) async {
    _checkDatabase();

    try {
      final token = call.clientMetadata?['access_token'] ?? "";
      final jwtClaim = verifyJwtHS256Signature(token, Env.secretKey);
      jwtClaim.validate();
      return null;
    } catch (_) {
      return GrpcError.unauthenticated("Invalid token");
    }
  }

  static void _checkDatabase() async {
    if (db.isOpen == false) {
      db.close();
      db = await initDatabase();
    }
  }
}
