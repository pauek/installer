import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class RunCommand extends SinglePriorStep {
  final String cmd;
  final List<String> args;
  RunCommand(this.cmd, this.args);

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Running '$cmd ${args.join(" ")}'", () async {
      final currPath = Platform.environment['Path']?.split(';') ?? [];
      try {
        final cmdPath = ctx.getBinary(cmd);
        final env = {
          pathVariable: currPath.join(";"),
        };
        final result = await Process.run(cmdPath, args, environment: env);
        if (result.exitCode != 0) {
          log.print("ERROR: $cmd returned ${result.exitCode}.");
          return error("$cmd returned ${result.exitCode}");
        }
        log.print("info: '$cmd ${args.join(" ")}' execution was successful.");
        return true;
      } catch (e) {
        return error("ERROR: command '$cmd' failed: $e");
      }
    });
  }
}
