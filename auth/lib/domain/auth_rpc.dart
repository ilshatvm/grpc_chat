import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:auth/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';

class AuthRpc extends AuthRpcServiceBase {
  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) {
    // TODO: implement fetchUser
    throw UnimplementedError();
  }

  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) {
    // TODO: implement refreshToken
    throw UnimplementedError();
  }

  @override
  Future<TokensDto> signIn(ServiceCall call, UserDto request) {
    return Future(
      () => TokensDto(
        accessToken: "accessToken",
        refreshToken: "refreshToken",
      ),
    );
  }

  @override
  Future<TokensDto> signUp(ServiceCall call, UserDto request) async {
    if (!db.isOpen) {
      db.open();
    }

    if (request.email.isEmpty) {
      throw GrpcError.invalidArgument("Email not found");
    }
    if (request.password.isEmpty) {
      throw GrpcError.invalidArgument("Password not found");
    }
    if (request.username.isEmpty) {
      throw GrpcError.invalidArgument("Username not found");
    }

    final id = await db.users.insertOne(
      UserInsertRequest(
        username: request.username,
        email: Utils.encryptField(request.email),
        password: Utils.getHashPassword(request.password),
      ),
    );

    return _createTokens(id.toString());
  }

  @override
  Future<UserDto> updateUser(ServiceCall call, UserDto request) {
    // TODO: implement updateUser
    throw UnimplementedError();
  }

  TokensDto _createTokens(String id) {
    final accessTokenClaims = JwtClaim(
      maxAge: Duration(seconds: Env.accessTokenLifetime),
      otherClaims: {"user_id": id},
    );
    final refreshTokenClaims = JwtClaim(
      maxAge: Duration(seconds: Env.refreshTokenLifetime),
      otherClaims: {"user_id": id},
    );
    return TokensDto(
      accessToken: issueJwtHS256(accessTokenClaims, Env.secretKey),
      refreshToken: issueJwtHS256(refreshTokenClaims, Env.secretKey),
    );
  }
}
