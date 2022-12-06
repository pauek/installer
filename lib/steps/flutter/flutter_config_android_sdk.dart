import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:path/path.dart';

class FlutterConfigAndroidSDK extends SinglePriorStep {
  @override
  Future run() async {
    await waitForInput();
    return await withMessage("Configuring Android SDK for Flutter", () async {
      final androidDir = join(ctx.targetDir, "android-sdk");
      final result = await Process.run(
        ctx.getBinary("flutter"),
        ["config", "--android-sdk", androidDir],
      );
      log.print("Configured Flutter Android SDK at '$androidDir'");
      return result.exitCode == 0;
    });
  }
}
