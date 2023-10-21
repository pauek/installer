import 'dart:io';

import 'package:console/console.dart';
import 'package:installer/installer/context.dart';
import 'package:installer/installer/log.dart';
import 'package:installer/installer/utils.dart';
import 'package:installer/steps.dart';

late final String os, arch;

Future<void> initPlatformVariables() async {
  os = await getOS();
  arch = await getArch();
}

Future<void> logEnv() async {
  if (ctx.path.isNotEmpty) {
    log.print("info: Path:");
    for (final entry in ctx.path) {
      log.print("   >> $entry");
    }
  }
  log.print("info: Environment variables:");
  for (final entry in ctx.variableList) {
    log.print("   >> ${entry.variable} = ${entry.value}");
  }
  log.print("info: Registered binaries:");
  for (final entry in ctx.binaries.entries) {
    log.print("   >> ${entry.key} = ${entry.value}");
  }
}

Future<void> runInstaller(Step installer) async {
  final startTime = DateTime.now();
  Console.init();

  await initPlatformVariables();

  log.print("info: Setup ok.");

  Console.eraseDisplay(2);
  Console.hideCursor();
  final lastPos = installer.setPos(CursorPosition(1, 1));
  Console.moveCursor(column: 1, row: 1);

  dynamic result;
  try {
    result = await installer.runChecked();
  } catch (e) {
    result = e;
  }
  log.print("Final result was: $result");

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

  final pen = TextPen();
  pen.setColor(Color.GOLD);
  pen.text("Installation time: ");
  pen.setColor(Color.YELLOW);
  pen.text("$totalStr\n\n");
  pen.setColor(Color.GRAY);
  pen.text("[Press any key or close the terminal]\n\n");
  pen.print();

  Console.showCursor();
  Console.readLine();

  // Note: we need this here because Console.hideCursor installs a
  // SIGINT catcher and probably Dart doesn't exit if the handler
  // can still catch events.
  exit(0);
}
