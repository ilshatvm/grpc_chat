import 'dart:async';
import 'dart:developer';

import 'package:auth/data/db.dart';
import 'package:auth/domain/auth_rpc.dart';
import 'package:grpc/grpc.dart';

Future<void> startServer() async {
  runZonedGuarded(() async {
    final authServer = Server.create(
      services: [
        AuthRpc(),
      ],
      interceptors: [],
      codecRegistry: CodecRegistry(
        codecs: [
          GzipCodec(),
        ],
      ),
    );
    await authServer.serve(port: 4400);
    log("Server listen port ${authServer.port}...");
    db = initDb();
    db.open();
  }, (error, stack) {
    log("error", error: error);
  });
}