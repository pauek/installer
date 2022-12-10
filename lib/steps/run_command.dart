import 'dart:convert';
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
    final value = await waitForInput();
    if (value == null) {
      return null;
    }
    return withMessage("Running '$cmd ${args.join(" ")}'", () async {
      final currPath = Platform.environment['Path']?.split(';') ?? [];
      try {
        final cmdPath = ctx.getBinary(cmd);
        final env = {
          pathVariable: currPath.join(";"),
        };

        final process = await Process.start(cmdPath, args, environment: env);
        final dec = Utf8Decoder();
        process.stdout.listen((bytes) => log.print(dec.convert(bytes)));
        process.stderr.listen((bytes) => log.print(dec.convert(bytes)));
        final exitCode = await process.exitCode;
        if (exitCode != 0) {
          log.print("ERROR: $cmd returned $exitCode:");
          return error("$cmd returned $exitCode");
        }
        log.print("'$cmd ${args.join(" ")}' execution was successful");
        return true;
      } catch (e) {
        return error("ERROR: command '$cmd' failed: $e");
      }
    });
  }
}
