import 'dart:convert';
import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class AcceptAndroidLicenses extends Step {
  static String title = "Accepting Android Licenses";
  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage(title, () async {
      final process = await Process.start(
        ctx.getBinary("sdkmanager"),
        ["--licenses"],
        environment: ctx.environment,
      );
      process.stdin.write("y\n" * 50); // Accept licenses
      List<int> bStdout = [], bStderr = [];
      process.stdout.listen((bytes) => bStdout.addAll(bytes));
      process.stderr.listen((bytes) => bStderr.addAll(bytes));
      final exitCode = await process.exitCode;
      if (exitCode != 0) {
        final dec = Utf8Decoder();
        log.print("ERROR: $title failed, stderr:");
        log.printOutput(dec.convert(bStderr));
        log.printOutput(dec.convert(bStdout));
        return InstallerError("$title failed, log for details");
      }
      return true;
    });
  }
}
