import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';

class RunCommand extends SinglePriorStep {
  final String cmd;
  final List<String> args;
  RunCommand(this.cmd, this.args);

  @override
  Future run() async {
    final value = await input.run();
    if (value == null) {
      return null;
    }
    return await withMessage(
      "Running '$cmd ${args.join(" ")}'",
      () async {
        final result = await Process.run(ctx.getBinary(cmd), args);
        if (result.exitCode != 0) {
          log.print("ERROR: $cmd returned $exitCode:");
          log.showOutput(result.stderr.toString().trim());
          throw "$cmd returned $exitCode";
        }
        log.print("'$cmd ${args.join(" ")}' execution was successful");
        return true;
      },
    );
  }
}
