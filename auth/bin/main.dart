import 'package:auth/auth.dart' as auth;
import 'package:auth/env.dart';

void main(List<String> arguments) {
  print("port ${Env.port}");
  print("db port ${Env.dbPort}");
  print("password ${Env.dbPassword}");
  print("username ${Env.dbUser}");
  print("database ${Env.dbName}");
  print("host ${Env.dbHost}");
  auth.startServer();
}
