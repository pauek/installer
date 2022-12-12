import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

String get codeCmd {
  if (Platform.isWindows) {
    return "code.cmd";
  } else {
    return "code";
  }
}

class VSCodeMissing extends Step {
  VSCodeMissing() : super("See if VSCode is missing");

  @override
  Future run() async {
    final vscodeDir = join(ctx.targetDir, "vscode");
    final vscodePath = join(vscodeDir, "bin", codeCmd);
    if (!(await isFilePresent(vscodePath))) {
      return true;
    }

    // Try to execute it (and get the version)
    final vscodeProcess = await Process.run(vscodePath, ["--version"]);
    if (vscodeProcess.exitCode != 0) {
      return true;
    }

    final version = vscodeProcess.stdout.toString().trim().split("\n");
    log.print("info: VSCode found, version '${version[0]}'.");
    ctx.addBinary("code", dirname(vscodePath), "code.cmd");

    return false; // not missing
  }
}
