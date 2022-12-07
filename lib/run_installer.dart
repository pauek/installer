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
  Console.init();
  final homeDir = getHomeDir();
  await InstallerContext.init(
    targetDir: join(homeDir, "MobileDevelopment2"),
    downloadDir: join(homeDir, "Downloads"),
  );
  Log.init(filename: "flutter-installer.log");
  await initPlatformVariables();

  log.print("Setup: ok");

  // Console.hideCursor();
  Console.eraseDisplay(2);
  Console.hideCursor();
  final lastPos = installer.setPos(CursorPosition(1, 1));
  Console.moveCursor(column: 1, row: 1);
  await installer.run();
  await logEnv();
  await log.close();
  Console.moveCursor(column: lastPos.column, row: lastPos.row);
  Console.write("[Press any key or close the terminal]\n");
  Console.showCursor();
  Console.readLine();
  exit(0); // Bug in Console??
}
