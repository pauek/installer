import 'dart:convert';
import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';

class RunSdkManager extends SinglePriorStep {
  final List<String> packages;
  RunSdkManager(this.packages)
      : super("Running 'sdkmanager ${packages.join(" ")}'");

  @override
  Future run() async {
    final process = await Process.start(
      ctx.getBinary("sdkmanager"),
      packages,
      environment: ctx.environment,
    );
    process.stdin.write("y\n" * 50); // Accept licenses
    List<int> bStdout = [], bStderr = [];
    process.stdout.listen((bytes) => bStdout.addAll(bytes));
    process.stderr.listen((bytes) => bStderr.addAll(bytes));
    final exitCode = await process.exitCode;

    if (exitCode != 0) {
      final dec = Utf8Decoder();
      final stdout = dec.convert(bStdout);
      final stderr = dec.convert(bStderr);
      log.print("ERROR: sdkmanager returned $exitCode. Output:");
      log.printOutput(stdout);
      log.printOutput(stderr);
      return error("sdkmanager returned $exitCode");
    }
    log.print("info: 'sdkmanager' execution was successful.");
    // log.showOutput(stdout);
    return true;
  }
}
