import 'package:auth/env.dart';
import 'package:stormberry/stormberry.dart';

late Connection db;

Future<Connection> initDatabase() async => await Connection.open(
      Endpoint(
        port: Env.dbPort,
        password: Env.dbPassword,
        username: Env.dbUser,
        database: Env.dbName,
        host: Env.dbHost,
      ),
      settings: ConnectionSettings(
        sslMode: SslMode.disable,
      ),
    );
