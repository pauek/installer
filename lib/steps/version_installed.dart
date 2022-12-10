import 'dart:io';

import 'package:installer2/log.dart';
import 'package:installer2/steps/step.dart';
import 'package:installer2/utils.dart';

class NotInstalled extends Step {
  final String cmd;
  final RegExp versionRegexp;
  NotInstalled(this.cmd, this.versionRegexp);

  @override
  Future run() async {
    final result = await waitForInput();
    if (result is InstallerError) {
      return result;
    }
    return withMessage("Determining if $cmd is installed", () async {
      final result = await Process.run(cmd, ["--version"], runInShell: true);
      final output = result.stdout.trim();
      final match = versionRegexp.firstMatch(output);
      String? version = match?.namedGroup("version");
      if (version != null) {
        log.print("$cmd: found version '$version'.");
      } else {
        log.print("$cmd: not found.");
      }
      return version == null;
    });
  }
}
