import 'dart:io';

import 'package:console/console.dart';
import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

Future<void> initPlatformVariables() async {
  String os = (await getCommandOutput("uname", [])).toLowerCase();
  String arch = await getCommandOutput("uname", ["-m"]);
  if (os.startsWith("mingw")) {
    os = "win";
  }
  if (arch == "x86_64") {
    arch = "x64";
  }
  ctx.addVariable("os", os);
  ctx.addVariable("arch", arch);
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
    targetDir: join(homeDir, "MobileDevelopment"),
    downloadDir: join(homeDir, "Downloads"),
  );
  Log.init(filename: "flutter-installer.log");
  await initPlatformVariables();

  log.print("Setup: ok");

  // Console.hideCursor();
  Console.eraseDisplay(2);
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
