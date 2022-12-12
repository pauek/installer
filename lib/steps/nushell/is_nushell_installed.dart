import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class IsNushellInstalled extends Step {
  IsNushellInstalled() : super("Nu shell is missing");

  @override
  Future run() async {
    final nuexePath = join(ctx.targetDir, "nu", "nu.exe");
    if (!(await isFilePresent(nuexePath))) {
      log.print("info: Nushell not found.");
      return false;
    }

    // Try to execute it (and get the version)
    final nuProcess = await Process.run(nuexePath, ["--version"]);
    if (nuProcess.exitCode != 0) {
      log.print("info: Nushell not found.");
      return false;
    }

    final version = nuProcess.stdout.toString().trim();
    log.print("info: Nushell found, version '$version'.");
    ctx.addBinary("nu", join(ctx.targetDir, "nu"), "nu.exe");
    return true;
  }
}
