import 'dart:convert';
import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';

class AcceptAndroidLicenses extends Step {
  AcceptAndroidLicenses() : super("Accepting Android Licenses");

  @override
  Future run() async {
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
      return error("$title failed, log for details");
    }
    return true;
  }
}
