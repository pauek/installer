import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';
import 'package:path/path.dart';

class FlutterConfigAndroidSDK extends SinglePriorStep {
  FlutterConfigAndroidSDK() : super("Configuring Android SDK for Flutter");

  @override
  Future run() async {
    final androidDir = join(ctx.targetDir, "android-sdk");
    final result = await Process.run(
      ctx.getBinary("flutter"),
      ["config", "--android-sdk", androidDir],
    );
    log.print("info: Configured Flutter Android SDK at '$androidDir'.");
    return result.exitCode == 0;
  }
}
