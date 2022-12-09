import 'dart:io';

import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

late final String os, arch;

Future<void> initPlatformVariables() async {
  os = await getOS();
  arch = await getArch();
}

Future<void> logEnv() async {
  if (ctx.path.isNotEmpty) {
    log.print("Path:");
    for (final entry in ctx.path) {
      log.print("  $entry");
    }
  }
  for (final entry in ctx.variables) {
    log.print("${entry.variable} = ${entry.value}");
  }
  for (final entry in ctx.binaries.entries) {
    log.print("${entry.key} = ${entry.value}");
  }
}

Future<void> runInstaller(Step installer) async {
  final startTime = DateTime.now();
  Console.init();
  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "MobileDevelopment2"),
    downloadDir: join(homeDir, "Downloads"),
  );
  Log.init(filename: "flutter-installer.log");
  await initPlatformVariables();

  log.print("Setup: ok");

  Console.hideCursor();
  Console.eraseDisplay(2);
  Console.hideCursor();
  final lastPos = installer.setPos(CursorPosition(1, 1));
  Console.moveCursor(column: 1, row: 1);

  try {
    await installer.run();
  } catch (e) {
    log.print("runInstaller error: ${e.toString()}");
  }

  await logEnv();
  await log.close();
  Console.moveCursor(column: lastPos.column, row: lastPos.row + 1);

  final endTime = DateTime.now();
  final total = endTime.difference(startTime);
  String totalStr = "";
  if (total.inMinutes < 1) {
    totalStr = "${total.inSeconds}s";
  } else {
    totalStr = "${total.inMinutes}m ${(total.inSeconds.remainder(60))}s";
  }
  Console.write("Installation time: $totalStr\n");

  Console.showCursor();
  if (!Platform.isWindows) {
    Console.write("[Press any key or close the terminal]\n");
    Console.readLine();
  }

  // Note: we need this here because Console.hideCursor installs a
  // SIGINT catcher and probably Dart doesn't exit if that the handler
  // can still catch events.
  exit(0);
}
