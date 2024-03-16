import 'dart:convert';

import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

abstract class Utils {
  static String getHashPassword(String password) {
    final bytes = utf8.encode(password + Env.secretKey);
    return sha256.convert(bytes).toString();
  }

  static String encryptField(String value, {bool isDecode = false}) {
    final key = Key.fromUtf8(Env.dbSecretKey);
    final iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(key, mode: AESMode.ecb));

    return isDecode
        ? encrypter.decrypt64(value, iv: iv)
        : encrypter.encrypt(value, iv: iv).base64;
  }

  static int getIdFromToken(String token) {
    final jwtClaim = verifyJwtHS256Signature(token, Env.secretKey);
    final id = int.tryParse(jwtClaim['user_id']);
    if (id == null) throw GrpcError.dataLoss("Can't get user id from token");
    return id;
  }

  static int getIdFromMetadata(ServiceCall call) {
    final accessToken = call.clientMetadata?['access_token'] ?? "";
    return getIdFromToken(accessToken);
  }

  static UserDto convertUserDto(UserView user) => UserDto(
        email: encryptField(user.email, isDecode: true),
        id: user.id.toString(),
        username: user.username,
      );
}
