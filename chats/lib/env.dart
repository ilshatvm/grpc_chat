import 'dart:io';

abstract class Env {
  //TODO replace <Type>.fromEnvironment with Platrorm.environment
  static int port = int.parse(Platform.environment['PORT'] ?? "4401");
  static String secretKey =
      String.fromEnvironment("SK", defaultValue: "SECRET_KEY");
  // static String dbSecretKey =
  //     String.fromEnvironment("DB_SK", defaultValue: '?J<v^LEncW1yA)vp');

  static int dbPort = int.parse(Platform.environment['DB_PORT'] ?? "4501");
  static String dbHost = Platform.environment["DB_HOST_ADDRESS"] ?? "localhost";
  static String dbName =
      String.fromEnvironment("DB_NAME", defaultValue: "postgres");
  static String dbUser =
      String.fromEnvironment("DB_USERNAME", defaultValue: "admin");
  static String dbPassword =
      String.fromEnvironment("DB_PASSWORD", defaultValue: "password");
  static bool dbUseSSL = bool.fromEnvironment("DB_SSL", defaultValue: false);

  //   - PORT=${auth_port}
  // - SECRET_KEY=${secret_key}
  // - DB_HOST_ADDRESS=db_auth
  // - DB_PORT=${db_port_auth}
  // - DB_NAME=${db_name_auth}
  // - DB_USERNAME=${db_user_auth}
  // - DB_PASSWORD=${db_password_auth}
  // - DB_SSL=${db_use_ssl}
  // - DB_SECRET_KEY=${db_sk_auth}
  // - ACCESS_TOKEN_LIFETIME=${access_token_lifetime}
  // - REFRESH_TOKEN_LIFETIME=${refresh_token_lifetime}
}
