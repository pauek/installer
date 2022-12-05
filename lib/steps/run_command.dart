import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';

class RunCommand extends SinglePriorStep {
  final List<String> cmdline;
  RunCommand(this.cmdline);

  @override
  Future run() async {
    final result = await input;
    if (result != null) {
      show("Running '${cmdline[0]} ${cmdline.sublist(1).join(" ")}'");
      await Process.run(
        ctx.getBinary(cmdline[0]),
        cmdline.sublist(1),
      );
      return true;
    }
    return null;
  }
}
