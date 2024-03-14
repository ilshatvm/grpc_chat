import 'package:stormberry/stormberry.dart';

late Database db;

Database initDb() {
  db = Database(
    port: 4500,
    password: "password",
    username: "admin",
    useSSL: false,
    database: "postgres",
    host: "127.0.0.1",
  );
  return db;
}
