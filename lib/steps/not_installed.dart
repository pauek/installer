import 'dart:io';

import 'package:installer/installer.dart';
import 'package:installer/steps/step.dart';

class NotInstalled extends Step {
  final String cmd;
  final RegExp versionRegexp;
  NotInstalled(this.cmd, this.versionRegexp)
      : super("Determine if $cmd is not installed");

  @override
  Future run() async {
    final result = await Process.run(cmd, ["--version"], runInShell: true);
    final output = result.stdout.trim();
    final match = versionRegexp.firstMatch(output);
    String? version = match?.namedGroup("version");
    if (version != null) {
      log.print("info: found '$cmd' version '$version'.");
    } else {
      log.print("info: '$cmd' not found.");
    }
    return version == null;
  }
}
