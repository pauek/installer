import 'dart:io';

import 'package:installer2/context.dart';
import 'package:installer2/steps/step.dart';

class RunCommand extends SinglePriorStep {
  final String cmdline;
  RunCommand(this.cmdline);

  @override
  Future run() async {
    await input;
    show("Running '$cmdline'");
    final parts = cmdline.split(" ");
    await Process.run(
      ctx.getBinary(parts[0]),
      parts.sublist(1),
    );
  }
}
