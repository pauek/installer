import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/nushell/configure_nushell.dart';
import 'package:installer/steps/step.dart';

class EnvVar {
  String variable, value;
  EnvVar({required this.variable, required this.value});
}

class RunCommand extends SinglePriorStep {
  final String cmd;
  final List<String> args;
  final List<String> envPath;
  RunCommand(
    this.cmd, {
    this.args = const [],
    this.envPath = const [],
  }) : super("Run command '$cmd ${args.join(" ")}'");

  @override
  Future run() async {
    final pathList = Platform.environment['Path']?.split(';') ?? [];

    // Add directories to PATH
    for (final dir in envPath) {
      pathList.add(dir);
    }

    final cmdPath = ctx.getBinary(cmd);

    final result = await Process.run(cmdPath, args, environment: {
      pathVariable: pathList.join(";"),
    });

    if (result.exitCode != 0) {
      log.print("ERROR: $cmd returned ${result.exitCode}.");
      log.print("ERROR: stdout:");
      log.printOutput(result.stdout.toString().trim());
      log.print("ERROR: stderr:");
      log.printOutput(result.stderr.toString().trim());
      return installerError("$cmd returned ${result.exitCode}");
    }
    log.print("info: '$cmd ${args.join(" ")}' execution was successful.");
    return true;
  }
}
