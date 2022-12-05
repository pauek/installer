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
    final result = await input;
    if (result != null) {
      final binary = ctx.getBinary(cmd);
      show("Running '$binary ${args.sublist(1).join(" ")}'");
      final result = await Process.run(binary, args);
      if (result.exitCode != 0) {
        log.print("ERROR: $cmd returned ${result.exitCode}:");
        final stderr = result.stderr.toString();
        for (final line in stderr.trim().split(" ")) {
          log.print(" >> $line");
        }
        throw "$cmd returned ${result.exitCode}";
      }
      return true;
    }
    return null;
  }
}
