import 'dart:convert';
import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';

class RunSdkManager extends SinglePriorStep {
  final List<String> packages;
  RunSdkManager(this.packages);

  @override
  Future run() async {
    final value = await input.run();
    if (value == null) {
      return null;
    }
    return await withMessage(
      "Running 'sdkmanager ${packages.join(" ")}'",
      () async {
        final process = await Process.start(
          ctx.getBinary("sdkmanager"),
          packages,
        );
        process.stdin.write("y\n" * 50); // Accept licenses
        List<int> bStdout = [], bStderr = [];
        process.stdout.listen((bytes) => bStdout.addAll(bytes));
        process.stderr.listen((bytes) => bStderr.addAll(bytes));
        final exitCode = await process.exitCode;

        if (exitCode != 0) {
          final dec = Utf8Decoder();
          // final stdout = dec.convert(bStdout);
          final stderr = dec.convert(bStderr);
          log.print("ERROR: sdkmanager returned $exitCode:");
          log.printOutput(stderr);
          throw "sdkmanager returned $exitCode";
        }
        log.print("'sdkmanager' execution was successful");
        // log.showOutput(stdout);
        return true;
      },
    );
  }
}
