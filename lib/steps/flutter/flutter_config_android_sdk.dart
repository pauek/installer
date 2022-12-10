import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class FlutterConfigAndroidSDK extends SinglePriorStep {
  static String title = "Configuring Android SDK for Flutter";

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage(title, () async {
      final androidDir = join(ctx.targetDir, "android-sdk");
      try {
        final result = await Process.run(
          ctx.getBinary("flutter"),
          ["config", "--android-sdk", androidDir],
        );
        log.print("info: Configured Flutter Android SDK at '$androidDir'.");
        return result.exitCode == 0;
      } catch (e) {
        log.print("ERROR: Flutter config Android SDK failed:");
        log.printOutput(e.toString());
        return error("Configuring Android SDK for Flutter failed.");
      }
    });
  }
}
