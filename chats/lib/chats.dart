import 'dart:async';
import 'dart:developer';

import 'package:chats/data/db.dart';
import 'package:chats/data/grpc_interceptors.dart';
import 'package:chats/env.dart';
import 'package:grpc/grpc.dart';

Future<void> startServer() async {
  runZonedGuarded(() async {
    final chatsServer = Server.create(
      services: [],
      interceptors: [
        GrpcInterceptors.tokenInterceptor,
      ],
      codecRegistry: CodecRegistry(
        codecs: [
          GzipCodec(),
        ],
      ),
    );
    await chatsServer.serve(port: Env.port);
    log("Server listen port ${chatsServer.port}...");

    db = await initDatabase();
  }, (error, stack) {
    log("error", error: error);
  });
}
