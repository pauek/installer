import 'dart:convert';
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
    final value = await input;
    if (value == null) {
      return null;
    }
    show("Running '$cmd ${args.join(" ")}'");
    final process = await Process.start(ctx.getBinary(cmd), args);
    process.stdin.write("y\n" * 50); // Accept licenses
    List<int> bStdout = [], bStderr = [];
    process.stdout.listen((bytes) => bStdout.addAll(bytes));
    process.stderr.listen((bytes) => bStderr.addAll(bytes));
    final exitCode = await process.exitCode;

    final dec = Utf8Decoder();
    // final stdout = dec.convert(bStdout);
    final stderr = dec.convert(bStderr);
    if (exitCode != 0) {
      log.print("ERROR: $cmd returned $exitCode:");
      log.showOutput(stderr);
      throw "$cmd returned $exitCode";
    }
    log.print("'$cmd' execution was successful");
    // log.showOutput(stdout);
    return true;
  }
}
