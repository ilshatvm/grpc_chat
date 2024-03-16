import 'package:auth/data/db.dart';
import 'package:auth/data/user/user.dart';
import 'package:auth/env.dart';
import 'package:auth/generated/auth.pbgrpc.dart';
import 'package:auth/utils.dart';
import 'package:grpc/grpc.dart';
import 'package:jaguar_jwt/jaguar_jwt.dart';
import 'package:stormberry/stormberry.dart';

class AuthRpc extends AuthRpcServiceBase {
  @override
  Future<ResponseDto> deleteUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetadata(call);
    await db.users.deleteOne(id);

    return ResponseDto(message: "User deleted");
  }

  @override
  Future<UserDto> fetchUser(ServiceCall call, RequestDto request) async {
    final id = Utils.getIdFromMetadata(call);
    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound("User not found");

    return Utils.convertUserDto(user);
  }

  @override
  Future<TokensDto> refreshToken(ServiceCall call, TokensDto request) async {
    if (request.refreshToken.isEmpty) {
      throw GrpcError.invalidArgument("refresh token not found");
    }

    final id = Utils.getIdFromToken(request.refreshToken);
    final user = await db.users.queryUser(id);

    if (user == null) throw GrpcError.notFound("User not found");

    return _createTokens(user.id.toString());
  }

  @override
  Future<TokensDto> signIn(ServiceCall call, UserDto request) async {
    if (request.email.isEmpty) {
      throw GrpcError.invalidArgument("Email not found");
    }
    if (request.password.isEmpty) {
      throw GrpcError.invalidArgument("Password not found");
    }

    final hashPassword = Utils.getHashPassword(request.password);
    final users = await db.users.queryUsers(
      QueryParams(
        where: "email=@email",
        values: {"email": Utils.encryptField(request.email)},
      ),
    );
    if (users.isEmpty) throw GrpcError.notFound("User not found");

    final user = users.first;
    if (hashPassword != user.password) {
      throw GrpcError.invalidArgument("Wrong password");
    }

    return _createTokens(user.id.toString());
  }

  @override
  Future<TokensDto> signUp(ServiceCall call, UserDto request) async {
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
  Future<UserDto> updateUser(ServiceCall call, UserDto request) async {
    final id = Utils.getIdFromMetadata(call);

    await db.users.updateOne(UserUpdateRequest(
      id: id,
      email: request.email.isEmpty ? null : Utils.encryptField(request.email),
      username: request.username.isEmpty ? null : request.username,
    ));

    final user = await db.users.queryUser(id);
    if (user == null) throw GrpcError.notFound("User not found");

    return Utils.convertUserDto(user);
  }
  // TODO create method update password

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
