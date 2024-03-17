import 'package:chats/chats.dart';
import 'package:chats/env.dart';

void main(List<String> arguments) {
  print("port ${Env.port}");
  print("db port ${Env.dbPort}");
  print("password ${Env.dbPassword}");
  print("username ${Env.dbUser}");
  print("database ${Env.dbName}");
  print("host ${Env.dbHost}");
  startServer();
}
