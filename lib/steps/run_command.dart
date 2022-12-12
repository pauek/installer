import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/nushell/configure_nushell.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';
import 'package:path/path.dart';

class RunCommand extends SinglePriorStep {
  final String cmd;
  final List<String> args;
  RunCommand(this.cmd, this.args)
      : super("Run command '$cmd ${args.join(" ")}");

  @override
  Future run() async {
    final envPath = Platform.environment['Path']?.split(';') ?? [];

    // Add node path for npm installs!
    envPath.add(
      dirname(ctx.getBinary("node")),
    );
    final cmdPath = ctx.getBinary(cmd);
    final env = {
      pathVariable: envPath.join(";"),
    };
    final result = await Process.run(cmdPath, args, environment: env);

    if (result.exitCode != 0) {
      log.print("ERROR: $cmd returned ${result.exitCode}.");
      log.print("ERROR: stdout:");
      log.printOutput(result.stdout.toString().trim());
      log.print("ERROR: stderr:");
      log.printOutput(result.stderr.toString().trim());
      return error("$cmd returned ${result.exitCode}");
    }
    log.print("info: '$cmd ${args.join(" ")}' execution was successful.");
    return true;
  }
}
