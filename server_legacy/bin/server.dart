import 'dart:async';
import 'dart:io';

import 'package:args/args.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:wexcom_sync_server/handlers.dart';
import 'package:wexcom_sync_server/store.dart';

Future<void> main(List<String> args) async {
  final parser = ArgParser()
    ..addOption('host', defaultsTo: '0.0.0.0')
    ..addOption('port', defaultsTo: '8787')
    ..addOption('db', defaultsTo: './wexcom-server.sqlite')
    ..addOption('user', defaultsTo: 'wexcom')
    ..addOption('pass')
    ..addFlag('version', abbr: 'v', negatable: false);
  final result = parser.parse(args);
  if (result['version'] == true) {
    stdout.writeln('wexcom-sync-server 1.0.0');
    return;
  }

  final host = result['host'] as String;
  final port = int.tryParse(result['port'] as String);
  if (port == null || port <= 0 || port > 65535) {
    stderr.writeln('Invalid --port value.');
    exitCode = 64;
    return;
  }

  final user = ((result['user'] as String?) ?? '').trim();
  final pass = ((result['pass'] as String?) ?? Platform.environment['WEXCOM_PASS'] ?? '')
      .trim();
  final envUser = Platform.environment['WEXCOM_USER']?.trim();
  final finalUser = envUser != null && envUser.isNotEmpty ? envUser : user;
  if (finalUser.isEmpty || pass.isEmpty) {
    stderr.writeln(
      'Missing credentials. Provide --user and --pass, or env WEXCOM_USER and WEXCOM_PASS.',
    );
    exitCode = 64;
    return;
  }

  final dbPath = result['db'] as String;
  final store = ServerStore.open(dbPath);
  final app = buildServerHandler(
    store: store,
    authUsername: finalUser,
    authPassword: pass,
  );

  // Try the requested port first, then fall back to subsequent ports if Windows
  // reports the address is already in use (errno 10048).
  const maxBindAttempts = 10;
  var bindPort = port;
  HttpServer? server;
  for (var attempt = 1; attempt <= maxBindAttempts; attempt++) {
    try {
      server = await shelf_io.serve(app, host, bindPort);
      break;
    } on SocketException catch (e) {
      final isPortInUse = e.osError?.errorCode == 10048;
      if (!isPortInUse || attempt == maxBindAttempts) {
        rethrow;
      }
      stdout.writeln(
        'Port $bindPort is in use, trying ${bindPort + 1}...',
      );
      bindPort += 1;
    }
  }
  if (server == null) {
    stderr.writeln('Failed to bind server after $maxBindAttempts attempts.');
    exitCode = 1;
    return;
  }
  final boundServer = server;
  stdout.writeln(
    'Listening on http://${boundServer.address.host}:${boundServer.port}',
  );

  final shutdownDone = Completer<void>();
  var shuttingDown = false;
  final signalSubs = <StreamSubscription<ProcessSignal>>[];

  Future<void> shutdown(String reason) async {
    if (shuttingDown) return;
    shuttingDown = true;
    stdout.writeln('Shutting down server ($reason)...');
    try {
      await boundServer.close(force: true);
    } finally {
      store.close();
      for (final sub in signalSubs) {
        await sub.cancel();
      }
      if (!shutdownDone.isCompleted) {
        shutdownDone.complete();
      }
    }
  }

  signalSubs.add(
    ProcessSignal.sigint.watch().listen((_) {
      shutdown('SIGINT');
    }),
  );
  // SIGTERM is not supported on Windows (errno 50: "The request is not supported").
  if (!Platform.isWindows) {
    signalSubs.add(
      ProcessSignal.sigterm.watch().listen((_) {
        shutdown('SIGTERM');
      }),
    );
  }
  await shutdownDone.future;
}
