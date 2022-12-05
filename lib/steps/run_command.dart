import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';

class RunCommand extends SinglePriorStep {
  final String cmdline;
  RunCommand(this.cmdline);

  @override
  Future run() async {
    final result = await input;
    if (result != null) {
      final parts = cmdline.split(" ");
      show("Running '${parts[0]} ${parts.sublist(1).join(" ")}'");
      await Process.run(
        ctx.getBinary(parts[0]),
        parts.sublist(1),
      );
      return true;
    }
    return null;
  }
}
