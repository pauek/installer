import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';

class AcceptAndroidLicenses extends Step {
  @override
  Future run() async {
    await waitForInput();
    return await withMessage("Accepting Android Licenses", () async {
      final process = await Process.start(
        ctx.getBinary("sdkmanager"),
        ["--licenses"],
      );
      process.stdin.write("y\n" * 50); // Accept licenses
      List<int> bStdout = [], bStderr = [];
      process.stdout.listen((bytes) => bStdout.addAll(bytes));
      process.stderr.listen((bytes) => bStderr.addAll(bytes));
      final exitCode = await process.exitCode;
      return exitCode == 0;
    });
  }
}
